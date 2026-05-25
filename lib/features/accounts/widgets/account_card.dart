// Single-account card for the overhauled Accounts page.
//
// Hierarchy (top → bottom):
//   - Top row: squircle icon | name + inline DEFAULT pill | quick-add button
//   - Meta row: TYPE · **** last4 (uppercase, tracked, no separate chip)
//   - Mid row: "Available Balance" / "Outstanding" label + amount
//              (+ "Limit" on the right for credit cards)
//   - Credit cards: utilization bar (color steps green→amber→red) + status line
//   - Optional last-activity strip (merchant · relative time · ±amount)
//
// Negative-balance treatment:
//   - For credit cards the amount stays in `onSurface`; the LABEL
//     ("Outstanding") and the utilization fill carry the colour. The
//     amount is allowed to render in `cs.error` only if the underlying
//     account is genuinely negative for a non-CC type (rare).
//   - For bank/cash accounts a "−" prefix is enough; we don't paint the
//     whole number red.
//
// Last-activity strip is hidden when no recent transaction is available.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/account_helpers.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/category_icon.dart';
import '../../settings/providers/settings_provider.dart'
    show formatterProvider, privacyModeProvider;
import '../../transactions/data/transaction.dart';
import '../data/account.dart';
import '../providers/account_provider.dart';

class AccountCard extends ConsumerWidget {
  final Account account;
  final double balance;
  final bool isDefault;
  final VoidCallback onTap;
  final VoidCallback onQuickAdd;

