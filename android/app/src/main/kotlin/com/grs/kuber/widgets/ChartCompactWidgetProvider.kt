package com.grs.kuber.widgets

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.widget.RemoteViews
import androidx.core.content.ContextCompat
import com.grs.kuber.R
import es.antonborri.home_widget.HomeWidgetProvider
import java.io.File

/** Chart (compact, 7D) (4x2). Pre-rendered PNG bar chart. Tap -> Analytics. */
class ChartCompactWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_chart_compact)
            bind(context, views, widgetData)
            views.setOnClickPendingIntent(R.id.widget_root, WidgetCommon.deepLink(context, "analytics", "chart_$id"))
            appWidgetManager.updateAppWidget(id, views)
        }
    }

    private fun bind(context: Context, views: RemoteViews, prefs: SharedPreferences) {
        val data = WidgetCommon.json(prefs, "chart_compact")
        if (data == null) {
            WidgetCommon.showState(views, R.id.state_loading, R.id.state_empty, R.id.state_content, WidgetCommon.State.LOADING)
            return
        }
        val bmp = loadBitmap(data.optString("image"))
        if (data.optString("state") == "empty" || bmp == null) {
            WidgetCommon.showState(views, R.id.state_loading, R.id.state_empty, R.id.state_content, WidgetCommon.State.EMPTY)
            return
        }
        WidgetCommon.showState(views, R.id.state_loading, R.id.state_empty, R.id.state_content, WidgetCommon.State.CONTENT)
        views.setImageViewBitmap(R.id.iv_chart, bmp)
        views.setTextViewText(R.id.tv_net, data.optString("net"))
        views.setTextColor(
            R.id.tv_net,
            ContextCompat.getColor(
                context,
                if (data.optString("netSign") == "income") R.color.kuber_income else R.color.kuber_expense
            )
        )
        views.setTextViewText(R.id.tv_income, data.optString("income"))
        views.setTextViewText(R.id.tv_expense, data.optString("expense"))
    }

    private fun loadBitmap(path: String?) = runCatching {
        if (path.isNullOrBlank() || !File(path).exists()) null else BitmapFactory.decodeFile(path)
    }.getOrNull()
}
