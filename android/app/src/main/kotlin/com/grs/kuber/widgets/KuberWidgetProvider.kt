package com.grs.kuber.widgets

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences

/**
 * Base for every Kuber home-screen widget: hands [onUpdate] the widget data
 * the Flutter side wrote (WidgetSyncService → "save" on the widgets channel
 * in MainActivity).
 */
abstract class KuberWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        super.onUpdate(context, appWidgetManager, appWidgetIds)
        onUpdate(context, appWidgetManager, appWidgetIds, WidgetCommon.data(context))
    }

    abstract fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    )
}
