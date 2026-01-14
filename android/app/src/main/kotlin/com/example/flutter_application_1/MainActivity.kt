package com.example.flutter_application_1

import android.content.ContentValues
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val channelName = "oneapp/files"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "saveToDownloads" -> {
                        val name = call.argument<String>("name")
                        val bytes = call.argument<ByteArray>("bytes")
                        val mime = call.argument<String>("mime")
                            ?: "application/octet-stream"
                        if (name == null || bytes == null) {
                            result.error("ARGUMENT_ERROR", "Missing name or bytes", null)
                            return@setMethodCallHandler
                        }
                        try {
                            val location = saveBytesToDownloads(name, bytes, mime)
                            result.success(location)
                        } catch (e: Exception) {
                            result.error("SAVE_ERROR", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun saveBytesToDownloads(name: String, bytes: ByteArray, mime: String): String {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val contentValues = ContentValues().apply {
                put(MediaStore.Downloads.DISPLAY_NAME, name)
                put(MediaStore.Downloads.MIME_TYPE, mime)
                put(MediaStore.Downloads.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS)
            }
            val resolver = applicationContext.contentResolver
            val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, contentValues)
                ?: throw IllegalStateException("Failed to create download entry")
            resolver.openOutputStream(uri)?.use { output ->
                output.write(bytes)
                output.flush()
            } ?: throw IllegalStateException("Failed to open output stream")
            uri.toString()
        } else {
            val dir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
            if (!dir.exists()) dir.mkdirs()
            val file = File(dir, name)
            FileOutputStream(file).use { output ->
                output.write(bytes)
                output.flush()
            }
            file.absolutePath
        }
    }
}
