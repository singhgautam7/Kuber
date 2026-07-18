package com.grs.kuber.widgets

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Color
import android.view.View
import android.widget.RemoteViews
import androidx.core.content.ContextCompat
import com.grs.kuber.R
import es.antonborri.home_widget.HomeWidgetProvider

/** Recent Transactions (4x2). Up to 4 fixed rows. Tap row -> txn; footer -> History. */
class RecentTransactionsWidgetProvider : HomeWidgetProvider() {

    private data class RowIds(val row: Int, val icon: Int, val name: Int, val account: Int, val amount: Int)

    private val rows = listOf(
        RowIds(R.id.row_0, R.id.row_0_icon, R.id.row_0_name, R.id.row_0_account, R.id.row_0_amount),
        RowIds(R.id.row_1, R.id.row_1_icon, R.id.row_1_name, R.id.row_1_account, R.id.row_1_amount),
        RowIds(R.id.row_2, R.id.row_2_icon, R.id.row_2_name, R.id.row_2_account, R.id.row_2_amount),
        RowIds(R.id.row_3, R.id.row_3_icon, R.id.row_3_name, R.id.row_3_account, R.id.row_3_amount)
    )

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_recent_transactions)
            WidgetTheme.applyCard(views, widgetData)
            val accent = WidgetTheme.primary(context, widgetData)
            WidgetTheme.tintIcon(views, R.id.iv_hicon, accent)
            views.setTextColor(R.id.footer_link, accent)
            bind(context, views, widgetData, id)
            views.setOnClickPendingIntent(R.id.widget_root, WidgetCommon.deepLink(context, "history", "recent_root_$id"))
            views.setOnClickPendingIntent(R.id.footer_link, WidgetCommon.deepLink(context, "history", "recent_all_$id"))
            appWidgetManager.updateAppWidget(id, views)
        }
    }

    private fun bind(context: Context, views: RemoteViews, prefs: SharedPreferences, widgetId: Int) {
        val data = WidgetCommon.json(prefs, "recent_transactions")
        if (data == null) {
            WidgetCommon.showState(views, R.id.state_loading, R.id.state_empty, R.id.state_content, WidgetCommon.State.LOADING)
            return
        }
        val txns = data.optJSONArray("txns")
        if (data.optString("state") == "empty" || txns == null || txns.length() == 0) {
            WidgetCommon.showState(views, R.id.state_loading, R.id.state_empty, R.id.state_content, WidgetCommon.State.EMPTY)
            return
        }
        WidgetCommon.showState(views, R.id.state_loading, R.id.state_empty, R.id.state_content, WidgetCommon.State.CONTENT)
        val stale = WidgetCommon.isStale(data.optLong("updatedMillis"))

        for ((i, r) in rows.withIndex()) {
            if (i >= txns.length()) {
                views.setViewVisibility(r.row, View.GONE)
                continue
            }
            val t = txns.getJSONObject(i)
            views.setViewVisibility(r.row, View.VISIBLE)
            views.setTextViewText(r.name, t.optString("name"))
            views.setTextViewText(r.account, t.optString("account"))
            views.setTextViewText(r.amount, t.optString("amount"))
            views.setTextColor(
                r.amount,
                WidgetTheme.amountColor(context, prefs, t.optString("amountSign"), stale)
            )
            runCatching { views.setInt(r.icon, "setColorFilter", Color.parseColor(t.optString("color", "#3B82F6"))) }
            views.setOnClickPendingIntent(
                r.row,
                WidgetCommon.deepLink(context, t.optString("path", "history"), "recent_${widgetId}_$i")
            )
        }
    }
}
