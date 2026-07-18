package com.grs.kuber.widgets

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import com.grs.kuber.R

/** Quick Actions (4x1). Four launcher buttons, no data sync. */
class QuickActionsWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        val prefs = WidgetCommon.data(context)
        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_quick_actions)
            WidgetTheme.applyCard(views, prefs)
            val accent = WidgetTheme.primary(context, prefs)
            for (icon in listOf(R.id.qa_ic_0, R.id.qa_ic_1, R.id.qa_ic_2, R.id.qa_ic_3)) {
                WidgetTheme.tintIcon(views, icon, accent)
            }
            views.setOnClickPendingIntent(R.id.btn_add_txn, WidgetCommon.deepLink(context, "add-transaction", "qa_add_$id"))
            views.setOnClickPendingIntent(R.id.btn_recurring, WidgetCommon.deepLink(context, "recurring/add", "qa_rec_$id"))
            views.setOnClickPendingIntent(R.id.btn_ask_kuber, WidgetCommon.deepLink(context, "more/ask-kuber", "qa_ask_$id"))
            views.setOnClickPendingIntent(R.id.btn_import_sms, WidgetCommon.deepLink(context, "more/sms-import", "qa_sms_$id"))
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
