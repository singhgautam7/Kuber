package com.grs.kuber

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.DocumentsContract
import android.provider.Telephony
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import android.view.WindowManager
import androidx.activity.enableEdgeToEdge
import androidx.core.content.pm.ShortcutInfoCompat
import androidx.core.content.pm.ShortcutManagerCompat
import androidx.core.graphics.drawable.IconCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

class MainActivity : FlutterFragmentActivity() {
    private val channelName = "com.grs.kuber/saf_backups"
    private val smsChannelName = "com.grs.kuber/sms"
    private val widgetsChannelName = "com.grs.kuber/widgets"
    private val shortcutsChannelName = "com.grs.kuber/shortcuts"
    private val secureChannelName = "com.grs.kuber/secure_screen"
    private val keystoreChannelName = "com.grs.kuber/cards_keystore"
    private val pickFolderRequest = 24017
    private var pendingPickResult: MethodChannel.Result? = null

    // Kuber Cards biometric-convenience PIN store (Android Keystore).
    private val cardsKeyAlias = "kuber_cards_pin_key"
    private val cardsPrefs = "kuber_cards_secure"
    private val cardsPinEntry = "pin_ct"

    override fun onCreate(savedInstanceState: Bundle?) {
        // Android 15 edge-to-edge: explicit backward-compatible opt-in, per
        // the Play Console recommendation. Pairs with the Dart-side
        // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge) in
        // main.dart; bar appearance is driven from app.dart (icon brightness
        // only, never the deprecated bar-color setters).
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)
    }

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

        // User-triggered pin-to-home-screen for app shortcuts (overflow menu).
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            shortcutsChannelName
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "isPinShortcutSupported" ->
                    result.success(ShortcutManagerCompat.isRequestPinShortcutSupported(this))
                "pinShortcut" -> {
                    try {
                        result.success(
                            pinShortcut(
                                call.argument<String>("id"),
                                call.argument<String>("shortLabel"),
                                call.argument<String>("longLabel"),
                                call.argument<String>("icon"),
                                call.argument<String>("deepLink")
                            )
                        )
                    } catch (e: Throwable) {
                        result.error("pin_error", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }

        // Kuber Cards: FLAG_SECURE toggling (no screenshots / blank recents).
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            secureChannelName
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "enable" -> {
                    window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    result.success(null)
                }
                "disable" -> {
                    window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        // Kuber Cards: biometric-convenience secret store (hardware Keystore).
        // Stores the derived key (base64), never the PIN.
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            keystoreChannelName
        ).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "store" -> {
                        val secret = call.argument<String>("secret")
                        if (secret == null) {
                            result.error("bad_args", "Missing secret", null)
                        } else {
                            storeCardsSecret(secret)
                            result.success(true)
                        }
                    }
                    "retrieve" -> result.success(retrieveCardsSecret())
                    "clear" -> {
                        clearCardsSecret()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            } catch (e: Throwable) {
                result.error("keystore_error", e.message, null)
            }
        }
    }

    // ── Kuber Cards Keystore helpers ─────────────────────────────────────────

    /** Returns (creating if needed) the hardware-backed AES key for the PIN. */
    private fun cardsSecretKey(): SecretKey {
        val ks = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
        (ks.getKey(cardsKeyAlias, null) as? SecretKey)?.let { return it }
        val generator = KeyGenerator.getInstance(
            KeyProperties.KEY_ALGORITHM_AES, "AndroidKeyStore"
        )
        generator.init(
            KeyGenParameterSpec.Builder(
                cardsKeyAlias,
                KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT
            )
                .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
                .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
                .build()
        )
        return generator.generateKey()
    }

    /** Encrypts the secret under the Keystore key; stores base64(iv:ct) in prefs. */
    private fun storeCardsSecret(secret: String) {
        val cipher = Cipher.getInstance("AES/GCM/NoPadding")
        cipher.init(Cipher.ENCRYPT_MODE, cardsSecretKey())
        val iv = cipher.iv
        val ct = cipher.doFinal(secret.toByteArray(Charsets.UTF_8))
        val encoded = "${Base64.encodeToString(iv, Base64.NO_WRAP)}:" +
            Base64.encodeToString(ct, Base64.NO_WRAP)
        getSharedPreferences(cardsPrefs, Context.MODE_PRIVATE)
            .edit().putString(cardsPinEntry, encoded).apply()
    }

    private fun retrieveCardsSecret(): String? {
        val encoded = getSharedPreferences(cardsPrefs, Context.MODE_PRIVATE)
            .getString(cardsPinEntry, null) ?: return null
        val parts = encoded.split(":")
        if (parts.size != 2) return null
        val iv = Base64.decode(parts[0], Base64.NO_WRAP)
        val ct = Base64.decode(parts[1], Base64.NO_WRAP)
        val cipher = Cipher.getInstance("AES/GCM/NoPadding")
        cipher.init(Cipher.DECRYPT_MODE, cardsSecretKey(), GCMParameterSpec(128, iv))
        return String(cipher.doFinal(ct), Charsets.UTF_8)
    }

    private fun clearCardsSecret() {
        getSharedPreferences(cardsPrefs, Context.MODE_PRIVATE)
            .edit().remove(cardsPinEntry).apply()
    }

    /**
     * Pins an app shortcut to the home screen via ShortcutManagerCompat. The
     * intent mirrors the static shortcuts in shortcuts.xml (ACTION_VIEW + a
     * kuber:// deep link, kept inside this package), so a pinned shortcut opens
     * the same route. Returns false on unsupported launchers / bad args.
     */
    private fun pinShortcut(
        id: String?,
        shortLabel: String?,
        longLabel: String?,
        icon: String?,
        deepLink: String?
    ): Boolean {
        if (id == null || shortLabel == null || longLabel == null || deepLink == null) {
            return false
        }
        if (!ShortcutManagerCompat.isRequestPinShortcutSupported(this)) return false
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(deepLink)).apply {
            setPackage(packageName)
        }
        val builder = ShortcutInfoCompat.Builder(this, id)
            .setShortLabel(shortLabel)
            .setLongLabel(longLabel)
            .setIntent(intent)
        if (icon != null) {
            val resId = resources.getIdentifier(icon, "drawable", packageName)
            if (resId != 0) {
                builder.setIcon(IconCompat.createWithResource(this, resId))
            }
        }
        return ShortcutManagerCompat.requestPinShortcut(this, builder.build(), null)
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
