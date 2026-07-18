class PrefsKeys {
  static const onboarded = 'kuber_onboarded';
  static const tutorialComplete = 'tutorial_complete';
  static const onboardingTutorialNudgePending =
      'kuber_onboarding_tutorial_nudge_pending';
  static const advancedSetupCompleted = 'kuber_advanced_setup_completed';
  static const userName = 'kuber_user_name';
  static const currency = 'currency';
  static const themeMode = 'theme_mode';
  static const themeVariant = 'theme_variant';
  static const swipeMode = 'swipe_mode';
  static const biometricsEnabled = 'biometrics_enabled';
  static const numberSystem = 'number_system';
  static const language = 'kuber_language';

  // Migration Keys
  static const migratedTxnLinkedRuleV1 = 'kuber_migrated_txn_linked_rule_v1';
  static const migratedSeedLedgerCategoryV1 =
      'kuber_migrated_seed_ledger_category_v1';
  static const migratedSeedLoanInvestmentCategoryV1 =
      'kuber_migrated_seed_loan_investment_category_v1';
  static const migratedAttachmentsV1 = 'kuber_migrated_attachments_tags_v1';
  static const migratedSuggestionBackfillV1 =
      'kuber_migrated_suggestion_backfill_v1';
  static const migratedStoriesPositionV2 = 'kuber_migrated_stories_position_v2';
  static const migratedStoryResetV1 = 'kuber_migrated_story_reset_v1';

  // Info Seen Keys
  static const seenInfoAccounts = 'seen_info_accounts';
  static const seenInfoCategories = 'seen_info_categories';
  static const seenInfoTags = 'seen_info_tags';
  static const seenInfoBudgets = 'seen_info_budgets';
  static const seenInfoRecurring = 'seen_info_recurring';
  static const seenInfoLedger = 'seen_info_ledger';
  static const seenInfoLoans = 'seen_info_loans';
  static const seenInfoInvestments = 'seen_info_investments';

  // Quick Add
  static const defaultAccountId = 'kuber_default_account_id';

  // Privacy
  static const privacyMode = 'kuber_privacy_mode';

  // Analytics thresholds
  static const thresholdFloor = 'kuber_threshold_floor';
  static const thresholdCeiling = 'kuber_threshold_ceiling';
  static const navBarStyle = 'nav_bar_style';
  static const moreTabLayout = 'more_tab_layout';

  // Analytics filter
  static const analyticsFilterType = 'kuber_analytics_filter_type';
  static const analyticsFilterFrom = 'kuber_analytics_filter_from';
  static const analyticsFilterTo = 'kuber_analytics_filter_to';

  // Notifications
  static const notificationPermissionAsked =
      'kuber_notification_permission_asked';

  // Stories
  static const lastStoryGenerationDate = 'kuber_last_story_generation_date';
  static const welcomeStoryGenerated = 'kuber_welcome_story_generated';

  // Kuber Notes
  static const notesOnboardingSeen = 'notes_onboarding_seen';
  static const notesViewMode = 'notes_view_mode'; // 'list' | 'grid'
  static const notesBiometricRequired = 'kuber_notes_biometric_required';

  // Upcoming Events widget migration (one-time Recurring widget replacement)
  static const upcomingEventsWidgetMigrated =
      'kuber_upcoming_events_widget_migrated_v1';

  // Kuber Pro — last-known Play Billing prices (JSON), for offline paywall
  static const cachedProPrices = 'cached_pro_prices_v1';

  // Kuber Pro — promo campaign remote config
  static const promoConfigCached = 'kuber_promo_config_cached';
  static const promoConfigFetchedAt = 'kuber_promo_config_fetched_at';
  static const promoBannerSessionDismissed =
      'kuber_promo_banner_session_dismissed';

  // Kuber Pro — Ask Kuber weekly free-tier counter. The full key appends the
  // ISO week, e.g. `ask_kuber_messages_week_2026-W28`, so it resets weekly
  // with no cleanup job.
  static const askKuberWeekPrefix = 'ask_kuber_messages_week_';
}
