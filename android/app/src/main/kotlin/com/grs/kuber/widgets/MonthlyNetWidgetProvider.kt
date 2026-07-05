package com.grs.kuber.widgets

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import androidx.core.content.ContextCompat
import com.grs.kuber.R
import es.antonborri.home_widget.HomeWidgetProvider

/** Monthly Net (2x1 compact / 2x2 full). Tap -> Home. */
class MonthlyNetWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (id in appWidgetIds) {
            val compact = isCompact(appWidgetManager, id)
            val layout = if (compact) R.layout.widget_monthly_net_compact else R.layout.widget_monthly_net
            val views = RemoteViews(context.packageName, layout)
            bind(context, views, widgetData, compact)
            views.setOnClickPendingIntent(
                R.id.widget_root,
                WidgetCommon.deepLink(context, "home", "monthly_net_$id")
            )
            appWidgetManager.updateAppWidget(id, views)
        }
    }

    private fun isCompact(mgr: AppWidgetManager, id: Int): Boolean {
        val minH = mgr.getAppWidgetOptions(id)
            .getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 0)
        return minH in 1..109 // < ~2 cells tall
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: android.os.Bundle
    ) {
        onUpdate(context, appWidgetManager, intArrayOf(appWidgetId), WidgetCommon.data(context))
    }

    private fun bind(
        context: Context,
        views: RemoteViews,
        prefs: SharedPreferences,
        compact: Boolean
    ) {
        val data = WidgetCommon.json(prefs, "monthly_net")
        if (data == null) {
            WidgetCommon.showState(
                views, R.id.state_loading, if (compact) 0 else R.id.state_empty,
                R.id.state_content, WidgetCommon.State.LOADING
            )
            return
        }
        if (!compact && data.optString("state") == "empty") {
            WidgetCommon.showState(
                views, R.id.state_loading, R.id.state_empty, R.id.state_content,
                WidgetCommon.State.EMPTY
            )
            return
        }
        WidgetCommon.showState(
            views, R.id.state_loading, if (compact) 0 else R.id.state_empty,
            R.id.state_content, WidgetCommon.State.CONTENT
        )

        val updatedMillis = data.optLong("updatedMillis")
        val stale = WidgetCommon.isStale(updatedMillis)

        views.setTextViewText(R.id.tv_net, data.optString("net", "₹0"))
        val netColor = if (stale) R.color.kuber_text_secondary else colorFor(data.optString("netSign"))
        views.setTextColor(R.id.tv_net, ContextCompat.getColor(context, netColor))

        if (compact) {
            views.setTextViewText(R.id.tv_updated, WidgetCommon.updatedLabel(updatedMillis, "").trim())
        } else {
            views.setTextViewText(R.id.tv_subline, data.optString("subline"))
            views.setViewVisibility(R.id.updated_bar, android.view.View.VISIBLE)
            views.setViewVisibility(R.id.iv_stale, WidgetCommon.vis(stale))
            views.setTextViewText(R.id.tv_updated, WidgetCommon.updatedLabel(updatedMillis))
            views.setTextColor(
                R.id.tv_updated,
                ContextCompat.getColor(
                    context,
                    if (stale) R.color.kuber_warning_amber else R.color.kuber_text_muted
                )
            )
        }
    }

    private fun colorFor(sign: String): Int = when (sign) {
        "income" -> R.color.kuber_income
        "expense" -> R.color.kuber_expense
        else -> R.color.kuber_text_primary
    }
}
