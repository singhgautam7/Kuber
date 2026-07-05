package com.grs.kuber

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.DocumentsContract
import android.provider.Telephony
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val channelName = "com.grs.kuber/saf_backups"
    private val smsChannelName = "com.grs.kuber/sms"
    private val widgetsChannelName = "com.grs.kuber/widgets"
    private val pickFolderRequest = 24017
    private var pendingPickResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            smsChannelName
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getInboxMessages" -> {
                    val sinceMillis = (call.argument<Number>("sinceMillis"))?.toLong() ?: 0L
                    readInbox(sinceMillis, result)
                }
                else -> result.notImplemented()
            }
        }
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
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            widgetsChannelName
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "isPinSupported" -> result.success(isPinSupported())
                "requestPin" -> {
                    val provider = call.argument<String>("provider")
                    if (provider == null) {
                        result.error("bad_args", "Missing widget provider name", null)
                    } else {
                        result.success(requestPin(provider))
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    /** Whether the launcher supports pin-to-home (API 26+ and launcher opt-in). */
    private fun isPinSupported(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return false
        val mgr = getSystemService(AppWidgetManager::class.java) ?: return false
        return mgr.isRequestPinAppWidgetSupported
    }

    /** Requests the launcher pin the given widget provider to the home screen. */
    private fun requestPin(provider: String): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return false
        val mgr = getSystemService(AppWidgetManager::class.java) ?: return false
        if (!mgr.isRequestPinAppWidgetSupported) return false
        val component = ComponentName(this, "com.grs.kuber.widgets.$provider")
        return mgr.requestPinAppWidget(component, null, null)
    }

    /**
     * Reads the SMS inbox (read-only) for messages received on or after
     * [sinceMillis]. Returns a list of {address, body, date} maps. Sender
     * filtering and parsing happen on the Dart side, which keeps the known
     * bank-sender list as the single source of truth. Requires the READ_SMS
     * runtime permission (requested from Dart); without it the query throws and
     * we return an error.
     */
    private fun readInbox(sinceMillis: Long, result: MethodChannel.Result) {
        try {
            val messages = mutableListOf<Map<String, Any?>>()
            val projection = arrayOf(
                Telephony.Sms.ADDRESS,
                Telephony.Sms.BODY,
                Telephony.Sms.DATE
            )
            val selection = "${Telephony.Sms.DATE} >= ?"
            val selectionArgs = arrayOf(sinceMillis.toString())
            contentResolver.query(
                Telephony.Sms.Inbox.CONTENT_URI,
                projection,
                selection,
                selectionArgs,
                "${Telephony.Sms.DATE} DESC"
            )?.use { cursor ->
                val addressIdx = cursor.getColumnIndex(Telephony.Sms.ADDRESS)
                val bodyIdx = cursor.getColumnIndex(Telephony.Sms.BODY)
                val dateIdx = cursor.getColumnIndex(Telephony.Sms.DATE)
                while (cursor.moveToNext()) {
                    messages.add(
                        mapOf(
                            "address" to cursor.getString(addressIdx),
                            "body" to cursor.getString(bodyIdx),
                            "date" to cursor.getLong(dateIdx)
                        )
                    )
                }
            }
            result.success(messages)
        } catch (security: SecurityException) {
            result.error("permission_denied", security.message, null)
        } catch (error: Throwable) {
            result.error("read_error", error.message, null)
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
