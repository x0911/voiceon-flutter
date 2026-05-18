package com.personal.voiceon

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.media.AudioManager
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel
import androidx.documentfile.provider.DocumentFile
import java.io.File

class MainActivity : FlutterActivity() {

    private val audioChannelName = "voiceon/audio"
    private val callsChannelName = "voiceon/calls"

    companion object {
        private const val REQUEST_FOLDER_PICK = 7001
    }

    // Kept as a field so CallRecordingService can send events back to Dart
    lateinit var callsMethodChannel: MethodChannel
        private set

    private var pendingFolderResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Cache the engine so CallImportService can look it up when the app
        // is open (service sends events via this cached engine reference)
        FlutterEngineCache.getInstance().put("main_engine", flutterEngine)
        VoiceonMethodChannel.register(flutterEngine)

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
        VoiceonMethodChannel.setMethodCallHandler { call, result ->
            val prefs = getSharedPreferences("voiceon_prefs", Context.MODE_PRIVATE)
            when (call.method) {
                "isCallVaultEnabled" -> {
                    val enabled = prefs.getBoolean("call_vault_enabled", false)
                    result.success(enabled)
                }
                "setCallVaultEnabled" -> {
                    val enabled = call.arguments as? Boolean ?: false
                    prefs.edit().putBoolean("call_vault_enabled", enabled).apply()
                    if (enabled && !prefs.contains("call_vault_enabled_since_ms")) {
                        prefs.edit().putLong("call_vault_enabled_since_ms", System.currentTimeMillis()).apply()
                    }
                    result.success(null)
                }
                "getCallVaultEnabledSinceMs" -> {
                    if (prefs.contains("call_vault_enabled_since_ms")) {
                        result.success(prefs.getLong("call_vault_enabled_since_ms", 0L))
                    } else {
                        result.success(null)
                    }
                }
                "getCallVaultFolderUri" -> {
                    val uri = prefs.getString("call_vault_folder_uri", null)
                    result.success(uri)
                }
                "setCallVaultFolderUri" -> {
                    val uri = call.arguments as? String
                    if (uri != null) {
                        prefs.edit().putString("call_vault_folder_uri", uri).apply()
                    } else {
                        prefs.edit().remove("call_vault_folder_uri").apply()
                    }
                    result.success(null)
                }
                "getContactName" -> {
                    val phoneNumber = call.arguments as? String ?: ""
                    val name = ContactResolver.getContactName(this, phoneNumber)
                    result.success(name)
                }
                "pickCallVaultFolder" -> {
                    pendingFolderResult = result
                    val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
                        addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION or
                                 Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION)
                    }
                    startActivityForResult(intent, REQUEST_FOLDER_PICK)
                    // Result will be sent in onActivityResult
                }
                "listCallVaultFiles" -> {
                    val args = call.arguments as Map<*, *>
                    val folderUriStr = args["folderUri"] as? String ?: run { result.success(emptyList<Any>()); return@setMethodCallHandler }
                    val enabledSinceMs = (args["enabledSinceMs"] as? Number)?.toLong() ?: 0L
                    val nowMs = System.currentTimeMillis()
                    val bufferMs = 5_000L // ignore files modified in the last 5 seconds

                    try {
                        val folderUri = Uri.parse(folderUriStr)
                        val folder = DocumentFile.fromTreeUri(this@MainActivity, folderUri)
                        val audioExtensions = setOf("mp3", "m4a", "amr", "aac", "ogg", "wav", "3gp")

                        val files = folder?.listFiles()
                            ?.filter { file ->
                                val ext = file.name?.substringAfterLast('.')?.lowercase() ?: ""
                                file.isFile &&
                                ext in audioExtensions &&
                                file.lastModified() >= enabledSinceMs &&
                                file.lastModified() < nowMs - bufferMs &&
                                file.length() > 0
                            }
                            ?.map { file ->
                                mapOf(
                                    "uri" to file.uri.toString(),
                                    "name" to (file.name ?: ""),
                                    "lastModifiedMs" to file.lastModified(),
                                    "sizeBytes" to file.length()
                                )
                            }
                            ?: emptyList()

                        result.success(files)
                    } catch (e: Exception) {
                        result.error("LIST_ERROR", e.message, null)
                    }
                }
                "copyCallVaultFile" -> {
                    val args = call.arguments as Map<*, *>
                    val sourceUriStr = args["sourceUri"] as? String ?: run { result.error("NO_URI", "No URI", null); return@setMethodCallHandler }

                    try {
                        val sourceUri = Uri.parse(sourceUriStr)
                        val sourceDoc = DocumentFile.fromSingleUri(this@MainActivity, sourceUri)
                        val ext = sourceDoc?.name?.substringAfterLast('.')?.lowercase() ?: "m4a"
                        val uuid = java.util.UUID.randomUUID().toString()

                        val destDir = File(filesDir, "call_vault").apply { mkdirs() }
                        val destFile = File(destDir, "$uuid.$ext")

                        contentResolver.openInputStream(sourceUri)?.use { input ->
                            destFile.outputStream().use { output ->
                                input.copyTo(output)
                            }
                        } ?: throw Exception("Cannot open input stream")

                        // Read duration
                        val retriever = android.media.MediaMetadataRetriever()
                        var durationSeconds = 0
                        try {
                            retriever.setDataSource(destFile.absolutePath)
                            val durationMs = retriever.extractMetadata(
                                android.media.MediaMetadataRetriever.METADATA_KEY_DURATION
                            )?.toLongOrNull() ?: 0L
                            durationSeconds = (durationMs / 1000).toInt()
                        } finally {
                            retriever.release()
                        }

                        result.success(mapOf(
                            "id" to uuid,
                            "destPath" to destFile.absolutePath,
                            "extension" to ext,
                            "durationSeconds" to durationSeconds
                        ))
                    } catch (e: Exception) {
                        result.error("COPY_ERROR", e.message, null)
                    }
                }
                "autoDetectRecordingsFolder" -> {
                    val candidates = listOf(
                        // ── Samsung ──────────────────────────────────────────────────────
                        "Recordings/Call",
                        "Call recordings",
                        "Recordings",
                        "Samsung/Call Recordings",

                        // ── Xiaomi / MIUI / HyperOS ──────────────────────────────────────
                        "MIUI/sound_recorder/call_rec",
                        "recordings/call",
                        "Sounds/callrecord",
                        "Record/Call",

                        // ── Oppo / ColorOS ───────────────────────────────────────────────
                        "ColorOS/PhoneRecord",
                        "Recordings/PhoneRecord",
                        "OPPO/PhoneRecord",

                        // ── Vivo / Funtouch OS / OriginOS ──────────────────────────────────
                        "record/callrecord",
                        "Recordings/CallRecord",
                        "vivo/call",

                        // ── Realme / Realme UI ─────────────────────────────────────────────
                        "Recordings/Call",
                        "realme/PhoneRecord",

                        // ── Huawei / Honor / EMUI ─────────────────────────────────────────
                        "Sounds/callrecord",
                        "PhoneRecord",
                        "Recordings/PhoneRecord",
                        "CallRecording",

                        // ── OnePlus / OxygenOS / ColorOS ─────────────────────────────────
                        "CallRecordings",
                        "Recordings/Call",

                        // ── Nokia / HMD (Android One/stock-ish) ──────────────────────────
                        "PhoneRecord",
                        "Recordings",

                        // ── Motorola (near-stock Android) ────────────────────────────────
                        "Recordings",
                        "Call Recordings",

                        // ── Sony Xperia ──────────────────────────────────────────────────
                        "Sounds/callrecord",
                        "PhoneRecord",

                        // ── Google Pixel (Google Phone app) ──────────────────────────────
                        "Recordings",

                        // ── LG (legacy, no longer made but users exist) ──────────────────
                        "LG/Call",
                        "PhoneRecord",

                        // ── Generic / Unknown ─────────────────────────────────────────────
                        "PhoneRecord",
                        "CallRecords",
                        "call_recordings",
                        "call_records",
                    )

                    val externalStorage = android.os.Environment.getExternalStorageDirectory()

                    val found = candidates
                        .distinctBy { it.lowercase() }
                        .firstOrNull { relativePath ->
                            val dir = java.io.File(externalStorage, relativePath)
                            dir.exists() && dir.isDirectory
                        }

                    if (found != null) {
                        val dir = java.io.File(externalStorage, found)
                        result.success(dir.absolutePath)
                    } else {
                        result.success(null)
                    }
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

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_FOLDER_PICK) {
            if (resultCode == Activity.RESULT_OK && data?.data != null) {
                val uri = data.data!!
                contentResolver.takePersistableUriPermission(
                    uri,
                    Intent.FLAG_GRANT_READ_URI_PERMISSION
                )
                val uriString = uri.toString()
                // Also persist it immediately in SharedPreferences
                getSharedPreferences("voiceon_prefs", Context.MODE_PRIVATE)
                    .edit().putString("call_vault_folder_uri", uriString).apply()
                pendingFolderResult?.success(uriString)
            } else {
                pendingFolderResult?.success(null)
            }
            pendingFolderResult = null
        }
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
