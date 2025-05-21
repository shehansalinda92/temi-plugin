package com.ncinga.temi

import android.app.Activity
import android.content.Context
import android.util.Log
import com.ncinga.temi.service.DetectionService
import com.ncinga.temi.service.FaceRecognitionService
import com.ncinga.temi.service.FollowingService
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import com.robotemi.sdk.Robot
import com.ncinga.temi.service.RobotMovementService
import com.ncinga.temi.service.TTSService
import com.robotemi.sdk.constants.HomeScreenMode


class TemiPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var robot: Robot? = null
    private var movementService: RobotMovementService? = null
    private var detectionService: DetectionService? = null
    private var ttsService: TTSService? = null
    private var followingService: FollowingService? = null
    private var faceRecognitionService: FaceRecognitionService? = null
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
                detectionService = DetectionService(channel, it)
                ttsService = TTSService(channel, it)
                followingService = FollowingService(channel, it)
                faceRecognitionService =
                    FaceRecognitionService(channel, it, activity!!.applicationContext)
                robot?.requestToBeKioskApp()
                robot?.setKioskModeOn(true, HomeScreenMode.APPLICATION)
                Log.i(TAG, "service initialized")

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

            "startDetectionListening" -> {
                handlingStartDetectionListening(call, result)
            }

            "stopDetectionListening" -> {
                handlingStopDetectionListening(call, result)
            }

            "startSpeakListening" -> {
                handlingStartSpeakListening(call, result)
            }

            "stopSpeakListening" -> {
                handlingStopSpeakListening(call, result)
            }

            "speak" -> {
                handleSpeak(call, result)
            }

            "registerFace" -> {
                handleRegisterFace(call, result)
            }

            "startFaceRecognition" -> {
                handlingStartFaceRecognition(call, result)
            }

            "stopFaceRecognition" -> {
                handlingStopFaceRecognition(call, result)
            }


            else -> {
                Log.w(TAG, "Method not implemented: ${call.method}")
                result.notImplemented()
            }
        }
    }

    private fun handlingStartSpeakListening(call: MethodCall, result: Result) {
        try {
            result.success("Start Speak Listening start")
            result.success(true)
        } catch (e: Exception) {
            result.error("START_SPEAK_LISTING", e.message, e.stackTraceToString())
        }
    }

    private fun handlingStopSpeakListening(call: MethodCall, result: Result) {
        try {
            result.success("Listening stopped")
            ttsService?.cleanupTTSService()
            result.success(true)
        } catch (e: Exception) {
            result.error("STOP_SPEAK_LISTING", e.message, e.stackTraceToString())
        }
    }


    private fun handlingStartDetectionListening(call: MethodCall, result: Result) {
        try {
            result.success("Start Detection Listening start")
            result.success(true)
        } catch (e: Exception) {
            result.error("START_DETECTION_LISTING", e.message, e.stackTraceToString())
        }
    }

    private fun handlingStopDetectionListening(call: MethodCall, result: Result) {
        try {
            detectionService?.cleanupDetectionLister()
            result.success(true)
            result.success("Stop Detection Listening start")
        } catch (e: Exception) {
            result.error("STOP_DETECTION_LISTING", e.message, e.stackTraceToString())
        }
    }

    private fun handlingStartFaceRecognition(call: MethodCall, result: Result) {
        try {
            faceRecognitionService!!.startFaceRecognition();
            result.success(true)
        } catch (e: Exception) {
            result.error("START_FACE_RECOGNITION", e.message, e.stackTraceToString())
        }
    }

    private fun handlingStopFaceRecognition(call: MethodCall, result: Result) {
        try {
            faceRecognitionService!!.stopFaceRecognition();
            result.success(true)
        } catch (e: Exception) {
            result.error("STOP_FACE_RECOGNITION", e.message, e.stackTraceToString())
        }
    }

    private fun handleRegisterFace(call: MethodCall, result: Result) {
        val fileUri = call.argument<String>("fileUri")
        val userId = call.argument<String>("userId")
        val username = call.argument<String>("username")
        if (fileUri == null || userId == null || username == null) {
            result.error("INVALID_ARGUMENTS", "Missing required arguments", null)
            return
        }
        try {
            faceRecognitionService!!.registerFace(fileUri, userId, username)
            result.success(true)
        } catch (e: Exception) {
            result.error("REGISTRATION_ERROR", e.message, e.stackTraceToString())
        }
    }

    private fun handleSpeak(call: MethodCall, result: Result) {
        val text = call.argument<String>("text")
        if (text != null) ttsService?.speak(text)

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
                    "ROBOT_NOT_INITIALIZED", "Robot movement service is not initialized", null
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
        detectionService?.cleanupDetectionLister()
    }
}