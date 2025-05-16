package com.ncinga.temi

import android.app.Activity
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import com.robotemi.sdk.Robot
import com.ncinga.temi.service.RobotMovementService

class TemiPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var robot: Robot? = null
    private var movementService: RobotMovementService? = null
    private val TAG = "TEMI"

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        Log.d(TAG, "onAttachedToEngine called")
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "temi")
        channel.setMethodCallHandler(this)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        Log.d(TAG, "onAttachedToActivity called")
        activity = binding.activity
        initializeRobot()
    }

    private fun initializeRobot() {
        try {
            robot = Robot.getInstance()
            robot?.let {
                movementService = RobotMovementService(it)
                Log.i(TAG, "Robot and movement service initialized")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to initialize robot: ${e.message}")
            e.printStackTrace()
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        Log.d(TAG, "onMethodCall: ${call.method}")

        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }

            "skidJoy" -> {
                handleSkidJoy(call, result)
            }

            else -> {
                Log.w(TAG, "Method not implemented: ${call.method}")
                result.notImplemented()
            }
        }
    }

    private fun handleSkidJoy(call: MethodCall, result: Result) {
        Log.d(TAG, "handleSkidJoy called")

        val x = call.argument<Double>("x")?.toFloat()
        val y = call.argument<Double>("y")?.toFloat()
        val smart = call.argument<Boolean>("smart")

        Log.d(TAG, "skidJoy parameters - x: $x, y: $y, smart: $smart")

        if (x == null || y == null || smart == null) {
            result.error("INVALID_ARGUMENTS", "x, y, and smart parameters are required", null)
            return
        }

        if (movementService == null) {
            Log.e(TAG, "Movement service is null, attempting to initialize")
            initializeRobot()

            if (movementService == null) {
                result.error(
                    "ROBOT_NOT_INITIALIZED",
                    "Robot movement service is not initialized",
                    null
                )
                return
            }
        }

        try {
            movementService?.skidJoy(x, y, smart)
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Error in skidJoy: ${e.message}")
            result.error("MOVEMENT_ERROR", "Failed to execute skidJoy: ${e.message}", null)
        }
    }


    override fun onDetachedFromActivity() {
        Log.d(TAG, "onDetachedFromActivity called")
        activity = null
        robot = null
        movementService = null
    }

    override fun onDetachedFromActivityForConfigChanges() {
        Log.d(TAG, "onDetachedFromActivityForConfigChanges called")
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        Log.d(TAG, "onReattachedToActivityForConfigChanges called")
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d(TAG, "onDetachedFromEngine called")
        channel.setMethodCallHandler(null)
    }
}