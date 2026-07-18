package com.grs.kuber.widgets

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import com.grs.kuber.R
import es.antonborri.home_widget.HomeWidgetProvider

/** Notes (4x3). Up to 3 recent notes. Add -> new note; row -> editor; footer -> Notes. */
class NotesWidgetProvider : HomeWidgetProvider() {

    private data class RowIds(val row: Int, val title: Int, val preview: Int, val time: Int)

    private val rows = listOf(
        RowIds(R.id.note_0, R.id.note_0_title, R.id.note_0_preview, R.id.note_0_time),
        RowIds(R.id.note_1, R.id.note_1_title, R.id.note_1_preview, R.id.note_1_time),
        RowIds(R.id.note_2, R.id.note_2_title, R.id.note_2_preview, R.id.note_2_time)
    )

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_notes)
            WidgetTheme.applyCard(views, widgetData)
            val accent = WidgetTheme.primary(context, widgetData)
            WidgetTheme.tintIcon(views, R.id.iv_hicon, accent)
            views.setTextColor(R.id.add_note, accent)
            views.setTextColor(R.id.add_note_empty, accent)
            views.setTextColor(R.id.footer_link, accent)
            bind(context, views, widgetData, id)
            views.setOnClickPendingIntent(R.id.widget_root, WidgetCommon.deepLink(context, "more/notes", "notes_root_$id"))
            views.setOnClickPendingIntent(R.id.footer_link, WidgetCommon.deepLink(context, "more/notes", "notes_all_$id"))
            views.setOnClickPendingIntent(R.id.add_note, WidgetCommon.deepLink(context, "notes/new", "notes_add_$id"))
            views.setOnClickPendingIntent(R.id.add_note_empty, WidgetCommon.deepLink(context, "notes/new", "notes_add2_$id"))
            appWidgetManager.updateAppWidget(id, views)
        }
    }

    private fun bind(context: Context, views: RemoteViews, prefs: SharedPreferences, widgetId: Int) {
        val data = WidgetCommon.json(prefs, "notes")
        if (data == null) {
            WidgetCommon.showState(views, R.id.state_loading, R.id.state_empty, R.id.state_content, WidgetCommon.State.LOADING)
            return
        }
        val notes = data.optJSONArray("notes")
        if (data.optString("state") == "empty" || notes == null || notes.length() == 0) {
            WidgetCommon.showState(views, R.id.state_loading, R.id.state_empty, R.id.state_content, WidgetCommon.State.EMPTY)
            return
        }
        WidgetCommon.showState(views, R.id.state_loading, R.id.state_empty, R.id.state_content, WidgetCommon.State.CONTENT)
        for ((i, r) in rows.withIndex()) {
            if (i >= notes.length()) {
                views.setViewVisibility(r.row, View.GONE)
                continue
            }
            val n = notes.getJSONObject(i)
            views.setViewVisibility(r.row, View.VISIBLE)
            views.setTextViewText(r.title, n.optString("title"))
            views.setTextViewText(r.preview, n.optString("preview"))
            views.setTextViewText(r.time, n.optString("time"))
            views.setOnClickPendingIntent(
                r.row,
                WidgetCommon.deepLink(context, n.optString("path", "more/notes"), "notes_${widgetId}_$i")
            )
        }
    }
}
