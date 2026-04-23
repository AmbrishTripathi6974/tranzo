package com.example.tranzo

import android.Manifest
import android.content.ContentValues
import android.app.NotificationChannel
import android.app.NotificationManager
import android.media.MediaScannerConnection
import android.os.Build
import android.os.Environment
import android.content.pm.PackageManager
import android.provider.MediaStore
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.net.URLConnection
import android.webkit.MimeTypeMap

class MainActivity : FlutterActivity() {
    private companion object {
        const val RECEIVED_FILES_CHANNEL = "tranzo/received_files"
        const val TRANSFER_PROGRESS_CHANNEL = "tranzo/transfer_progress_notification"
        const val TRANSFER_NOTIFICATION_CHANNEL_ID = "tranzo_transfer_channel"
        const val TRANSFER_PROGRESS_NOTIFICATION_ID = 2322
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            RECEIVED_FILES_CHANNEL,
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

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            TRANSFER_PROGRESS_CHANNEL,
        ).setMethodCallHandler { call, result ->
            if (call.method != "show_progress") {
                result.notImplemented()
                return@setMethodCallHandler
            }

            val fileName = call.argument<String>("fileName")?.trim().orEmpty()
            val progressPercent = (call.argument<Int>("progressPercent") ?: 0).coerceIn(0, 100)
            showTransferProgressNotification(
                fileName = if (fileName.isBlank()) "Transfer in progress" else fileName,
                progressPercent = progressPercent,
            )
            result.success(true)
        }
    }

    private fun showTransferProgressNotification(fileName: String, progressPercent: Int) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED
        ) {
            return
        }

        ensureTransferNotificationChannel()
        val builder = NotificationCompat.Builder(this, TRANSFER_NOTIFICATION_CHANNEL_ID)
            .setSmallIcon(applicationInfo.icon)
            .setContentTitle("Tranzo transfer")
            .setContentText(fileName)
            .setOnlyAlertOnce(true)
            .setSilent(true)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setProgress(100, progressPercent, false)

        try {
            NotificationManagerCompat.from(this).notify(
                TRANSFER_PROGRESS_NOTIFICATION_ID,
                builder.build(),
            )
        } catch (_: SecurityException) {
            // Ignore if notification permission state changes at runtime.
        }
    }

    private fun ensureTransferNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return
        }
        val manager = getSystemService(NotificationManager::class.java) ?: return
        val existing = manager.getNotificationChannel(TRANSFER_NOTIFICATION_CHANNEL_ID)
        if (existing != null) {
            return
        }
        val channel = NotificationChannel(
            TRANSFER_NOTIFICATION_CHANNEL_ID,
            "Transfer progress",
            NotificationManager.IMPORTANCE_LOW,
        ).apply {
            description = "Shows active transfer progress and keeps transfers alive."
            setShowBadge(false)
            setSound(null, null)
            enableVibration(false)
        }
        manager.createNotificationChannel(channel)
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
