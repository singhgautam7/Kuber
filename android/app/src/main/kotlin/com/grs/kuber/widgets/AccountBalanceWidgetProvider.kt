package com.grs.kuber.widgets

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Bundle
import android.widget.RemoteViews
import androidx.core.content.ContextCompat
import com.grs.kuber.R
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Account Balance (2x1 compact / 2x2 full). Per-instance account chosen via the
 * configuration activity, stored under "acctwidget_<widgetId>". Tap -> account view.
 */
class AccountBalanceWidgetProvider : HomeWidgetProvider() {

    companion object {
        fun accountKey(widgetId: Int) = "acctwidget_$widgetId"
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (id in appWidgetIds) {
            val compact = isCompact(appWidgetManager, id)
            val layout = if (compact) R.layout.widget_account_balance_compact else R.layout.widget_account_balance
            val views = RemoteViews(context.packageName, layout)
            val accountId = widgetData.getString(accountKey(id), null)
            bind(context, views, widgetData, accountId, compact)
            if (accountId != null) {
                views.setOnClickPendingIntent(
                    R.id.widget_root,
                    WidgetCommon.deepLink(context, "more/accounts?viewId=$accountId", "acct_$id")
                )
            } else {
                // Unconfigured — e.g. pinned via requestPinAppWidget, which skips the
                // config activity on many launchers. Tapping opens the account picker
                // for THIS instance so users can pick an account (and place more than
                // one, each for a different account).
                views.setOnClickPendingIntent(R.id.widget_root, configIntent(context, id))
            }
            appWidgetManager.updateAppWidget(id, views)
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle
    ) {
        onUpdate(context, appWidgetManager, intArrayOf(appWidgetId), WidgetCommon.data(context))
    }

    private fun isCompact(mgr: AppWidgetManager, id: Int): Boolean {
        val minH = mgr.getAppWidgetOptions(id)
            .getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 0)
        return minH in 1..109
    }

    /** PendingIntent that opens the account-picker config activity for [widgetId]. */
    private fun configIntent(context: Context, widgetId: Int): PendingIntent {
        val intent = Intent(context, AccountBalanceConfigActivity::class.java).apply {
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        return PendingIntent.getActivity(
            context,
            "acctcfg_$widgetId".hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }

    private fun bind(
        context: Context,
        views: RemoteViews,
        prefs: SharedPreferences,
        accountId: String?,
        compact: Boolean
    ) {
        val emptyId = if (compact) 0 else R.id.state_empty
        if (accountId == null) {
            WidgetCommon.showState(
                views, R.id.state_loading, emptyId, R.id.state_content,
                if (compact) WidgetCommon.State.LOADING else WidgetCommon.State.EMPTY
            )
            return
        }
        val data = WidgetCommon.json(prefs, "acct_$accountId")
        if (data == null) {
            WidgetCommon.showState(
                views, R.id.state_loading, emptyId, R.id.state_content, WidgetCommon.State.LOADING
            )
            return
        }
        WidgetCommon.showState(
            views, R.id.state_loading, emptyId, R.id.state_content, WidgetCommon.State.CONTENT
        )

        val updatedMillis = data.optLong("updatedMillis")
        val stale = WidgetCommon.isStale(updatedMillis)

        views.setTextViewText(R.id.tv_account_name, data.optString("name"))
        views.setTextViewText(R.id.tv_balance, data.optString("balance", "₹0"))
        val balColor = when {
            stale -> R.color.kuber_text_secondary
            data.optString("sign") == "expense" -> R.color.kuber_expense
            else -> R.color.kuber_income
        }
        views.setTextColor(R.id.tv_balance, ContextCompat.getColor(context, balColor))

        if (!compact) {
            views.setViewVisibility(R.id.iv_stale, WidgetCommon.vis(stale))
            views.setTextViewText(R.id.tv_updated, WidgetCommon.updatedLabel(updatedMillis, "Last updated"))
            views.setTextColor(
                R.id.tv_updated,
                ContextCompat.getColor(
                    context,
                    if (stale) R.color.kuber_warning_amber else R.color.kuber_text_secondary
                )
            )
        }
    }
}
