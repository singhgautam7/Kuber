package com.grs.kuber.widgets

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import com.grs.kuber.R

/** Quick Actions (4x1). Four launcher buttons, no data sync. */
class QuickActionsWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_quick_actions)
            views.setOnClickPendingIntent(R.id.btn_add_txn, WidgetCommon.deepLink(context, "add-transaction", "qa_add_$id"))
            views.setOnClickPendingIntent(R.id.btn_recurring, WidgetCommon.deepLink(context, "recurring/add", "qa_rec_$id"))
            views.setOnClickPendingIntent(R.id.btn_ask_kuber, WidgetCommon.deepLink(context, "more/ask-kuber", "qa_ask_$id"))
            views.setOnClickPendingIntent(R.id.btn_import_sms, WidgetCommon.deepLink(context, "more/sms-import", "qa_sms_$id"))
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
