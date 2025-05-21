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

class FaceRecognitionService(
    private val channel: MethodChannel,
    private val robot: Robot,
    private var context: Context
) :
    OnFaceRecognizedListener {
    private var contentResolver: ContentResolver? = null
    private val TAG = "ImageRecognitionService"


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

    fun registerFace() {
        val contentValues = ContentValues()
        contentValues.put("test", "abc")
        contentResolver!!.insert(
            Uri.parse("content://com.robotemi.sdk.TemiSdkDocumentContentProvider/face"),
            contentValues
        )

    }


    override fun onFaceRecognized(contactModelList: List<ContactModel>) {

    }

    fun cleanUpRecognized() {
        robot.removeOnFaceRecognizedListener(this)
    }
}