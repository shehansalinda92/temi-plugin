package com.ncinga.temi.service

import android.util.Log
import com.robotemi.sdk.Robot
import com.robotemi.sdk.listeners.OnGoToLocationStatusChangedListener
import com.robotemi.sdk.navigation.listener.OnCurrentPositionChangedListener
import com.robotemi.sdk.navigation.model.Position
import io.flutter.plugin.common.MethodChannel

class NavigationMapService(
    private val channel: MethodChannel,
    private val robot: Robot
) : OnGoToLocationStatusChangedListener, OnCurrentPositionChangedListener {

    private val TAG = "NavigationMapService"

    init {
        robot.addOnGoToLocationStatusChangedListener(this)
        robot.addOnCurrentPositionChangedListener(this)
    }

    fun getLocations(): List<String> {
        Log.i(TAG, "getLocations")
        return try {
            robot.locations
        } catch (e: Exception) {
            Log.e(TAG, "Error in getLocations: ${e.message}")
            emptyList()
        }
    }

    fun goToLocation(location: String): Boolean {
        Log.i(TAG, "goTo: $location")
        return try {
            robot.goTo(location)
            true
        } catch (e: Exception) {
            Log.e(TAG, "Error in goTo: ${e.message}")
            false
        }
    }

    fun saveLocation(name: String): Boolean {
        Log.i(TAG, "saveLocation: $name")
        return try {
            robot.saveLocation(name)
            true
        } catch (e: Exception) {
            Log.e(TAG, "Error in saveLocation: ${e.message}")
            false
        }
    }

    fun deleteLocation(name: String): Boolean {
        Log.i(TAG, "deleteLocation: $name")
        return try {
            robot.deleteLocation(name)
            true
        } catch (e: Exception) {
            Log.e(TAG, "Error in deleteLocation: ${e.message}")
            false
        }
    }

    override fun onGoToLocationStatusChanged(
        location: String,
        status: String,
        descriptionId: Int,
        description: String
    ) {
        Log.i(TAG, "onGoToLocationStatusChanged: $location, $status, $descriptionId, $description")

        channel.invokeMethod(
            "onGoToLocationStatusChanged", mapOf(
                "location" to location,
                "status" to status,
                "descriptionId" to descriptionId,
                "description" to description
            )
        )
    }

    override fun onCurrentPositionChanged(position: Position) {
        Log.i(TAG, "onCurrentPositionChanged: ${position.x}, ${position.y}, ${position.yaw}")
        channel.invokeMethod(
            "onCurrentPositionChanged", mapOf(
                "x" to position.x,
                "y" to position.y,
                "yaw" to position.yaw
            )
        )
    }

    fun cleanupNavigationMap() {
        robot.removeOnGoToLocationStatusChangedListener(this)
        robot.removeOnCurrentPositionChangedListener(this)
    }
}