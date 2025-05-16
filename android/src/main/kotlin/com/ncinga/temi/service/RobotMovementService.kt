package com.ncinga.temi.service

import android.util.Log
import com.robotemi.sdk.Robot

interface RobotMovement {
    fun skidJoy(x: Float, y: Float, smart: Boolean)
}

class RobotMovementService(private val robot: Robot) : RobotMovement {
    private val TAG = "TEMI";

    override fun skidJoy(x: Float, y: Float, smart: Boolean) {
        Log.i(TAG, "Move Start  x:${x}, y:${y} smart:${smart}")
        robot.skidJoy(x, y, smart)
        Log.i(TAG, "Movement complected")
    }



}