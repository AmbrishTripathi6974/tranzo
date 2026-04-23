package com.example.tranzo

import android.content.ContentValues
import android.media.MediaScannerConnection
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.net.URLConnection
import android.webkit.MimeTypeMap

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "tranzo/received_files",
        ).setMethodCallHandler { call, result ->
            if (call.method != "store_in_downloads") {
                result.notImplemented()
                return@setMethodCallHandler
            }

            val sourcePath = call.argument<String>("sourcePath")
            val fileName = call.argument<String>("fileName")
            if (sourcePath.isNullOrBlank() || fileName.isNullOrBlank()) {
                result.error("invalid_args", "sourcePath and fileName are required", null)
                return@setMethodCallHandler
            }

            try {
                val sourceFile = File(sourcePath)
                val mimeType = resolveMimeType(fileName)
                val relativePath = "${Environment.DIRECTORY_DOWNLOADS}/Tranzo"
                var legacyAbsolutePath: String? = null
                val uri = contentResolver.insert(
                    MediaStore.Downloads.EXTERNAL_CONTENT_URI,
                    ContentValues().apply {
                        put(MediaStore.Downloads.DISPLAY_NAME, fileName)
                        put(MediaStore.Downloads.MIME_TYPE, mimeType)
                        put(MediaStore.Downloads.SIZE, sourceFile.length())
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                            put(MediaStore.Downloads.RELATIVE_PATH, relativePath)
                        } else {
                            val legacyDir = File(
                                Environment.getExternalStoragePublicDirectory(
                                    Environment.DIRECTORY_DOWNLOADS,
                                ),
                                "Tranzo",
                            )
                            legacyDir.mkdirs()
                            put(
                                MediaStore.Downloads.DATA,
                                File(legacyDir, fileName).absolutePath,
                            )
                            legacyAbsolutePath = File(legacyDir, fileName).absolutePath
                        }
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                            put(MediaStore.Downloads.IS_PENDING, 1)
                        }
                    },
                )

                if (uri == null) {
                    result.success(false)
                    return@setMethodCallHandler
                }

                contentResolver.openOutputStream(uri)?.use { output ->
                    FileInputStream(sourceFile).use { input ->
                        input.copyTo(output)
                    }
                } ?: run {
                    contentResolver.delete(uri, null, null)
                    result.success(false)
                    return@setMethodCallHandler
                }

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    contentResolver.update(
                        uri,
                        ContentValues().apply { put(MediaStore.Downloads.IS_PENDING, 0) },
                        null,
                        null,
                    )
                }

                if (!legacyAbsolutePath.isNullOrBlank()) {
                    MediaScannerConnection.scanFile(
                        this,
                        arrayOf(legacyAbsolutePath),
                        arrayOf(mimeType),
                        null,
                    )
                }
                result.success(true)
            } catch (_: Exception) {
                result.success(false)
            }
        }
    }

    private fun resolveMimeType(fileName: String): String {
        val extension = fileName.substringAfterLast('.', "").lowercase()
        if (extension.isNotEmpty()) {
            val mapped = MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension)
            if (!mapped.isNullOrBlank()) {
                return mapped
            }
        }
        val guessed = URLConnection.guessContentTypeFromName(fileName)
        if (!guessed.isNullOrBlank()) {
            return guessed
        }
        return "application/octet-stream"
    }
}
