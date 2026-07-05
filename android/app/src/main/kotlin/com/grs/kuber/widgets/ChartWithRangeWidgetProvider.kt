package com.grs.kuber.widgets

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.widget.RemoteViews
import androidx.core.content.ContextCompat
import com.grs.kuber.R
import es.antonborri.home_widget.HomeWidgetProvider
import java.io.File

/**
 * Trends (range switcher) (4x3). Charts for all three ranges are pre-rendered by
 * Flutter; the per-instance selected range lives in "trendswidget_<widgetId>" and
 * is switched by [RangeSwitchReceiver] without a re-render. Tap body -> Analytics.
 */
class ChartWithRangeWidgetProvider : HomeWidgetProvider() {

    companion object {
        fun rangeKey(widgetId: Int) = "trendswidget_$widgetId"
        val RANGES = listOf("7D", "4W", "6M")
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_chart_with_range)
            val range = widgetData.getString(rangeKey(id), "7D") ?: "7D"
            bind(context, views, widgetData, id, range)
            val pi = WidgetCommon.deepLink(context, "analytics", "trends_$id")
            views.setOnClickPendingIntent(R.id.widget_root, pi)
            views.setOnClickPendingIntent(R.id.footer_link, pi)
            appWidgetManager.updateAppWidget(id, views)
        }
    }

    private fun bind(context: Context, views: RemoteViews, prefs: SharedPreferences, widgetId: Int, range: String) {
        // Chips always wired + styled (visible even in loading/empty).
        styleChips(context, views, widgetId, range)

        val data = WidgetCommon.json(prefs, "chart_with_range")
        if (data == null) {
            WidgetCommon.showState(views, R.id.state_loading, R.id.state_empty, R.id.state_content, WidgetCommon.State.LOADING)
            return
        }
        val ranges = data.optJSONObject("ranges")
        val rd = ranges?.optJSONObject(range)
        val bmp = loadBitmap(rd?.optString("image"))
        if (data.optString("state") == "empty" || rd == null || bmp == null) {
            WidgetCommon.showState(views, R.id.state_loading, R.id.state_empty, R.id.state_content, WidgetCommon.State.EMPTY)
            return
        }
        WidgetCommon.showState(views, R.id.state_loading, R.id.state_empty, R.id.state_content, WidgetCommon.State.CONTENT)
        views.setImageViewBitmap(R.id.iv_chart, bmp)
        views.setTextViewText(R.id.tv_net, rd.optString("net"))
        views.setTextColor(
            R.id.tv_net,
            ContextCompat.getColor(
                context,
                if (rd.optString("netSign") == "income") R.color.kuber_income else R.color.kuber_expense
            )
        )
        views.setTextViewText(R.id.tv_income, rd.optString("income"))
        views.setTextViewText(R.id.tv_expense, rd.optString("expense"))
    }

    private fun styleChips(context: Context, views: RemoteViews, widgetId: Int, range: String) {
        val chips = mapOf("7D" to R.id.chip_7d, "4W" to R.id.chip_4w, "6M" to R.id.chip_6m)
        for ((key, chipId) in chips) {
            val selected = key == range
            views.setInt(
                chipId, "setBackgroundResource",
                if (selected) R.drawable.widget_chip_bg_selected else R.drawable.widget_chip_bg
            )
            views.setTextColor(
                chipId,
                ContextCompat.getColor(context, if (selected) R.color.kuber_primary else R.color.kuber_text_secondary)
            )
            views.setOnClickPendingIntent(chipId, switchIntent(context, widgetId, key))
        }
    }

    private fun switchIntent(context: Context, widgetId: Int, range: String): PendingIntent {
        val intent = Intent(context, RangeSwitchReceiver::class.java).apply {
            action = "com.grs.kuber.widgets.RANGE_SWITCH"
            putExtra("widgetId", widgetId)
            putExtra("range", range)
        }
        return PendingIntent.getBroadcast(
            context,
            "trends_${widgetId}_$range".hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }

    private fun loadBitmap(path: String?) = runCatching {
        if (path.isNullOrBlank() || !File(path).exists()) null else BitmapFactory.decodeFile(path)
    }.getOrNull()
}
