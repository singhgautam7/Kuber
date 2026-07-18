package com.grs.kuber.widgets

import android.content.Context
import android.content.SharedPreferences
import android.content.res.ColorStateList
import android.os.Build
import android.widget.RemoteViews
import androidx.core.content.ContextCompat
import com.grs.kuber.R

/**
 * Theme-family support for the home-screen widgets.
 *
 * The Flutter side persists the active family name under `theme_family`
 * (see WidgetSyncService._syncTheme). Neutral chrome (text, borders, muted
 * fills, skeletons) is defined as alpha overlays in colors.xml, so it tints
 * itself over the per-family opaque card fill; this object only resolves the
 * pieces that carry the family accent: the card background, accent/income/
 * expense colors, and the accent-tinted drawables. Light vs dark follows the
 * OS (values-night), matching the pre-theming behavior.
 */
object WidgetTheme {

    enum class Family { SIGNATURE, FLEWTUBE, WOOFSAPP, PURRHUB, HONKPE, SQUEAKDIN, OINKZON }

    fun family(prefs: SharedPreferences): Family = when (prefs.getString("theme_family", null)) {
        "flewtube" -> Family.FLEWTUBE
        "woofsapp" -> Family.WOOFSAPP
        "purrhub" -> Family.PURRHUB
        "honkpe" -> Family.HONKPE
        "squeakdin" -> Family.SQUEAKDIN
        "oinkzon" -> Family.OINKZON
        else -> Family.SIGNATURE
    }

    // ---- resolved accent colors --------------------------------------------

    fun primary(context: Context, prefs: SharedPreferences): Int =
        color(context, when (family(prefs)) {
            Family.SIGNATURE -> R.color.kuber_primary
            Family.FLEWTUBE -> R.color.kuber_flewtube_primary
            Family.WOOFSAPP -> R.color.kuber_woofsapp_primary
            Family.PURRHUB -> R.color.kuber_purrhub_primary
            Family.HONKPE -> R.color.kuber_honkpe_primary
            Family.SQUEAKDIN -> R.color.kuber_squeakdin_primary
            Family.OINKZON -> R.color.kuber_oinkzon_primary
        })

    fun income(context: Context, prefs: SharedPreferences): Int =
        color(context, when (family(prefs)) {
            Family.SIGNATURE -> R.color.kuber_income
            Family.FLEWTUBE -> R.color.kuber_flewtube_income
            Family.WOOFSAPP -> R.color.kuber_woofsapp_income
            Family.PURRHUB -> R.color.kuber_purrhub_income
            Family.HONKPE -> R.color.kuber_honkpe_income
            Family.SQUEAKDIN -> R.color.kuber_squeakdin_income
            Family.OINKZON -> R.color.kuber_oinkzon_income
        })

    fun expense(context: Context, prefs: SharedPreferences): Int =
        color(context, when (family(prefs)) {
            Family.SIGNATURE -> R.color.kuber_expense
            Family.FLEWTUBE -> R.color.kuber_flewtube_expense
            Family.WOOFSAPP -> R.color.kuber_woofsapp_expense
            Family.PURRHUB -> R.color.kuber_purrhub_expense
            Family.HONKPE -> R.color.kuber_honkpe_expense
            Family.SQUEAKDIN -> R.color.kuber_squeakdin_expense
            Family.OINKZON -> R.color.kuber_oinkzon_expense
        })

    fun warning(context: Context): Int = color(context, R.color.kuber_warning_amber)

    fun textPrimary(context: Context): Int = color(context, R.color.kuber_text_primary)

    fun textSecondary(context: Context): Int = color(context, R.color.kuber_text_secondary)

    /** Amount color for an income/expense sign flag, stale-aware. */
    fun amountColor(
        context: Context,
        prefs: SharedPreferences,
        sign: String,
        stale: Boolean = false
    ): Int = when {
        stale -> textSecondary(context)
        sign == "income" -> income(context, prefs)
        sign == "expense" -> expense(context, prefs)
        else -> textPrimary(context)
    }

    private fun color(context: Context, res: Int): Int = ContextCompat.getColor(context, res)

    // ---- family drawables ---------------------------------------------------

