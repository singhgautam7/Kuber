package com.grs.kuber.widgets

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import com.grs.kuber.R
import es.antonborri.home_widget.HomeWidgetProvider

/** SMS Import Badge (2x1). Always visible; 0 -> "All caught up". Tap -> Import SMS. */
class SmsImportBadgeWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_sms_import_badge)
            val data = WidgetCommon.json(widgetData, "sms_badge")
            if (data == null) {
                WidgetCommon.showState(views, R.id.state_loading, 0, R.id.state_content, WidgetCommon.State.LOADING)
            } else {
                WidgetCommon.showState(views, R.id.state_loading, 0, R.id.state_content, WidgetCommon.State.CONTENT)
                val count = data.optInt("count", 0)
                views.setTextViewText(R.id.tv_count, count.toString())
                views.setTextViewText(
                    R.id.tv_caption,
                    if (count > 0) context.getString(R.string.w_unreviewed_messages)
                    else context.getString(R.string.w_all_caught_up)
                )
            }
            views.setOnClickPendingIntent(
                R.id.widget_root,
                WidgetCommon.deepLink(context, "more/sms-import", "sms_$id")
            )
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
