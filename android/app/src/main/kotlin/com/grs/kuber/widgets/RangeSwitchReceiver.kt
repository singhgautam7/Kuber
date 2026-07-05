package com.grs.kuber.widgets

import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/** Handles Trends range-chip taps: persists the per-instance range and refreshes the widget. */
class RangeSwitchReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != "com.grs.kuber.widgets.RANGE_SWITCH") return
        val widgetId = intent.getIntExtra("widgetId", AppWidgetManager.INVALID_APPWIDGET_ID)
        val range = intent.getStringExtra("range") ?: return
        if (widgetId == AppWidgetManager.INVALID_APPWIDGET_ID) return

        WidgetCommon.data(context).edit()
            .putString(ChartWithRangeWidgetProvider.rangeKey(widgetId), range)
            .apply()

        ChartWithRangeWidgetProvider().onUpdate(
            context,
            AppWidgetManager.getInstance(context),
            intArrayOf(widgetId),
            WidgetCommon.data(context)
        )
    }
}
