package com.ncinga.temi.service

import android.content.ContentResolver
import android.content.ContentValues
import android.content.Context
import android.net.Uri
import android.util.Log
import com.robotemi.sdk.Robot
import com.robotemi.sdk.face.ContactModel
import com.robotemi.sdk.face.OnFaceRecognizedListener
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject

class FaceRecognitionService(
    private val channel: MethodChannel,
    private val robot: Robot,
    private var context: Context
) :
    OnFaceRecognizedListener {
    private var contentResolver: ContentResolver? = null
    private val TAG = "FaceRecognitionService"


    init {
        robot.addOnFaceRecognizedListener(this)
        contentResolver = context.contentResolver;
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
    }
}