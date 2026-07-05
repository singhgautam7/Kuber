package com.grs.kuber.widgets

import android.appwidget.AppWidgetManager
import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Base for the two widget configuration activities. Boots the Flutter engine
 * directly onto a config route (passing the appWidgetId) and exposes a method
 * channel the Flutter screen calls on Confirm / Cancel. Defaults the result to
 * CANCELED so backing out does not place the widget.
 */
abstract class WidgetConfigActivity : FlutterFragmentActivity() {

    protected var appWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID

    /** Route segment under /widget-config (e.g. "account" or "range"). */
    protected abstract val routeName: String

    /** Persist the chosen value and refresh the widget instance. */
    protected abstract fun onConfirm(value: String)

    override fun onCreate(savedInstanceState: Bundle?) {
        appWidgetId = intent?.extras?.getInt(
            AppWidgetManager.EXTRA_APPWIDGET_ID,
            AppWidgetManager.INVALID_APPWIDGET_ID
        ) ?: AppWidgetManager.INVALID_APPWIDGET_ID
        setResult(RESULT_CANCELED, Intent().putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId))
        super.onCreate(savedInstanceState)
    }

    override fun getInitialRoute(): String = "/widget-config/$routeName?widgetId=$appWidgetId"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "confirm" -> {
                        onConfirm(call.argument<String>("value") ?: "")
                        setResult(
                            RESULT_OK,
                            Intent().putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
                        )
                        result.success(true)
                        finish()
                    }
                    "cancel" -> {
                        result.success(true)
                        finish()
                    }
                    else -> result.notImplemented()
                }
            }
    }

    companion object {
        const val CHANNEL = "com.grs.kuber/widget_config"
    }
}
