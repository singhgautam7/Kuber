package com.grs.kuber.widgets

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.graphics.Color
import android.view.View
import android.widget.RemoteViews
import com.grs.kuber.R
import es.antonborri.home_widget.HomeWidgetProvider
import java.io.File

/** Category Donut (4x3). Pre-rendered donut PNG + top-3 rows. Tap -> Analytics (categories). */
class CategoryDonutWidgetProvider : HomeWidgetProvider() {

    private data class RowIds(val row: Int, val dot: Int, val name: Int, val value: Int)

    private val rows = listOf(
        RowIds(R.id.cat_0, R.id.cat_0_dot, R.id.cat_0_name, R.id.cat_0_value),
        RowIds(R.id.cat_1, R.id.cat_1_dot, R.id.cat_1_name, R.id.cat_1_value),
        RowIds(R.id.cat_2, R.id.cat_2_dot, R.id.cat_2_name, R.id.cat_2_value)
    )

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_category_donut)
            WidgetTheme.applyCard(views, widgetData)
            bind(context, views, widgetData)
            val pi = WidgetCommon.deepLink(context, "analytics?section=categories", "donut_$id")
            views.setOnClickPendingIntent(R.id.widget_root, pi)
            views.setOnClickPendingIntent(R.id.footer_link, pi)
            appWidgetManager.updateAppWidget(id, views)
        }
    }

    private fun bind(context: Context, views: RemoteViews, prefs: SharedPreferences) {
        val data = WidgetCommon.json(prefs, "category_donut")
        if (data == null) {
            WidgetCommon.showState(views, R.id.state_loading, R.id.state_empty, R.id.state_content, WidgetCommon.State.LOADING)
            return
        }
        val cats = data.optJSONArray("cats")
        val bmp = loadBitmap(data.optString("image"))
        if (data.optString("state") == "empty" || cats == null || cats.length() == 0 || bmp == null) {
            WidgetCommon.showState(views, R.id.state_loading, R.id.state_empty, R.id.state_content, WidgetCommon.State.EMPTY)
            return
        }
        WidgetCommon.showState(views, R.id.state_loading, R.id.state_empty, R.id.state_content, WidgetCommon.State.CONTENT)
        val accent = WidgetTheme.primary(context, prefs)
        WidgetTheme.tintIcon(views, R.id.iv_hicon, accent)
        views.setTextColor(R.id.footer_link, accent)
        views.setImageViewBitmap(R.id.iv_donut, bmp)
        for ((i, r) in rows.withIndex()) {
            if (i >= cats.length()) {
                views.setViewVisibility(r.row, View.GONE)
                continue
            }
            val c = cats.getJSONObject(i)
            views.setViewVisibility(r.row, View.VISIBLE)
            views.setTextViewText(r.name, c.optString("name"))
            views.setTextViewText(r.value, c.optString("value"))
            runCatching { views.setInt(r.dot, "setColorFilter", Color.parseColor(c.optString("color", "#3B82F6"))) }
        }
    }

    private fun loadBitmap(path: String?) = runCatching {
        if (path.isNullOrBlank() || !File(path).exists()) null else BitmapFactory.decodeFile(path)
    }.getOrNull()
}
