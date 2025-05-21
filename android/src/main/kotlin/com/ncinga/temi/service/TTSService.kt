package com.ncinga.temi.service

import android.util.Log
import com.robotemi.sdk.Robot
import com.robotemi.sdk.TtsRequest
import io.flutter.plugin.common.MethodChannel

class TTSService(private val channel: MethodChannel, private val robot: Robot) : Robot.TtsListener {
    private val TAG = "TTSService"
       init {
        robot.addTtsListener(this)
    }

    override fun onTtsStatusChanged(ttsRequest: TtsRequest) {
        channel.invokeMethod(
            "onTtsStatusChanged", mapOf(
                "id" to ttsRequest.toString(),
                "text" to ttsRequest.speech,
                "status" to ttsRequest.status.toString()
            )
        )
    }

    fun speak(text: String) {
        val ttsRequest = TtsRequest.create(text, false)
        Log.i(TAG, "speech : ${text}")
        robot.speak(ttsRequest)
    }

    fun cleanupTTSService() {
        robot.removeTtsListener(this)
    }
}