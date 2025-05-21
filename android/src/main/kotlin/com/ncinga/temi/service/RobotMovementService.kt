package com.ncinga.temi.service

import android.util.Log
import com.robotemi.sdk.Robot


class RobotMovementService(private val robot: Robot) {
    private val TAG = "TEMI";
    fun skidJoy(x: Float, y: Float, smart: Boolean) {
        Log.i(TAG, "Move Start  x:${x}, y:${y} smart:${smart}")
        robot.skidJoy(x, y, smart)
        Log.i(TAG, "Movement complected")
    }



}