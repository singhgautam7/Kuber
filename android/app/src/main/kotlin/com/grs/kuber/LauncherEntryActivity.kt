package com.grs.kuber

import android.app.Activity
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle

/**
 * Extra app-drawer entries (Kuber Cards, Kuber Notes, Reminders). Each is an
 * `activity-alias` of this invisible activity, off until the user adds it
 * from the screen's overflow or Settings. It forwards the alias's
 * `com.grs.kuber.deepLink` to [MainActivity] (the same kuber:// link the
 * pinned shortcuts use), so the running app opens that screen instead of a
 * second copy of the app starting in its own task.
 */
class LauncherEntryActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val link = intent.component?.let {
            try {
                packageManager.getActivityInfo(it, PackageManager.GET_META_DATA)
                    .metaData?.getString(META_DEEP_LINK)
            } catch (_: PackageManager.NameNotFoundException) {
                null
            }
        }
        startActivity(
            Intent(Intent.ACTION_VIEW, Uri.parse(link ?: "kuber://app/home"))
                .setClass(this, MainActivity::class.java)
                .addFlags(
                    Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_CLEAR_TOP or
                        Intent.FLAG_ACTIVITY_SINGLE_TOP
                )
        )
        finish()
    }

    companion object {
        private const val META_DEEP_LINK = "com.grs.kuber.deepLink"

        /** Entry id (Dart side) to alias class, see AndroidManifest.xml. */
        private val ENTRIES = mapOf(
            "cards" to "com.grs.kuber.entry.Cards",
            "notes" to "com.grs.kuber.entry.Notes",
            "reminders" to "com.grs.kuber.entry.Reminders",
        )

        fun states(context: Context): Map<String, Boolean> =
            ENTRIES.mapValues { (_, cls) ->
                context.packageManager.getComponentEnabledSetting(ComponentName(context, cls)) ==
                    PackageManager.COMPONENT_ENABLED_STATE_ENABLED
            }

        /** Shows or hides an entry in the app drawer. False for an unknown id. */
        fun set(context: Context, id: String?, enabled: Boolean): Boolean {
            val cls = ENTRIES[id] ?: return false
            context.packageManager.setComponentEnabledSetting(
                ComponentName(context, cls),
                if (enabled) PackageManager.COMPONENT_ENABLED_STATE_ENABLED
                else PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                PackageManager.DONT_KILL_APP
            )
            return true
        }
    }
}
