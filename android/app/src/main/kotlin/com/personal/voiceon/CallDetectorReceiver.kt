package com.personal.voiceon

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.telephony.TelephonyManager
import android.util.Log

class CallDetectorReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "CallDetectorReceiver"
    }

    override fun onReceive(context: Context, intent: Intent) {
        // Only process if call recording is enabled
        val prefs = context.getSharedPreferences("voiceon_prefs", Context.MODE_PRIVATE)
        if (!prefs.getBoolean("call_recording_enabled", false)) {
            return
        }

        when (intent.action) {
            TelephonyManager.ACTION_PHONE_STATE_CHANGED -> {
                val state = intent.getStringExtra(TelephonyManager.EXTRA_STATE)
                val number = intent.getStringExtra(TelephonyManager.EXTRA_INCOMING_NUMBER) ?: ""
                Log.d(TAG, "Phone state changed: $state, number: $number")

                when (state) {
                    TelephonyManager.EXTRA_STATE_OFFHOOK -> {
                        // Call connected — start recording
                        // If there's a pending outgoing number, this is an outgoing call
                        val pendingOutgoing = CallRecordingService.pendingOutgoingNumber
                        if (pendingOutgoing != null) {
                            CallRecordingService.start(context, pendingOutgoing, "outgoing")
                        } else {
                            CallRecordingService.start(context, number, "incoming")
                        }
                    }
                    TelephonyManager.EXTRA_STATE_IDLE -> {
                        // Call ended — stop recording
                        CallRecordingService.stop(context)
                    }
                }
            }
            @Suppress("DEPRECATION")
            Intent.ACTION_NEW_OUTGOING_CALL -> {
                val number = intent.getStringExtra(Intent.EXTRA_PHONE_NUMBER) ?: ""
                Log.d(TAG, "Outgoing call detected: $number")
                // Store number for when OFFHOOK fires
                CallRecordingService.pendingOutgoingNumber = number
            }
        }
    }
}
