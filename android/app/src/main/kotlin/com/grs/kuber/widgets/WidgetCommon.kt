package com.grs.kuber.widgets

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONObject

/**
 * Shared helpers for all Kuber home-screen widget providers.
 *
 * Data contract: the Flutter [WidgetSyncService] writes one JSON string per
 * widget (via the home_widget bridge). Amounts arrive pre-formatted as display
 * strings so currency/locale formatting matches the app exactly; providers only
 * bind text and choose income/expense colors from a sign flag.
 */
object WidgetCommon {

    /** Muted vs colored value handling for the stale state. */
    const val STALE_AFTER_MS = 24L * 60L * 60L * 1000L

    fun data(context: Context): SharedPreferences = HomeWidgetPlugin.getData(context)

    fun json(prefs: SharedPreferences, key: String): JSONObject? {
        val raw = prefs.getString(key, null) ?: return null
        return try {
            JSONObject(raw)
        } catch (_: Throwable) {
            null
        }
    }

    /** True when [updatedMillis] is older than 24h. */
    fun isStale(updatedMillis: Long): Boolean =
        updatedMillis > 0 && System.currentTimeMillis() - updatedMillis > STALE_AFTER_MS

    /** "Updated 4m ago" style relative label. */
    fun updatedLabel(updatedMillis: Long, prefix: String = "Updated"): String {
        if (updatedMillis <= 0) return "$prefix just now"
        val diff = System.currentTimeMillis() - updatedMillis
        val mins = diff / 60000
        return when {
            mins < 1 -> "$prefix just now"
            mins < 60 -> "$prefix ${mins}m ago"
            mins < 1440 -> "$prefix ${mins / 60}h ago"
            else -> "$prefix ${mins / 1440}d ago"
        }
    }

    /** A PendingIntent that opens the app at kuber://app/<path> (handled by MainActivity). */
    fun deepLink(context: Context, path: String, requestKey: String): PendingIntent {
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse("kuber://app/$path")).apply {
            setPackage(context.packageName)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        }
        return PendingIntent.getActivity(
            context,
            requestKey.hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }

    /** Toggle the three state containers (any id may be 0 to skip). */
    fun showState(
        views: RemoteViews,
        loadingId: Int,
        emptyId: Int,
        contentId: Int,
        show: State
    ) {
        if (loadingId != 0) views.setViewVisibility(loadingId, vis(show == State.LOADING))
        if (emptyId != 0) views.setViewVisibility(emptyId, vis(show == State.EMPTY))
        if (contentId != 0) views.setViewVisibility(contentId, vis(show == State.CONTENT))
    }

    fun vis(visible: Boolean): Int = if (visible) android.view.View.VISIBLE else android.view.View.GONE

    enum class State { LOADING, EMPTY, CONTENT }
}
