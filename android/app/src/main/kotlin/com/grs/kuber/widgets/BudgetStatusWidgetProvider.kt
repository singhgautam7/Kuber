package com.grs.kuber.widgets

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import com.grs.kuber.R
import es.antonborri.home_widget.HomeWidgetProvider

/** Budget Status (4x3). Top-3 budgets with state-colored bars. Tap row -> budget. */
class BudgetStatusWidgetProvider : HomeWidgetProvider() {

    private data class RowIds(
        val row: Int, val name: Int, val value: Int,
        val pbPrimary: Int, val pbAmber: Int, val pbExpense: Int
    )

    private val rows = listOf(
        RowIds(R.id.bud_0, R.id.bud_0_name, R.id.bud_0_value, R.id.bud_0_pb_primary, R.id.bud_0_pb_amber, R.id.bud_0_pb_expense),
        RowIds(R.id.bud_1, R.id.bud_1_name, R.id.bud_1_value, R.id.bud_1_pb_primary, R.id.bud_1_pb_amber, R.id.bud_1_pb_expense),
        RowIds(R.id.bud_2, R.id.bud_2_name, R.id.bud_2_value, R.id.bud_2_pb_primary, R.id.bud_2_pb_amber, R.id.bud_2_pb_expense)
    )

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_budget_status)
            WidgetTheme.applyCard(views, widgetData)
            bind(context, views, widgetData, id)
            views.setOnClickPendingIntent(R.id.footer_link, WidgetCommon.deepLink(context, "more/budgets", "bud_all_$id"))
            appWidgetManager.updateAppWidget(id, views)
        }
    }

    private fun bind(context: Context, views: RemoteViews, prefs: SharedPreferences, widgetId: Int) {
        val data = WidgetCommon.json(prefs, "budget_status")
        if (data == null) {
            WidgetCommon.showState(views, R.id.state_loading, R.id.state_empty, R.id.state_content, WidgetCommon.State.LOADING)
            return
        }
        val budgets = data.optJSONArray("budgets")
        if (data.optString("state") == "empty" || budgets == null || budgets.length() == 0) {
            WidgetCommon.showState(views, R.id.state_loading, R.id.state_empty, R.id.state_content, WidgetCommon.State.EMPTY)
            return
        }
        WidgetCommon.showState(views, R.id.state_loading, R.id.state_empty, R.id.state_content, WidgetCommon.State.CONTENT)
        WidgetTheme.tintIcon(views, R.id.iv_hicon, WidgetTheme.primary(context, prefs))

        for ((i, r) in rows.withIndex()) {
            if (i >= budgets.length()) {
                views.setViewVisibility(r.row, View.GONE)
                continue
            }
            val b = budgets.getJSONObject(i)
            views.setViewVisibility(r.row, View.VISIBLE)
            views.setTextViewText(r.name, b.optString("name"))
            views.setTextViewText(r.value, b.optString("value"))
            val pct = b.optInt("percent", 0).coerceIn(0, 100)
            val shown = when (b.optString("status")) {
                "expense" -> r.pbExpense
                "amber" -> r.pbAmber
                else -> r.pbPrimary
            }
            for (pb in listOf(r.pbPrimary, r.pbAmber, r.pbExpense)) {
                views.setViewVisibility(pb, if (pb == shown) View.VISIBLE else View.GONE)
            }
            views.setProgressBar(shown, 100, pct, false)
            WidgetTheme.tintProgress(views, r.pbPrimary, WidgetTheme.primary(context, prefs))
            WidgetTheme.tintProgress(views, r.pbAmber, WidgetTheme.warning(context))
            WidgetTheme.tintProgress(views, r.pbExpense, WidgetTheme.expense(context, prefs))
            views.setOnClickPendingIntent(
                r.row,
                WidgetCommon.deepLink(context, b.optString("path", "more/budgets"), "bud_${widgetId}_$i")
            )
        }

        val more = data.optString("moreText")
        views.setViewVisibility(R.id.footer_link, if (more.isBlank()) View.GONE else View.VISIBLE)
        if (more.isNotBlank()) views.setTextViewText(R.id.footer_link, more)
    }
}
