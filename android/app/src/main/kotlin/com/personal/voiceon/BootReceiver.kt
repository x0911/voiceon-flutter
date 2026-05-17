package com.personal.voiceon

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class BootReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "BootReceiver"
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            Log.d(TAG, "Boot completed — Voiceon call detector is active via manifest registration")

            // Re-read shared preferences to confirm recording state
            val prefs = context.getSharedPreferences("voiceon_prefs", Context.MODE_PRIVATE)
            val isEnabled = prefs.getBoolean("call_recording_enabled", false)
            Log.d(TAG, "Call recording enabled: $isEnabled")
        }
    }
}
