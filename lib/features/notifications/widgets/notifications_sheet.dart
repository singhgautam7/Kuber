import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../data/app_notification.dart';

/// UI-side metadata for [NotificationType]. Kept here (not on the model) so
/// the data layer stays free of Flutter dependencies.
extension NotificationTypeMeta on NotificationType {
  String get groupTitle => switch (this) {
    NotificationType.general => 'General',
    NotificationType.budgetAlert => 'Budget Alerts',
    NotificationType.recurringTransaction => 'Recurring Transactions',
    NotificationType.loanEmi => 'Loan EMI',
    NotificationType.ledgerReminder => 'Ledger Reminders',
    NotificationType.backup => 'Backup',
  };

  IconData get icon => switch (this) {
    NotificationType.general => Icons.notifications_none_rounded,
    NotificationType.budgetAlert => Icons.pie_chart_outline_rounded,
    NotificationType.recurringTransaction => Icons.sync_rounded,
    NotificationType.loanEmi => Icons.account_balance_outlined,
    NotificationType.ledgerReminder => Icons.handshake_outlined,
    NotificationType.backup => Icons.backup_outlined,
  };
}

const _kGroupOrder = [
  NotificationType.general,
  NotificationType.budgetAlert,
  NotificationType.recurringTransaction,
  NotificationType.loanEmi,
  NotificationType.ledgerReminder,
  NotificationType.backup,
];

class NotificationsSheet extends StatelessWidget {
  final List<AppNotification> notifications;
  final VoidCallback onClearAll;
  final void Function(AppNotification) onTapNotification;

  const NotificationsSheet({
    super.key,
    required this.notifications,
    required this.onClearAll,
    required this.onTapNotification,
  });

  static Future<void> show(
    BuildContext context, {
    required List<AppNotification> notifications,
    required VoidCallback onClearAll,
    required void Function(AppNotification) onTapNotification,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NotificationsSheet(
        notifications: notifications,
        onClearAll: onClearAll,
        onTapNotification: onTapNotification,
      ),
    );
  }

  Future<void> _confirmClearAll(BuildContext context) async {
    final cs = Theme.of(context).colorScheme;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Clear all notifications?',
          style: GoogleFonts.inter(fontWeight: FontWeight.w800),
        ),
        content: Text(
          'This will permanently remove all notifications. '
          'This cannot be undone.',
          style: GoogleFonts.inter(color: cs.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Clear all',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: cs.error,
              ),
            ),
          ),
        ],
      ),
    );
    if (ok == true) onClearAll();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final byType = <NotificationType, List<AppNotification>>{};
    for (final t in _kGroupOrder) {
      byType[t] = <AppNotification>[];
    }
    for (final n in notifications) {
      byType[n.type]!.add(n);
    }
    for (final t in byType.keys) {
      byType[t]!.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    final hasAny = notifications.isNotEmpty;
    final unreadCount = notifications.where((n) => n.readAt == null).length;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(KuberRadius.lg),
        ),
        border: Border(
          top: BorderSide(color: cs.outline),
          left: BorderSide(color: cs.outline),
          right: BorderSide(color: cs.outline),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 14, 12),
              child: Row(
                children: [
                  Text(
                    'Notifications',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: cs.onSurface,
                    ),
                  ),
                  if (unreadCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(KuberRadius.full),
                      ),
                      child: Text(
                        '$unreadCount new',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: cs.primary,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  IconButton(
                    onPressed: () =>
                        Navigator.of(context, rootNavigator: true).pop(),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: cs.surfaceContainerHigh,
                      shape: const CircleBorder(),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, thickness: 0.5, color: cs.outline),
            Flexible(
              child: hasAny
                  ? ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                      children: [
                        // Body header — recent-summary on the left,
                        // Clear all on the right (matches Gmail / Slack /
                        // most messaging apps).
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  unreadCount > 0
                                      ? '$unreadCount unread · ${notifications.length} total'
                                      : '${notifications.length} ${notifications.length == 1 ? 'notification' : 'notifications'}',
                                  style: GoogleFonts.inter(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: cs.onSurfaceVariant,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () => _confirmClearAll(context),
                                style: TextButton.styleFrom(
                                  foregroundColor: cs.error,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                icon: Icon(
                                  Icons.delete_outline_rounded,
                                  size: 16,
                                  color: cs.error,
                                ),
                                label: Text(
                                  'Clear all',
                                  style: GoogleFonts.inter(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: cs.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        for (final t in _kGroupOrder)
                          if ((byType[t] ?? const []).isNotEmpty)
                            _Group(
                              type: t,
                              items: byType[t]!,
                              onTap: (n) {
                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).pop();
                                onTapNotification(n);
                              },
                            ),
                      ],
                    )
                  : const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: KuberEmptyState(
                        icon: Icons.notifications_off_outlined,
                        title: 'No notifications yet',
                        description:
                            'Budget alerts, recurring runs, loan EMIs and ledger reminders will show up here.',
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  final NotificationType type;
  final List<AppNotification> items;
  final void Function(AppNotification) onTap;

  const _Group({required this.type, required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: KuberSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, KuberSpacing.sm),
            child: Text(
              type.groupTitle.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(KuberRadius.md),
              border: Border.all(color: cs.outline),
            ),
            child: Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  _Row(item: items[i], onTap: () => onTap(items[i])),
                  if (i < items.length - 1)
                    Divider(height: 1, color: cs.outline, indent: 60),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final AppNotification item;
  final VoidCallback onTap;
  const _Row({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final unread = item.readAt == null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(KuberRadius.md),
      child: Container(
        decoration: BoxDecoration(
          color: unread
              ? cs.primary.withValues(alpha: 0.06)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(KuberRadius.md),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 3,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: unread ? cs.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 9),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: unread
                        ? cs.primary.withValues(alpha: 0.14)
                        : cs.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(KuberRadius.sm),
                  ),
                  child: Icon(
                    item.type.icon,
                    size: 18,
                    color: unread ? cs.primary : cs.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: unread
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: cs.onSurface,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: cs.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _relative(item.createdAt),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    if (unread) ...[
                      const SizedBox(height: 6),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: cs.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _relative(DateTime t) {
    final now = DateTime.now();
    final d = now.difference(t);
    if (d.inSeconds < 45) return 'just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    if (d.inDays < 7) return '${d.inDays}d ago';
    if (d.inDays < 30) return '${(d.inDays / 7).floor()}w ago';
    if (d.inDays < 365) return '${(d.inDays / 30).floor()}mo ago';
    return '${(d.inDays / 365).floor()}y ago';
  }
}
