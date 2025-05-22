package com.ncinga.temi.service

import android.content.ContentResolver
import android.content.ContentValues
import android.content.Context
import android.net.Uri
import android.util.Log
import com.robotemi.sdk.Robot
import com.robotemi.sdk.face.ContactModel
import com.robotemi.sdk.face.OnContinuousFaceRecognizedListener
import com.robotemi.sdk.face.OnFaceRecognizedListener
import com.robotemi.sdk.listeners.OnGreetModeStateChangedListener
import com.robotemi.sdk.sequence.OnSequencePlayStatusChangedListener
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject

class FaceRecognitionService(
    private val channel: MethodChannel,
    private val robot: Robot,
    private var context: Context
) :
    OnFaceRecognizedListener, OnContinuousFaceRecognizedListener, OnGreetModeStateChangedListener,
    OnSequencePlayStatusChangedListener {
    private var contentResolver: ContentResolver? = null
    private val TAG = "FaceRecognitionService"


    init {

        robot.addOnFaceRecognizedListener(this)
        robot.addOnContinuousFaceRecognizedListener(this)
        robot.addOnGreetModeStateChangedListener(this)
        robot.addOnSequencePlayStatusChangedListener(this)
        contentResolver = context.contentResolver;
        Log.i(TAG, "FaceRecognitionService -Init")
    }


    fun startFaceRecognition() {
        Log.i(TAG, "startFaceRecognition")
        robot.startFaceRecognition()
    }

    fun stopFaceRecognition() {
        Log.i(TAG, "stopFaceRecognition")
        robot.stopFaceRecognition()
    }

    fun registerFace(fileUri: String, userId: String, username: String) {
        val contentValues = ContentValues()
        contentValues.put("uid", userId)
        contentValues.put("username", username)
        contentValues.put("uri", fileUri)
        contentResolver!!.insert(
            Uri.parse("content://com.robotemi.sdk.TemiSdkDocumentContentProvider/face"),
            contentValues
        )

    }


    override fun onFaceRecognized(contactModelList: List<ContactModel>) {
        Log.i(TAG, "onFaceRecognized: ${contactModelList.size} faces recognized")
        val recognizedFaces = JSONArray()
        for (contact in contactModelList) {
            try {
                val faceData = JSONObject()
                faceData.put("uid", contact.userId)
                faceData.put("firstName", contact.firstName)
                faceData.put("lastName", contact.lastName)
                recognizedFaces.put(faceData)
                val arguments = HashMap<String, Any>()
//                arguments["uid"] = contact.userId
//                arguments["username"] = contact.userId
//                arguments["firstName"] = contact.firstName
//                arguments["lastName"] = contact.lastName
                channel.invokeMethod("onFaceRecognized", arguments)

                Log.i(TAG, "Recognized face: ${contact.userId} (${contact.userId})")
            } catch (e: Exception) {
                Log.e(TAG, "Error processing recognized face: ${e.message}")
                e.printStackTrace()
            }
        }
        if (contactModelList.isNotEmpty()) {
            val arguments = HashMap<String, Any>()
            arguments["faces"] = recognizedFaces.toString()

            channel.invokeMethod("onFacesRecognized", arguments)
        }
    }

    fun cleanUpRecognized() {
        robot.removeOnFaceRecognizedListener(this)
        robot.removeOnContinuousFaceRecognizedListener(this)
        robot.removeOnGreetModeStateChangedListener(this)
        robot.removeOnSequencePlayStatusChangedListener(this)
    }

    override fun onContinuousFaceRecognized(contactModelList: List<ContactModel>) {
        Log.i(TAG, "onContinuousFaceRecognized: ${contactModelList.size} faces recognized")
    }

    override fun onGreetModeStateChanged(state: Int) {
        Log.i(TAG, "onGreetModeStateChanged: $state}")
    }

    override fun onSequencePlayStatusChanged(status: Int) {
        Log.i(TAG, "onSequencePlayStatusChanged: $status}")
    }
}