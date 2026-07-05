package com.grs.kuber.widgets

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import com.grs.kuber.R

/** Quick Actions Extended (4x3). 8 launcher buttons, no data sync. */
class QuickActionsExtendedWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_quick_actions_extended)
            views.setOnClickPendingIntent(R.id.btn_add_txn, WidgetCommon.deepLink(context, "add-transaction", "qax_add_$id"))
            views.setOnClickPendingIntent(R.id.btn_recurring, WidgetCommon.deepLink(context, "recurring/add", "qax_rec_$id"))
            views.setOnClickPendingIntent(R.id.btn_add_loan, WidgetCommon.deepLink(context, "loans/add", "qax_loan_$id"))
            views.setOnClickPendingIntent(R.id.btn_invest, WidgetCommon.deepLink(context, "investments/add", "qax_inv_$id"))
            views.setOnClickPendingIntent(R.id.btn_lend_borrow, WidgetCommon.deepLink(context, "ledger/add", "qax_led_$id"))
            views.setOnClickPendingIntent(R.id.btn_ask_kuber, WidgetCommon.deepLink(context, "more/ask-kuber", "qax_ask_$id"))
            views.setOnClickPendingIntent(R.id.btn_calculators, WidgetCommon.deepLink(context, "more/tools", "qax_calc_$id"))
            views.setOnClickPendingIntent(R.id.btn_notes, WidgetCommon.deepLink(context, "more/notes", "qax_notes_$id"))
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
