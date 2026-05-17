package com.personal.voiceon

import android.content.Context
import android.media.AudioManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val audioChannelName = "voiceon/audio"
    private val callsChannelName = "voiceon/calls"

    // Kept as a field so CallRecordingService can send events back to Dart
    lateinit var callsMethodChannel: MethodChannel
        private set

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Cache the engine so CallRecordingService can look it up when the app
        // is open (service sends events via this cached engine reference)
        FlutterEngineCache.getInstance().put("main_engine", flutterEngine)

        // ── Audio channel (existing) ──────────────────────────────────────────
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, audioChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "muteBeep" -> {
                        muteBeep()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }

        // ── Calls channel (new) ───────────────────────────────────────────────
        callsMethodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            callsChannelName
        )
        callsMethodChannel.setMethodCallHandler { call, result ->
            val prefs = getSharedPreferences("voiceon_prefs", Context.MODE_PRIVATE)
            when (call.method) {
                "isCallRecordingEnabled" -> {
                    val enabled = prefs.getBoolean("call_recording_enabled", false)
                    result.success(enabled)
                }
                "setCallRecordingEnabled" -> {
                    val enabled = call.arguments as? Boolean ?: false
                    prefs.edit().putBoolean("call_recording_enabled", enabled).apply()
                    result.success(null)
                }
                "getContactName" -> {
                    val phoneNumber = call.arguments as? String ?: ""
                    val name = ContactResolver.getContactName(this, phoneNumber)
                    result.success(name)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        // Remove cached engine reference to avoid memory leaks when activity
        // is truly destroyed (e.g. app cleared from recents)
        FlutterEngineCache.getInstance().remove("main_engine")
        super.onDestroy()
    }

    private fun muteBeep() {
        val audioManager = getSystemService(Context.AUDIO_SERVICE) as? AudioManager ?: return
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            audioManager.adjustStreamVolume(AudioManager.STREAM_NOTIFICATION, AudioManager.ADJUST_MUTE, 0)
            audioManager.adjustStreamVolume(AudioManager.STREAM_SYSTEM, AudioManager.ADJUST_MUTE, 0)
            audioManager.adjustStreamVolume(AudioManager.STREAM_MUSIC, AudioManager.ADJUST_MUTE, 0)
            Handler(Looper.getMainLooper()).postDelayed({
                audioManager.adjustStreamVolume(AudioManager.STREAM_NOTIFICATION, AudioManager.ADJUST_UNMUTE, 0)
                audioManager.adjustStreamVolume(AudioManager.STREAM_SYSTEM, AudioManager.ADJUST_UNMUTE, 0)
                audioManager.adjustStreamVolume(AudioManager.STREAM_MUSIC, AudioManager.ADJUST_UNMUTE, 0)
            }, 500)
        }
    }
}
