package com.ncinga.temi.service

import android.util.Log
import com.robotemi.sdk.Robot
import com.robotemi.sdk.listeners.OnDetectionStateChangedListener
import com.robotemi.sdk.listeners.OnGoToLocationStatusChangedListener
import com.robotemi.sdk.listeners.OnRobotReadyListener
import com.robotemi.sdk.listeners.OnUserInteractionChangedListener
import io.flutter.plugin.common.MethodChannel

class DetectionService(private val channel: MethodChannel, private val robot: Robot) :
    OnRobotReadyListener,
    OnUserInteractionChangedListener, OnDetectionStateChangedListener,
    OnGoToLocationStatusChangedListener {
    private val TAG = "DetectionService"

    init {
        robot.addOnRobotReadyListener(this)
        robot.addOnUserInteractionChangedListener(this)
        robot.addOnDetectionStateChangedListener(this)
        robot.addOnGoToLocationStatusChangedListener(this)

        Log.i(
            TAG,
            "Temi is listing this listener (addOnRobotReadyListener, addOnUserInteractionChangedListener, addOnGoToLocationStatusChangedListener, addOnGoToLocationStatusChangedListener)"
        )


    }


    override fun onRobotReady(isReady: Boolean) {
        channel.invokeMethod("onRobotReady", mapOf("isReady" to isReady))
    }

    override fun onUserInteraction(isInteracting: Boolean) {
        channel.invokeMethod("onUserInteraction", mapOf("isInteracting" to isInteracting))
    }

    override fun onDetectionStateChanged(state: Int) {
        channel.invokeMethod("onDetectionStateChanged", mapOf("state" to state))
    }

    override fun onGoToLocationStatusChanged(
        location: String,
        status: String,
        descriptionId: Int,
        description: String
    ) {
        channel.invokeMethod(
            "onGoToLocationStatusChanged", mapOf(
                "location" to location,
                "status" to status,
                "descriptionId" to descriptionId,
                "description" to description
            )
        )
    }


    fun cleanupDetectionLister() {
        robot.removeOnRobotReadyListener(this)
        robot.removeOnUserInteractionChangedListener(this)
        robot.removeOnDetectionStateChangedListener(this)
        robot.removeOnGoToLocationStatusChangedListener(this)
    }

}