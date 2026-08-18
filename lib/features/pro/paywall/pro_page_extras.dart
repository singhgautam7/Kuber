import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_service.dart';
import '../../../core/models/info_config.dart';
import '../../../shared/widgets/kuber_comparison_table.dart';
import '../data/user_entitlement.dart';
import 'pro_state.dart';

/// True when the current device previously held a real Pro entitlement that has
/// since lapsed (tier back to `free` but `activatedAt` still set — `revoke`
/// never clears it). Lets the paywall show the "Welcome back" card for lapsed
/// users without touching `KuberProState`. Read-only; recomputes when
/// entitlement changes.
final hadPriorProProvider = Provider<bool>((ref) {
  // Recompute when entitlement transitions (e.g. a sub lapses this session).
  ref.watch(kuberProStateProvider);
  final isar = ref.read(isarProvider);
  final row = isar.collection<UserEntitlement>().getSync(0);
  if (row == null) return false;
  return EntitlementTier.coerce(row.tier) == EntitlementTier.free &&
      row.activatedAt != null;
});

/// Copy for the "About Kuber Pro" info sheet, opened from the paywall app bar's
/// info button. Verbatim from the design's `info-sheet-about-pro.md`.
const kAboutProInfoConfig = KuberInfoConfig(
  title: 'About Kuber Pro',
  description:
      'Kuber Pro unlocks every feature and helps fund development. No account '
      'is needed and nothing moves to the cloud.',
  items: [
    KuberInfoItem(
      icon: Icons.workspace_premium_rounded,
      title: 'What Kuber Pro is',
      description:
          'One subscription or a one-time purchase unlocks every gated '
          'feature. Everything stays on your device, offline, with no account.',
    ),
    KuberInfoItem(
      icon: Icons.credit_card_rounded,
      title: 'Billing is Google Play',
      description:
          'Google Play handles payment. Kuber never sees your card or payment '
          'details. Prices are shown by Play in your local currency.',
    ),
    KuberInfoItem(
      icon: Icons.timer_outlined,
      title: 'Free trial',
      description:
          'New yearly customers get a 14-day free trial through Google Play. '
          'You are charged only when the trial ends, and you can cancel before '
          'then.',
    ),
    KuberInfoItem(
      icon: Icons.cancel_outlined,
      title: 'Cancel anytime',
      description:
          'Cancel from the Play Store subscriptions screen. You keep Pro until '
          'the end of the current period. Nothing is deleted when Pro ends.',
    ),
    KuberInfoItem(
      icon: Icons.restore_rounded,
      title: 'Restore across devices',
      description:
          'Restore purchases works on any device signed in to the same Google '
          'account. Refunds follow Google Play\'s refund policy.',
    ),
    KuberInfoItem(
      icon: Icons.local_cafe_rounded,
      title: 'Supporting Kuber',
      description:
          'The Buy me a coffee tips are a one-time thank you. They unlock no '
          'features and are not a subscription.',
    ),
  ],
);

/// The comparison-table content: the live gated features (Multi-currency
/// dropped — currency selection is free) grouped as in the design, plus the
/// always-free core row. Limits are the shipped gating in
/// `specs/pro-gating-enabled.md` and must not change here.
const kProComparisonRows = <ComparisonEntry>[
  ComparisonGroup('Advanced features'),
  ComparisonRow(
    icon: Icons.insert_chart_outlined_rounded,
    feature: 'Advanced Analytics',
    free: 'Basic charts',
    pro: 'Full trends + filters',
  ),
  ComparisonRow(
    icon: Icons.sms_outlined,
    feature: 'SMS Import',
    free: '5 per week',
    pro: 'Unlimited',
  ),
  ComparisonRow(
    icon: Icons.notifications_active_outlined,
    feature: 'Reminders',
    free: 'Not included',
    pro: 'Included',
  ),
  ComparisonRow(
    icon: Icons.backup_outlined,
    feature: 'Automatic Backups',
    free: 'Manual only',
    pro: 'Automatic',
  ),
  ComparisonRow(
    icon: Icons.palette_outlined,
    feature: 'Custom themes',
    free: 'Signature only',
    pro: '7 themes',
  ),
  ComparisonGroup('Usage limits'),
  ComparisonRow(
    icon: Icons.sticky_note_2_outlined,
    feature: 'Kuber Notes',
    free: '2 notes',
    pro: 'Unlimited',
  ),
  ComparisonRow(
    icon: Icons.auto_awesome_rounded,
    feature: 'Ask Kuber',
    free: '5 per week',
    pro: 'Unlimited',
  ),
  ComparisonRow(
    icon: Icons.credit_card_rounded,
    feature: 'Kuber Cards',
    free: '2 cards',
    pro: 'Unlimited',
  ),
  ComparisonGroup('Always free for everyone'),
  ComparisonRow(
    icon: Icons.favorite_border_rounded,
    feature: 'Core features',
    free: 'All included',
    pro: 'All included',
    freeChecked: true,
  ),
];
