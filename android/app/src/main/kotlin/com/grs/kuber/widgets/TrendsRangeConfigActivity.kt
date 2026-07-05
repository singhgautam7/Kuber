package com.grs.kuber.widgets

import android.appwidget.AppWidgetManager

/** Configuration activity for the Trends widget (pick default 7D / 4W / 6M range). */
class TrendsRangeConfigActivity : WidgetConfigActivity() {
    override val routeName: String = "range"

    override fun onConfirm(value: String) {
        val range = if (value in ChartWithRangeWidgetProvider.RANGES) value else "7D"
        WidgetCommon.data(this).edit()
            .putString(ChartWithRangeWidgetProvider.rangeKey(appWidgetId), range)
            .apply()
        ChartWithRangeWidgetProvider().onUpdate(
            this,
            AppWidgetManager.getInstance(this),
            intArrayOf(appWidgetId),
            WidgetCommon.data(this)
        )
    }
}