  const AccountCard({
    super.key,
    required this.account,
    required this.balance,
    required this.isDefault,
    required this.onTap,
    required this.onQuickAdd,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final fmt = ref.watch(formatterProvider);
    final masked = ref.watch(privacyModeProvider);
    final lastTx = ref
        .watch(accountLatestTransactionProvider(account.id))
        .valueOrNull;

    final accentColor = resolveAccountColor(account);
    final iconData = resolveAccountIcon(account);
    final isCC = account.isCreditCard;

    // For CC, `balance` is the OUTSTANDING (negative number means spent).
    // We display the absolute outstanding as a positive figure under an
    // "Outstanding" label, which reads more naturally than a screaming
    // negative amount.
    final outstanding = isCC ? balance.abs() : balance.abs();
    final showAsNeg = isCC ? balance < 0 : balance < 0;

    final amountColor = (isCC || !showAsNeg) ? cs.onSurface : cs.error;
    final amountString = maskAmount(
      '${(!isCC && showAsNeg) ? '−' : ''}${fmt.formatCurrency(outstanding)}',
      masked,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(KuberRadius.lg),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(KuberRadius.lg),
            border: Border.all(color: cs.outline),
          ),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Top: icon, name, default pill, quick-add ----------------
              Row(
                children: [
                  CategoryIcon.square(
                    icon: iconData,
                    rawColor: accentColor,
                    size: 44,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                account.name,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w700,
                                  color: cs.onSurface,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                            if (isDefault) ...[
                              const SizedBox(width: 8),
                              const _DefaultPill(),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        _MetaRow(
                          type: _typeFor(account),
                          last4: account.last4Digits,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _QuickAddButton(onTap: onQuickAdd),
                ],
              ),
              const SizedBox(height: 12),

              // --- Mid: label + amount (+ limit on the right for CC) -------
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isCC ? 'OUTSTANDING' : 'AVAILABLE BALANCE',
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: isCC && balance < 0
                                ? cs.error
                                : cs.onSurfaceVariant,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          amountString,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: amountColor,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isCC && account.creditLimit != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'LIMIT',
                            style: GoogleFonts.inter(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurfaceVariant,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            maskAmount(
                              fmt.formatCurrency(account.creditLimit!),
                              masked,
                            ),
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              // --- Credit-card utilization --------------------------------
              if (isCC && account.creditLimit != null) ...[
                const SizedBox(height: 12),
                _Utilization(
                  outstanding: outstanding,
                  limit: account.creditLimit!,
                  fmt: fmt,
                  masked: masked,
                ),
              ],

              // --- Last activity -------------------------------------------
              if (lastTx != null) ...[
                const SizedBox(height: 12),
                _LastActivityRow(transaction: lastTx, fmt: fmt, masked: masked),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _typeFor(Account a) {
    if (a.isCreditCard) return 'CREDIT CARD';
    switch (a.type.toLowerCase()) {
      case 'bank':
        return 'BANK';
      case 'card':
        return 'CREDIT CARD';
      case 'wallet':
        return 'WALLET';
      case 'cash':
        return 'CASH';
      default:
        return a.type.toUpperCase();
    }
  }
}

class _DefaultPill extends StatelessWidget {
  const _DefaultPill();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.12),
        border: Border.all(color: cs.primary.withValues(alpha: 0.30)),
        borderRadius: BorderRadius.circular(KuberRadius.sm),
      ),
      child: Text(
        'DEFAULT',
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: cs.primary,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final String type;
  final String? last4;
  const _MetaRow({required this.type, this.last4});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(
          type,
          style: GoogleFonts.inter(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: cs.onSurfaceVariant,
            letterSpacing: 0.6,
          ),
        ),
        if (last4 != null && last4!.isNotEmpty) ...[
          const SizedBox(width: 6),
          Container(
            width: 3,
            height: 3,
            decoration: BoxDecoration(
              color: cs.onSurfaceVariant.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '**** $last4',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: cs.onSurfaceVariant,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ],
    );
  }
}

class _QuickAddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _QuickAddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(KuberRadius.md + 2),
        child: Tooltip(
          message: 'Add transaction',
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              border: Border.all(color: cs.outline),
              borderRadius: BorderRadius.circular(KuberRadius.md + 2),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.add_rounded,
              size: 18,
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _Utilization extends StatelessWidget {
  final double outstanding;
  final double limit;
  final dynamic fmt; // formatter from formatterProvider
  final bool masked;
  const _Utilization({
    required this.outstanding,
    required this.limit,
    required this.fmt,
    required this.masked,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final rawPct = limit <= 0 ? 0.0 : outstanding / limit;
    final pct = rawPct.clamp(0.0, 1.0);
    final available = (limit - outstanding).clamp(0.0, double.infinity);

    // Color steps — green < 30%, amber 30–<100%, red at or over 100%.
    // Over-limit is checked against the raw (un-clamped) ratio so the bar
    // clearly turns red the moment outstanding == limit.
    final fillColor = rawPct >= 1.0
        ? cs.error
        : rawPct < 0.30
        ? cs.tertiary
        : const Color(0xFFF59E0B); // warning — no slot on ColorScheme

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: SizedBox(
            height: 6,
            child: Stack(
              children: [
                Container(color: cs.surfaceContainerHigh),
                FractionallySizedBox(
                  widthFactor: pct,
                  child: Container(color: fillColor),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: cs.onSurfaceVariant,
                  ),
                  children: [
                    TextSpan(
                      text: '${(pct * 100).toStringAsFixed(1)}%',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    const TextSpan(text: ' utilized'),
                  ],
                ),
              ),
            ),
            Text(
              '${maskAmount(fmt.formatCurrency(available), masked)} available',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LastActivityRow extends StatelessWidget {
  final Transaction transaction;
  final dynamic fmt;
  final bool masked;
  const _LastActivityRow({
    required this.transaction,
    required this.fmt,
    required this.masked,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isExpense = transaction.type == 'expense';
    final amountColor = isExpense ? cs.error : cs.tertiary;
    final relTime = _formatRelative(transaction.createdAt);

    return Container(
      padding: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: cs.outline.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule_rounded,
            size: 13,
            color: cs.onSurfaceVariant.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              transaction.name,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '· $relTime',
            style: GoogleFonts.inter(
              fontSize: 11.5,
              color: cs.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text(
            '${isExpense ? '−' : '+'}'
            '${maskAmount(fmt.formatCurrency(transaction.amount.abs()), masked)}',
            style: GoogleFonts.inter(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatRelative(DateTime at) {
    final now = DateTime.now();
    final diff = now.difference(at);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(at);
  }
}
