package com.personal.voiceon

import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

object VoiceonMethodChannel {
    private var channel: MethodChannel? = null

    fun register(flutterEngine: FlutterEngine) {
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "voiceon/calls")
    }

    fun setMethodCallHandler(handler: MethodChannel.MethodCallHandler) {
        channel?.setMethodCallHandler(handler)
    }
}
