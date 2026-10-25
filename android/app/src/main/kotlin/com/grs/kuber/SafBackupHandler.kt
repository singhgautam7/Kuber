package com.grs.kuber

import android.content.Context
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.provider.DocumentsContract
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

/**
 * Backup folder I/O for channel com.grs.kuber/saf_backups (write, list,
 * delete). Every ContentResolver call runs on a background executor and the
 * result is posted back to the main looper: a slow provider (Drive, SD card)
 * must never block the thread Flutter's vsync arrives on. Registered on the
 * app's engine (MainActivity, which also handles pickFolder) and on the
 * background worker's headless engine.
 */
class SafBackupHandler(private val context: Context) {
    private val executor = Executors.newSingleThreadExecutor()
    private val main = Handler(Looper.getMainLooper())

    /** Handles the I/O methods; returns false for anything else. */
    fun handle(method: String, arguments: Any?, result: MethodChannel.Result): Boolean {
        @Suppress("UNCHECKED_CAST")
        val args = arguments as? Map<String, Any?>
        when (method) {
            "writeText" -> {
                val folderUri = args?.get("folderUri") as? String
                val fileName = args?.get("fileName") as? String
                val contents = args?.get("contents") as? String
                if (folderUri == null || fileName == null || contents == null) {
                    result.error("bad_args", "Missing backup write arguments", null)
                } else {
                    run(result, "write_error") { writeText(folderUri, fileName, contents); null }
                }
            }
            "listFileNames" -> {
                val folderUri = arguments as? String
                if (folderUri == null) {
                    result.error("bad_args", "Missing folder URI", null)
                } else {
                    run(result, "unknown") { listFileNames(folderUri) }
                }
            }
            "deleteFile" -> {
                val folderUri = args?.get("folderUri") as? String
                val fileName = args?.get("fileName") as? String
                if (folderUri == null || fileName == null) {
                    result.error("bad_args", "Missing delete arguments", null)
                } else {
                    run(result, "unknown") { deleteFile(folderUri, fileName); null }
                }
            }
            else -> return false
        }
        return true
    }

    /** Standalone registration (worker engine: no folder picker there). */
    fun register(messenger: BinaryMessenger) {
        MethodChannel(messenger, CHANNEL).setMethodCallHandler { call, result ->
            if (!handle(call.method, call.arguments, result)) result.notImplemented()
        }
    }

    fun shutdown() = executor.shutdown()

    private fun run(result: MethodChannel.Result, errorCode: String, block: () -> Any?) {
        executor.execute {
            try {
                val value = block()
                main.post { result.success(value) }
            } catch (security: SecurityException) {
                main.post { result.error("folder_revoked", security.message, null) }
            } catch (error: Throwable) {
                main.post { result.error(errorCode, error.message, null) }
            }
        }
    }

    private fun writeText(folderUriString: String, fileName: String, contents: String) {
        val resolver = context.contentResolver
        val folderUri = Uri.parse(folderUriString)
        val parentUri = DocumentsContract.buildDocumentUriUsingTree(
            folderUri,
            DocumentsContract.getTreeDocumentId(folderUri)
        )
        findChild(folderUri, fileName)?.let { DocumentsContract.deleteDocument(resolver, it) }
        val fileUri = DocumentsContract.createDocument(
            resolver, parentUri, "application/json", fileName
        ) ?: throw IllegalStateException("Could not create backup file")
        resolver.openOutputStream(fileUri, "w")?.use { stream ->
            stream.write(contents.toByteArray(Charsets.UTF_8))
        } ?: throw IllegalStateException("Could not open backup file")
    }

    private fun listFileNames(folderUriString: String): List<String> {
        val folderUri = Uri.parse(folderUriString)
        val childrenUri = DocumentsContract.buildChildDocumentsUriUsingTree(
            folderUri,
            DocumentsContract.getTreeDocumentId(folderUri)
        )
        val names = mutableListOf<String>()
        context.contentResolver.query(
            childrenUri,
            arrayOf(DocumentsContract.Document.COLUMN_DISPLAY_NAME),
            null, null, null
        )?.use { cursor ->
            while (cursor.moveToNext()) names.add(cursor.getString(0))
        }
        return names
    }

    private fun deleteFile(folderUriString: String, fileName: String) {
        val folderUri = Uri.parse(folderUriString)
        findChild(folderUri, fileName)?.let {
            DocumentsContract.deleteDocument(context.contentResolver, it)
        }
    }

    private fun findChild(folderUri: Uri, fileName: String): Uri? {
        val childrenUri = DocumentsContract.buildChildDocumentsUriUsingTree(
            folderUri,
            DocumentsContract.getTreeDocumentId(folderUri)
        )
        context.contentResolver.query(
            childrenUri,
            arrayOf(
                DocumentsContract.Document.COLUMN_DOCUMENT_ID,
                DocumentsContract.Document.COLUMN_DISPLAY_NAME
            ),
            null, null, null
        )?.use { cursor ->
            while (cursor.moveToNext()) {
                if (cursor.getString(1) == fileName) {
                    return DocumentsContract.buildDocumentUriUsingTree(folderUri, cursor.getString(0))
                }
            }
        }
        return null
    }

    companion object {
        const val CHANNEL = "com.grs.kuber/saf_backups"
    }
}
