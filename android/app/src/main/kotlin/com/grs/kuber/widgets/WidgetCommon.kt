package com.grs.kuber.widgets

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONObject
import java.io.File

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

    /**
     * Decodes a chart PNG rendered by the Flutter side, downsampling to at
     * most [maxDim] px on the longest edge (BitmapFactory.Options bounds pass
     * + inSampleSize, per the Play Console bitmap-downsampling guidance).
     * The app's own bitmaps are small (<=480px), so this is a safety net for
     * future resolution bumps rather than a behavior change. Never throws.
     */
    fun decodeBitmap(path: String?, maxDim: Int = 1024): Bitmap? = runCatching {
        if (path.isNullOrBlank() || !File(path).exists()) return null
        val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
        BitmapFactory.decodeFile(path, bounds)
        if (bounds.outWidth <= 0 || bounds.outHeight <= 0) return null
        var sample = 1
        while (bounds.outWidth / (sample * 2) > maxDim ||
            bounds.outHeight / (sample * 2) > maxDim
        ) {
            sample *= 2
        }
        val opts = BitmapFactory.Options().apply { inSampleSize = sample }
        BitmapFactory.decodeFile(path, opts)
    }.getOrNull()

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
