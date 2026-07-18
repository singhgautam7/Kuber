package com.grs.kuber.widgets

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import androidx.core.content.ContextCompat
import com.grs.kuber.R
import es.antonborri.home_widget.HomeWidgetProvider

/** Upcoming Events (4x2). Up to 4 fixed rows with source-type pills. */
class UpcomingEventsWidgetProvider : HomeWidgetProvider() {

    private data class RowIds(val row: Int, val date: Int, val title: Int, val pill: Int, val amount: Int)

    private val rows = listOf(
        RowIds(R.id.row_0, R.id.row_0_date, R.id.row_0_title, R.id.row_0_pill, R.id.row_0_amount),
        RowIds(R.id.row_1, R.id.row_1_date, R.id.row_1_title, R.id.row_1_pill, R.id.row_1_amount),
        RowIds(R.id.row_2, R.id.row_2_date, R.id.row_2_title, R.id.row_2_pill, R.id.row_2_amount),
        RowIds(R.id.row_3, R.id.row_3_date, R.id.row_3_title, R.id.row_3_pill, R.id.row_3_amount)
    )

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_upcoming_events)
            WidgetTheme.applyCard(views, widgetData)
            val accent = WidgetTheme.primary(context, widgetData)
            WidgetTheme.tintIcon(views, R.id.iv_hicon, accent)
            views.setTextColor(R.id.footer_link, accent)
            bind(context, views, widgetData, id)
            views.setOnClickPendingIntent(
                R.id.widget_root,
                WidgetCommon.deepLink(context, "more/upcoming-events", "events_root_$id")
            )
            views.setOnClickPendingIntent(
                R.id.footer_link,
                WidgetCommon.deepLink(context, "more/upcoming-events", "events_all_$id")
            )
            appWidgetManager.updateAppWidget(id, views)
        }
    }

    private fun bind(context: Context, views: RemoteViews, prefs: SharedPreferences, widgetId: Int) {
        val data = WidgetCommon.json(prefs, "upcoming_events")
        if (data == null) {
            WidgetCommon.showState(views, R.id.state_loading, R.id.state_empty, R.id.state_content, WidgetCommon.State.LOADING)
            return
        }
        val events = data.optJSONArray("events")
        if (data.optString("state") == "empty" || events == null || events.length() == 0) {
            WidgetCommon.showState(views, R.id.state_loading, R.id.state_empty, R.id.state_content, WidgetCommon.State.EMPTY)
            return
        }
        WidgetCommon.showState(views, R.id.state_loading, R.id.state_empty, R.id.state_content, WidgetCommon.State.CONTENT)
        val stale = WidgetCommon.isStale(data.optLong("updatedMillis"))

        for ((i, r) in rows.withIndex()) {
            if (i >= events.length()) {
                views.setViewVisibility(r.row, View.GONE)
                continue
            }
            val e = events.getJSONObject(i)
            views.setViewVisibility(r.row, View.VISIBLE)
            views.setTextViewText(r.date, e.optString("date"))
            views.setTextViewText(r.title, e.optString("title"))
            views.setTextViewText(r.amount, e.optString("amount"))
            views.setTextColor(
                r.amount,
                WidgetTheme.amountColor(context, prefs, e.optString("amountSign"), stale)
            )
            bindPill(context, views, prefs, r.pill, e.optString("sourceType"))
            views.setOnClickPendingIntent(
                r.row,
                WidgetCommon.deepLink(context, e.optString("path", "more/upcoming-events"), "events_${widgetId}_$i")
            )
        }
    }

    private fun bindPill(
        context: Context,
        views: RemoteViews,
        prefs: SharedPreferences,
        pillId: Int,
        type: String
    ) {
        // Reminder and SIP pills carry the family accent / income colors; EMI,
        // recurring, and ledger keep their family-independent identity colors.
        val (bg, color, label) = when (type) {
            "reminder" -> Triple(
                WidgetTheme.pillReminderBg(prefs), WidgetTheme.primary(context, prefs), "REMINDER"
            )
            "emi" -> Triple(
                R.drawable.widget_pill_emi,
                ContextCompat.getColor(context, R.color.kuber_pill_emi_text), "EMI"
            )
            "sip" -> Triple(
                WidgetTheme.pillSipBg(prefs), WidgetTheme.income(context, prefs), "SIP"
            )
            "recurring" -> Triple(
                R.drawable.widget_pill_recurring,
                ContextCompat.getColor(context, R.color.kuber_warning_amber), "RECURRING"
            )
            else -> Triple(
                R.drawable.widget_pill_ledger,
                ContextCompat.getColor(context, R.color.kuber_text_secondary), "LEDGER"
            )
        }
        views.setInt(pillId, "setBackgroundResource", bg)
        views.setTextViewText(pillId, label)
        views.setTextColor(pillId, color)
    }
}
