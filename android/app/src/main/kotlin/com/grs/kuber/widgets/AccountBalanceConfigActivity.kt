package com.grs.kuber.widgets

import android.appwidget.AppWidgetManager

/** Configuration activity for the Account Balance widget (pick which account). */
class AccountBalanceConfigActivity : WidgetConfigActivity() {
    override val routeName: String = "account"

    override fun onConfirm(value: String) {
        WidgetCommon.data(this).edit()
            .putString(AccountBalanceWidgetProvider.accountKey(appWidgetId), value)
            .apply()
        AccountBalanceWidgetProvider().onUpdate(
            this,
            AppWidgetManager.getInstance(this),
            intArrayOf(appWidgetId),
            WidgetCommon.data(this)
        )
    }
}
