package com.fortranthesis.moldify

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
	private val channelName = "com.fortranthesis.moldify/pdf_export"

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
			.setMethodCallHandler { call, result ->
				when (call.method) {
					"savePdfToDownloads" -> {
						try {
							val bytes = call.argument<ByteArray>("bytes")
							val fileName = call.argument<String>("fileName") ?: "report.pdf"
							val subDirectory = call.argument<String>("subDirectory") ?: "Moldify"

							if (bytes == null) {
								result.error("INVALID_ARGS", "Missing PDF bytes", null)
								return@setMethodCallHandler
							}

							if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
								val relativePath = Environment.DIRECTORY_DOWNLOADS + File.separator + subDirectory
								val values = ContentValues().apply {
									put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
									put(MediaStore.MediaColumns.MIME_TYPE, "application/pdf")
									put(MediaStore.MediaColumns.RELATIVE_PATH, relativePath)
									put(MediaStore.MediaColumns.IS_PENDING, 1)
								}

								val collection = MediaStore.Downloads.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
								val uri = contentResolver.insert(collection, values)

								if (uri == null) {
									result.error("SAVE_FAILED", "Unable to create Download entry", null)
									return@setMethodCallHandler
								}

								contentResolver.openOutputStream(uri)?.use { outputStream ->
									outputStream.write(bytes)
								} ?: run {
									contentResolver.delete(uri, null, null)
									result.error("SAVE_FAILED", "Unable to open output stream", null)
									return@setMethodCallHandler
								}

								val completeValues = ContentValues().apply {
									put(MediaStore.MediaColumns.IS_PENDING, 0)
								}
								contentResolver.update(uri, completeValues, null, null)

								result.success("Downloads/$subDirectory/$fileName")
							} else {
								val downloadsDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
								val targetDir = File(downloadsDir, subDirectory)
								if (!targetDir.exists()) {
									targetDir.mkdirs()
								}

								val file = File(targetDir, fileName)
								FileOutputStream(file).use { outputStream ->
									outputStream.write(bytes)
								}

								result.success(file.absolutePath)
							}
						} catch (e: Exception) {
							result.error("SAVE_FAILED", e.message, null)
						}
					}
					else -> result.notImplemented()
				}
			}
	}
}
