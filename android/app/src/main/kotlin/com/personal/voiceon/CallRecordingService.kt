package com.personal.voiceon

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaCodec
import android.media.MediaCodecInfo
import android.media.MediaFormat
import android.media.MediaMuxer
import android.media.MediaRecorder
import android.os.Build
import android.os.IBinder
import android.util.Log
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.nio.ByteBuffer
import java.util.UUID

class CallRecordingService : Service() {

    companion object {
        private const val TAG = "CallRecordingService"
        private const val CHANNEL_ID = "voiceon_calls"
        private const val NOTIFICATION_ID = 1001
        private const val FLUTTER_ENGINE_ID = "main_engine"
        private const val METHOD_CHANNEL = "voiceon/calls"

        private const val SAMPLE_RATE = 44100
        private const val CHANNEL_CONFIG = AudioFormat.CHANNEL_IN_MONO
        private const val AUDIO_FORMAT = AudioFormat.ENCODING_PCM_16BIT
        private const val BIT_RATE = 128_000
        private const val AAC_MIME = "audio/mp4a-latm"

        // Public state accessible by CallDetectorReceiver
        @Volatile var pendingOutgoingNumber: String? = null
        @Volatile var currentCallNumber: String = ""

        fun start(context: Context, phoneNumber: String, direction: String) {
            val intent = Intent(context, CallRecordingService::class.java).apply {
                putExtra("phoneNumber", phoneNumber)
                putExtra("direction", direction)
            }
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    context.startForegroundService(intent)
                } else {
                    context.startService(intent)
                }
            } catch (e: Exception) {
                Log.e(TAG, "Failed to start CallRecordingService", e)
            }
        }

        fun stop(context: Context) {
            val intent = Intent(context, CallRecordingService::class.java).apply {
                action = "STOP_RECORDING"
            }
            context.startService(intent)
        }

    }

    // Recording state
    private var audioRecord: AudioRecord? = null
    private var recordingThread: Thread? = null
    private var isRecording = false

    private var callUuid: String = ""
    private var callDirection: String = "incoming"
    private var startTimestampMs: Long = 0L
    private var pcmTempFile: File? = null
    private var outputM4aFile: File? = null

    // ─────────────────────────────────────────────────────────
    // Lifecycle
    // ─────────────────────────────────────────────────────────

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == "STOP_RECORDING") {
            stopRecording()
            stopSelf()
            return START_NOT_STICKY
        }

        // Already recording — don't start again
        if (isRecording) return START_NOT_STICKY

        val phoneNumber = intent?.getStringExtra("phoneNumber") ?: pendingOutgoingNumber ?: ""
        val direction = intent?.getStringExtra("direction") ?: "incoming"

        currentCallNumber = phoneNumber
        callDirection = direction
        // Clear pending outgoing number once consumed
        pendingOutgoingNumber = null

        startForeground(NOTIFICATION_ID, buildNotification())
        startRecording(phoneNumber, direction)

        return START_NOT_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        if (isRecording) stopRecording()
    }

    // ─────────────────────────────────────────────────────────
    // Recording
    // ─────────────────────────────────────────────────────────

    private fun startRecording(phoneNumber: String, direction: String) {
        callUuid = UUID.randomUUID().toString()
        startTimestampMs = System.currentTimeMillis()

        val recDir = File(filesDir, "call_recordings").apply { mkdirs() }
        pcmTempFile = File(recDir, "$callUuid.pcm")
        outputM4aFile = File(recDir, "$callUuid.m4a")

        val minBufSize = AudioRecord.getMinBufferSize(SAMPLE_RATE, CHANNEL_CONFIG, AUDIO_FORMAT)
            .coerceAtLeast(8192)

        val recorder: AudioRecord?
        var usedSource = -1
        
        audioRecord = tryCreateAudioRecord(MediaRecorder.AudioSource.VOICE_CALL, minBufSize)
        if (audioRecord != null) {
            usedSource = MediaRecorder.AudioSource.VOICE_CALL
        } else {
            audioRecord = tryCreateAudioRecord(MediaRecorder.AudioSource.VOICE_COMMUNICATION, minBufSize)
            if (audioRecord != null) {
                usedSource = MediaRecorder.AudioSource.VOICE_COMMUNICATION
            } else {
                audioRecord = tryCreateAudioRecord(MediaRecorder.AudioSource.MIC, minBufSize)
                if (audioRecord != null) usedSource = MediaRecorder.AudioSource.MIC
            }
        }
        recorder = audioRecord

        if (recorder == null) {
            Log.e(TAG, "Failed to create AudioRecord")
            stopSelf()
            return
        }

        try {
            recorder.startRecording()
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start recording: ${e.message}")
            stopSelf()
            return
        }

        Log.d(TAG, "Successfully started recording with audio source: $usedSource")
        isRecording = true

        recordingThread = Thread {
            writePcmToFile(recorder, minBufSize)
        }.also { it.start() }
    }

    private fun tryCreateAudioRecord(audioSource: Int, bufSize: Int): AudioRecord? {
        return try {
            val ar = AudioRecord(audioSource, SAMPLE_RATE, CHANNEL_CONFIG, AUDIO_FORMAT, bufSize)
            if (ar.state == AudioRecord.STATE_INITIALIZED) ar else { ar.release(); null }
        } catch (e: Exception) {
            Log.w(TAG, "AudioRecord source $audioSource failed: ${e.message}")
            null
        }
    }

    private fun writePcmToFile(recorder: AudioRecord, bufSize: Int) {
        val buffer = ByteArray(bufSize)
        try {
            FileOutputStream(pcmTempFile).use { fos ->
                while (isRecording) {
                    val read = recorder.read(buffer, 0, buffer.size)
                    if (read > 0) fos.write(buffer, 0, read)
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error writing PCM: ${e.message}")
        }
    }

    private fun stopRecording() {
        isRecording = false
        val endTimestampMs = System.currentTimeMillis()

        val recorder = audioRecord
        recorder?.stop()
        recorder?.release()
        audioRecord = null

        recordingThread?.join(3000)
        recordingThread = null

        val pcm = pcmTempFile ?: return
        val m4a = outputM4aFile ?: return

        // Encode PCM → M4A
        val success = encodePcmToM4a(pcm, m4a)
        
        val finalAudioPath = if (success && m4a.exists()) {
            pcm.delete()
            m4a.absolutePath
        } else {
            Log.e(TAG, "M4A encoding failed, falling back to raw PCM file")
            if (m4a.exists()) m4a.delete()
            pcm.absolutePath
        }

        sendResultToFlutter(
            uuid = callUuid,
            phoneNumber = currentCallNumber,
            direction = callDirection,
            audioPath = finalAudioPath,
            startedAt = startTimestampMs,
            endedAt = endTimestampMs
        )
    }

    // ─────────────────────────────────────────────────────────
    // PCM → M4A encoding via MediaCodec + MediaMuxer
    // ─────────────────────────────────────────────────────────

    private fun encodePcmToM4a(pcmFile: File, m4aFile: File): Boolean {
        if (!pcmFile.exists() || pcmFile.length() == 0L) return false

        return try {
            val format = MediaFormat.createAudioFormat(AAC_MIME, SAMPLE_RATE, 1).apply {
                setInteger(MediaFormat.KEY_AAC_PROFILE, MediaCodecInfo.CodecProfileLevel.AACObjectLC)
                setInteger(MediaFormat.KEY_BIT_RATE, BIT_RATE)
                setInteger(MediaFormat.KEY_MAX_INPUT_SIZE, 16384)
            }

            val codec = MediaCodec.createEncoderByType(AAC_MIME)
            codec.configure(format, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE)
            codec.start()

            val muxer = MediaMuxer(m4aFile.absolutePath, MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4)
            var audioTrackIndex = -1
            var muxerStarted = false

            val bufInfo = MediaCodec.BufferInfo()
            var inputDone = false
            var outputDone = false

            FileInputStream(pcmFile).use { fis ->
                val inputBuffer = ByteArray(8192)

                while (!outputDone) {
                    // Feed input
                    if (!inputDone) {
                        val inputIdx = codec.dequeueInputBuffer(10_000)
                        if (inputIdx >= 0) {
                            val buf = codec.getInputBuffer(inputIdx)!!
                            buf.clear()
                            val read = fis.read(inputBuffer, 0, buf.remaining().coerceAtMost(inputBuffer.size))
                            if (read <= 0) {
                                codec.queueInputBuffer(inputIdx, 0, 0, 0L, MediaCodec.BUFFER_FLAG_END_OF_STREAM)
                                inputDone = true
                            } else {
                                buf.put(inputBuffer, 0, read)
                                val presentationUs = (fis.channel.position() * 1_000_000L) / (SAMPLE_RATE * 2)
                                codec.queueInputBuffer(inputIdx, 0, read, presentationUs, 0)
                            }
                        }
                    }

                    // Drain output
                    val outputIdx = codec.dequeueOutputBuffer(bufInfo, 10_000)
                    when {
                        outputIdx == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED -> {
                            val newFormat = codec.outputFormat
                            audioTrackIndex = muxer.addTrack(newFormat)
                            muxer.start()
                            muxerStarted = true
                        }
                        outputIdx >= 0 -> {
                            val encodedData = codec.getOutputBuffer(outputIdx)!!
                            if (bufInfo.flags and MediaCodec.BUFFER_FLAG_CODEC_CONFIG != 0) {
                                bufInfo.size = 0
                            }
                            if (bufInfo.size > 0 && muxerStarted) {
                                encodedData.position(bufInfo.offset)
                                encodedData.limit(bufInfo.offset + bufInfo.size)
                                muxer.writeSampleData(audioTrackIndex, encodedData, bufInfo)
                            }
                            codec.releaseOutputBuffer(outputIdx, false)
                            if (bufInfo.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) {
                                outputDone = true
                            }
                        }
                    }
                }
            }

            codec.stop()
            codec.release()
            if (muxerStarted) muxer.stop()
            muxer.release()
            true
        } catch (e: Exception) {
            Log.e(TAG, "Encoding error: ${e.message}", e)
            false
        }
    }

    // ─────────────────────────────────────────────────────────
    // Flutter MethodChannel callback (native → Dart)
    // ─────────────────────────────────────────────────────────

    private fun sendResultToFlutter(
        uuid: String,
        phoneNumber: String,
        direction: String,
        audioPath: String,
        startedAt: Long,
        endedAt: Long
    ) {
        val durationSeconds = ((endedAt - startedAt) / 1000).toInt().coerceAtLeast(0)
        val args = mapOf(
            "id" to uuid,
            "phoneNumber" to phoneNumber,
            "direction" to direction,
            "audioPath" to audioPath,
            "startedAt" to startedAt,
            "endedAt" to endedAt,
            "durationSeconds" to durationSeconds
        )

        Log.d(TAG, "Sending onCallRecorded to Flutter: $args")

        // Post on main thread — MethodChannel requires it
        val engine = FlutterEngineCache.getInstance().get(FLUTTER_ENGINE_ID)
        if (engine != null) {
            val channel = MethodChannel(engine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
            android.os.Handler(android.os.Looper.getMainLooper()).post {
                channel.invokeMethod("onCallRecorded", args)
            }
        } else {
            Log.w(TAG, "Flutter engine not found in cache — result will be sent next app launch")
        }
    }

    // ─────────────────────────────────────────────────────────
    // Notification
    // ─────────────────────────────────────────────────────────

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Call Recording",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Shown while Voiceon is recording a call"
                setShowBadge(false)
            }
            val nm = getSystemService(NotificationManager::class.java)
            nm.createNotificationChannel(channel)
        }
    }

    private fun buildNotification(): Notification {
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
                .setContentTitle("Recording call")
                .setContentText("Tap to open Voiceon")
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentIntent(pendingIntent)
                .setOngoing(true)
                .build()
        } else {
            @Suppress("DEPRECATION")
            android.app.Notification.Builder(this)
                .setContentTitle("Recording call")
                .setContentText("Tap to open Voiceon")
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentIntent(pendingIntent)
                .setOngoing(true)
                .build()
        }
    }
}
