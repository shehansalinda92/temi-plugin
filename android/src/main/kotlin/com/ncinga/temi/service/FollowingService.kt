package com.ncinga.temi.service

import com.robotemi.sdk.Robot
import com.robotemi.sdk.listeners.OnBeWithMeStatusChangedListener
import io.flutter.plugin.common.MethodChannel

class FollowingService(private val channel: MethodChannel, private val robot: Robot) :
    OnBeWithMeStatusChangedListener {
    private val TAG = "FollowService"

    init {
        robot.addOnBeWithMeStatusChangedListener(this)
    }

    override fun onBeWithMeStatusChanged(status: String) {
        channel.invokeMethod("onBeWithMeStatusChanged", mapOf("status" to status))
    }

    fun cleanupFollowingService() {
        robot.removeOnBeWithMeStatusChangedListener(this)
    }
}