    fun cardBg(prefs: SharedPreferences): Int = when (family(prefs)) {
        Family.SIGNATURE -> R.drawable.widget_card_bg
        Family.FLEWTUBE -> R.drawable.widget_card_bg_flewtube
        Family.WOOFSAPP -> R.drawable.widget_card_bg_woofsapp
        Family.PURRHUB -> R.drawable.widget_card_bg_purrhub
        Family.HONKPE -> R.drawable.widget_card_bg_honkpe
        Family.SQUEAKDIN -> R.drawable.widget_card_bg_squeakdin
        Family.OINKZON -> R.drawable.widget_card_bg_oinkzon
    }

    fun markBg(prefs: SharedPreferences): Int = when (family(prefs)) {
        Family.SIGNATURE -> R.drawable.widget_kuber_mark_bg
        Family.FLEWTUBE -> R.drawable.widget_kuber_mark_bg_flewtube
        Family.WOOFSAPP -> R.drawable.widget_kuber_mark_bg_woofsapp
        Family.PURRHUB -> R.drawable.widget_kuber_mark_bg_purrhub
        Family.HONKPE -> R.drawable.widget_kuber_mark_bg_honkpe
        Family.SQUEAKDIN -> R.drawable.widget_kuber_mark_bg_squeakdin
        Family.OINKZON -> R.drawable.widget_kuber_mark_bg_oinkzon
    }

    fun chipSelectedBg(prefs: SharedPreferences): Int = when (family(prefs)) {
        Family.SIGNATURE -> R.drawable.widget_chip_bg_selected
        Family.FLEWTUBE -> R.drawable.widget_chip_bg_selected_flewtube
        Family.WOOFSAPP -> R.drawable.widget_chip_bg_selected_woofsapp
        Family.PURRHUB -> R.drawable.widget_chip_bg_selected_purrhub
        Family.HONKPE -> R.drawable.widget_chip_bg_selected_honkpe
        Family.SQUEAKDIN -> R.drawable.widget_chip_bg_selected_squeakdin
        Family.OINKZON -> R.drawable.widget_chip_bg_selected_oinkzon
    }

    fun pillReminderBg(prefs: SharedPreferences): Int = when (family(prefs)) {
        Family.SIGNATURE -> R.drawable.widget_pill_reminder
        Family.FLEWTUBE -> R.drawable.widget_pill_reminder_flewtube
        Family.WOOFSAPP -> R.drawable.widget_pill_reminder_woofsapp
        Family.PURRHUB -> R.drawable.widget_pill_reminder_purrhub
        Family.HONKPE -> R.drawable.widget_pill_reminder_honkpe
        Family.SQUEAKDIN -> R.drawable.widget_pill_reminder_squeakdin
        Family.OINKZON -> R.drawable.widget_pill_reminder_oinkzon
    }

    fun pillSipBg(prefs: SharedPreferences): Int = when (family(prefs)) {
        Family.SIGNATURE -> R.drawable.widget_pill_sip
        Family.FLEWTUBE -> R.drawable.widget_pill_sip_flewtube
        Family.WOOFSAPP -> R.drawable.widget_pill_sip_woofsapp
        Family.PURRHUB -> R.drawable.widget_pill_sip_purrhub
        Family.HONKPE -> R.drawable.widget_pill_sip_honkpe
        Family.SQUEAKDIN -> R.drawable.widget_pill_sip_squeakdin
        Family.OINKZON -> R.drawable.widget_pill_sip_oinkzon
    }

    // ---- RemoteViews helpers ------------------------------------------------

    /** Swaps the root card background to the active family's variant. */
    fun applyCard(views: RemoteViews, prefs: SharedPreferences) {
        views.setInt(R.id.widget_root, "setBackgroundResource", cardBg(prefs))
    }

    /** Tints an ImageView glyph (header icons and similar) to [color]. */
    fun tintIcon(views: RemoteViews, viewId: Int, color: Int) {
        runCatching { views.setInt(viewId, "setColorFilter", color) }
    }

    /**
     * Tints a ProgressBar's fill to [color] on API 31+. Older devices keep
     * the static drawable colors (Signature palette); progressDrawable is not
     * swappable through RemoteViews.
     */
    fun tintProgress(views: RemoteViews, viewId: Int, color: Int) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            runCatching {
                views.setColorStateList(
                    viewId,
                    "setProgressTintList",
                    ColorStateList.valueOf(color)
                )
            }
        }
    }
}
