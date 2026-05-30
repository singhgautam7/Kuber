package com.grs.kuber

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.provider.DocumentsContract
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val channelName = "com.grs.kuber/saf_backups"
    private val pickFolderRequest = 24017
    private var pendingPickResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "pickFolder" -> pickFolder(result)
                "writeText" -> {
                    val folderUri = call.argument<String>("folderUri")
                    val fileName = call.argument<String>("fileName")
                    val contents = call.argument<String>("contents")
                    if (folderUri == null || fileName == null || contents == null) {
                        result.error("bad_args", "Missing backup write arguments", null)
                    } else {
                        writeText(folderUri, fileName, contents, result)
                    }
                }
                "listFileNames" -> {
                    val folderUri = call.arguments as? String
                    if (folderUri == null) {
                        result.error("bad_args", "Missing folder URI", null)
                    } else {
                        listFileNames(folderUri, result)
                    }
                }
                "deleteFile" -> {
                    val folderUri = call.argument<String>("folderUri")
                    val fileName = call.argument<String>("fileName")
                    if (folderUri == null || fileName == null) {
                        result.error("bad_args", "Missing delete arguments", null)
                    } else {
                        deleteFile(folderUri, fileName, result)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun pickFolder(result: MethodChannel.Result) {
        if (pendingPickResult != null) {
            result.error("busy", "A folder picker is already open", null)
            return
        }
        pendingPickResult = result
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
            addFlags(Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION)
            addFlags(Intent.FLAG_GRANT_PREFIX_URI_PERMISSION)
        }
        startActivityForResult(intent, pickFolderRequest)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != pickFolderRequest) return
        val result = pendingPickResult ?: return
        pendingPickResult = null
        if (resultCode != Activity.RESULT_OK) {
            result.success(null)
            return
        }
        val uri = data?.data
        if (uri == null) {
            result.success(null)
            return
        }
        val flags = data.flags and
            (Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
        contentResolver.takePersistableUriPermission(uri, flags)
        result.success(uri.toString())
    }

    private fun writeText(
        folderUriString: String,
        fileName: String,
        contents: String,
        result: MethodChannel.Result
    ) {
        try {
            val folderUri = Uri.parse(folderUriString)
            val treeDocumentId = DocumentsContract.getTreeDocumentId(folderUri)
            val parentUri = DocumentsContract.buildDocumentUriUsingTree(
                folderUri,
                treeDocumentId
            )
            val existing = findChild(folderUri, fileName)
            if (existing != null) {
                DocumentsContract.deleteDocument(contentResolver, existing)
            }
            val fileUri = DocumentsContract.createDocument(
                contentResolver,
                parentUri,
                "application/json",
                fileName
            ) ?: throw IllegalStateException("Could not create backup file")
            contentResolver.openOutputStream(fileUri, "w")?.use { stream ->
                stream.write(contents.toByteArray(Charsets.UTF_8))
            } ?: throw IllegalStateException("Could not open backup file")
            result.success(null)
        } catch (security: SecurityException) {
            result.error("folder_revoked", security.message, null)
        } catch (error: Throwable) {
            result.error("write_error", error.message, null)
        }
    }

    private fun listFileNames(folderUriString: String, result: MethodChannel.Result) {
        try {
            val folderUri = Uri.parse(folderUriString)
            val childrenUri = DocumentsContract.buildChildDocumentsUriUsingTree(
                folderUri,
                DocumentsContract.getTreeDocumentId(folderUri)
            )
            val names = mutableListOf<String>()
            contentResolver.query(
                childrenUri,
                arrayOf(DocumentsContract.Document.COLUMN_DISPLAY_NAME),
                null,
                null,
                null
            )?.use { cursor ->
                while (cursor.moveToNext()) {
                    names.add(cursor.getString(0))
                }
            }
            result.success(names)
        } catch (security: SecurityException) {
            result.error("folder_revoked", security.message, null)
        } catch (error: Throwable) {
            result.error("unknown", error.message, null)
        }
    }

    private fun deleteFile(
        folderUriString: String,
        fileName: String,
        result: MethodChannel.Result
    ) {
        try {
            val folderUri = Uri.parse(folderUriString)
            val child = findChild(folderUri, fileName)
            if (child != null) {
                DocumentsContract.deleteDocument(contentResolver, child)
            }
            result.success(null)
        } catch (security: SecurityException) {
            result.error("folder_revoked", security.message, null)
        } catch (error: Throwable) {
            result.error("unknown", error.message, null)
        }
    }

    private fun findChild(folderUri: Uri, fileName: String): Uri? {
        val childrenUri = DocumentsContract.buildChildDocumentsUriUsingTree(
            folderUri,
            DocumentsContract.getTreeDocumentId(folderUri)
        )
        contentResolver.query(
            childrenUri,
            arrayOf(
                DocumentsContract.Document.COLUMN_DOCUMENT_ID,
                DocumentsContract.Document.COLUMN_DISPLAY_NAME
            ),
            null,
            null,
            null
        )?.use { cursor ->
            while (cursor.moveToNext()) {
                if (cursor.getString(1) == fileName) {
                    return DocumentsContract.buildDocumentUriUsingTree(
                        folderUri,
                        cursor.getString(0)
                    )
                }
            }
        }
        return null
    }
}
