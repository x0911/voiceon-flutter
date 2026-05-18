package com.personal.voiceon

import android.content.Context
import android.media.MediaMetadataRetriever
import android.net.Uri
import androidx.documentfile.provider.DocumentFile
import java.io.File
import java.io.FileOutputStream
import java.util.UUID

object CallFileImporter {

    private val AUDIO_EXTENSIONS = setOf("mp3", "m4a", "amr", "aac", "ogg", "wav", "3gp")

    /**
     * Scans the configured folder for any audio file created after [callStartedAt].
     * Returns the newest such file, or null if none found.
     */
    fun findNewRecordingFile(
        context: Context,
        folderUriString: String,
        callStartedAt: Long
    ): DocumentFile? {
        val folderUri = Uri.parse(folderUriString)
        val folder = DocumentFile.fromTreeUri(context, folderUri) ?: return null

        return folder.listFiles()
            .filter { file ->
                val ext = file.name?.substringAfterLast('.')?.lowercase() ?: ""
                file.isFile &&
                ext in AUDIO_EXTENSIONS &&
                file.lastModified() >= callStartedAt - 5000 // 5s buffer for clock skew
            }
            .maxByOrNull { it.lastModified() } // pick the most recent
    }

    /**
     * Copies the recording to app storage, reads metadata, returns a map
     * ready to send to Flutter via MethodChannel.
     */
    fun importFile(
        context: Context,
        file: DocumentFile,
        phoneNumber: String,
        direction: String,
        startedAt: Long,
        endedAt: Long
    ): Map<String, Any>? {
        return try {
            val ext = file.name?.substringAfterLast('.') ?: "m4a"
            val uuid = UUID.randomUUID().toString()
            val destDir = File(context.filesDir, "call_recordings").apply { mkdirs() }
            val destFile = File(destDir, "$uuid.$ext")

            // Copy file
            context.contentResolver.openInputStream(file.uri)?.use { input ->
                FileOutputStream(destFile).use { output ->
                    input.copyTo(output)
                }
            } ?: return null

            // Read duration via MediaMetadataRetriever
            val retriever = MediaMetadataRetriever()
            var durationSeconds = 0
            try {
                retriever.setDataSource(destFile.absolutePath)
                val durationMs = retriever.extractMetadata(
                    MediaMetadataRetriever.METADATA_KEY_DURATION
                )?.toLongOrNull() ?: 0L
                durationSeconds = (durationMs / 1000).toInt()
            } catch (_: Exception) {
            } finally {
                retriever.release()
            }

            mapOf(
                "id" to uuid,
                "phoneNumber" to phoneNumber,
                "direction" to direction,
                "audioPath" to destFile.absolutePath,
                "fileSizeBytes" to destFile.length(),
                "fileExtension" to ext,
                "startedAt" to startedAt,
                "endedAt" to endedAt,
                "durationSeconds" to durationSeconds
            )
        } catch (e: Exception) {
            null
        }
    }
}
