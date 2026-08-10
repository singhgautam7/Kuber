import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/info_table.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../accounts/providers/account_provider.dart';
import '../../accounts/widgets/account_detail_sheet.dart';
import '../data/card_clipboard_service.dart';
import '../data/card_vault_service.dart';
import '../data/stored_card.dart';
import '../providers/kuber_cards_provider.dart';
import 'stored_card_visual.dart';

/// Labels that mark a custom field as sensitive (masked by default, tap-reveal).
const _riskyLabels = ['cvv', 'cvc', 'pin', 'otp', 'password', 'passcode', 'secret'];

bool _isRisky(String label) {
  final l = label.trim().toLowerCase();
  return _riskyLabels.any((r) => l.contains(r));
}

void showCardDetailSheet(BuildContext context, WidgetRef ref, StoredCard card) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (_) => CardDetailSheet(card: card),
  );
}

class CardDetailSheet extends ConsumerStatefulWidget {
  final StoredCard card;
  const CardDetailSheet({super.key, required this.card});

  @override
  ConsumerState<CardDetailSheet> createState() => _CardDetailSheetState();
}

class _CardDetailSheetState extends ConsumerState<CardDetailSheet> {
  DecryptedCard? _dec;
  bool _revealed = false; // session-length reveal of number + expiry
  final Set<int> _revealedCustom = {}; // risky custom fields revealed (10s)
  final Map<int, Timer> _customTimers = {};

  @override
  void initState() {
    super.initState();
    _decrypt();
  }

  Future<void> _decrypt() async {
    final key = ref.read(cardSessionProvider).key;
    if (key == null) return; // locked; secure scaffold will cover the screen
    final dec = await ref
        .read(cardVaultServiceProvider)
        .decryptCard(key: key, card: widget.card);
    if (mounted) setState(() => _dec = dec);
  }

  @override
  void dispose() {
    for (final t in _customTimers.values) {
      t.cancel();
    }
    super.dispose();
  }

  void _copy(String value, String label) {
    CardClipboardService.copy(value);
    showKuberSnackBar(context, 'Copied $label.');
  }

  void _revealCustom(int index) {
    setState(() => _revealedCustom.add(index));
    _customTimers[index]?.cancel();
    _customTimers[index] = Timer(const Duration(seconds: 10), () {
      if (mounted) setState(() => _revealedCustom.remove(index));
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final card = widget.card;
    final dec = _dec;

    final typeLabel = (card.cardType ?? '').isEmpty
        ? 'CARD'
        : '${card.cardType![0].toUpperCase()}${card.cardType!.substring(1)} card'
            .toUpperCase();

    return KuberBottomSheet(
      title: card.nickname,
      subtitle: typeLabel,
      // Edit + Delete in a single row (no Close; the sheet's ✕ handles closing).
      actions: Row(
        children: [
          Expanded(
            child: AppButton(
              label: 'Edit',
              icon: Icons.edit_rounded,
              type: AppButtonType.primary,
              fullWidth: true,
              height: 46,
              onPressed: () {
                Navigator.pop(context);
                context.push('/cards/edit', extra: card);
              },
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: AppButton(
              label: 'Delete',
              icon: Icons.delete_outline_rounded,
              type: AppButtonType.danger,
              fullWidth: true,
              height: 46,
              onPressed: () => _confirmDelete(context),
            ),
          ),
        ],
      ),
      child: dec == null
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          : _content(cs, dec),
    );
  }

  Widget _content(ColorScheme cs, DecryptedCard dec) {
    final hasNumber = (dec.number ?? '').isNotEmpty;

    // The card face is the hero; below it a field table lists number, holder,
    // expiry and network (number + expiry stay masked until "Show details").
    // Long-press any row (or the card) copies that field's underlying value.
    final rows = <InfoTableRow>[
      InfoTableDataRow(
        label: 'Card number',
        value: hasNumber
            ? (_revealed ? _group(dec.number!) : '•••• ${dec.last4 ?? '••••'}')
            : (dec.last4 != null ? '•••• ${dec.last4}' : '••••'),
        onLongPress:
            hasNumber ? () => _copy(dec.number!, 'card number') : null,
      ),
      if ((dec.cardholder ?? '').isNotEmpty)
        InfoTableDataRow(
          label: 'Cardholder',
          value: dec.cardholder!,
          onLongPress: () => _copy(dec.cardholder!, 'cardholder'),
        ),
      if ((dec.expiry ?? '').isNotEmpty)
        InfoTableDataRow(
          label: 'Expiry',
          value: _revealed ? dec.expiry! : '••/••',
          onLongPress: () => _copy(dec.expiry!, 'Expiry'),
        ),
      if ((dec.network ?? '').isNotEmpty)
        InfoTableDataRow(
          label: 'Network',
          value: _titleCase(dec.network!),
          onLongPress: () => _copy(_titleCase(dec.network!), 'network'),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onLongPress:
              hasNumber ? () => _copy(dec.number!, 'card number') : null,
          child: StoredCardVisual(
            nickname: dec.nickname,
            last4: dec.last4,
            bankIcon: dec.bankIcon,
            network: dec.network,
            colorValue: dec.colorValue,
            isGradient: dec.isGradient,
            // Cardholder always shown; expiry masked as ••/•• until revealed.
            cardholder: dec.cardholder,
            expiry: _revealed
                ? dec.expiry
                : ((dec.expiry ?? '').isNotEmpty ? '••/••' : null),
            revealedNumber: _revealed ? dec.number : null,
          ),
        ),
        const SizedBox(height: KuberSpacing.lg),
        if (hasNumber) ...[
          _revealButton(cs),
          const SizedBox(height: KuberSpacing.lg),
        ],
        InfoTable(rows: rows),
        if (dec.customFields.isNotEmpty) ...[
          const SizedBox(height: KuberSpacing.lg),
          _miniLabel(cs, 'CUSTOM FIELDS'),
          const SizedBox(height: KuberSpacing.sm),
          InfoTable(rows: _customRows(dec)),
        ],
        _linkedAccount(cs, dec),
      ],
    );
  }

  /// Reveal toggle. Both states use accent content: hidden reads as a bordered
  /// surface button, shown reads as a primary-tinted button (per the design).
  Widget _revealButton(ColorScheme cs) {
    final shown = _revealed;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _revealed = !_revealed),
        borderRadius: BorderRadius.circular(KuberRadius.md),
        child: Ink(
          height: 48,
          decoration: BoxDecoration(
            color: shown
                ? cs.primary.withValues(alpha: 0.10)
                : cs.surfaceContainer,
            borderRadius: BorderRadius.circular(KuberRadius.md),
            border: Border.all(
              color: shown ? cs.primary.withValues(alpha: 0.40) : cs.outline,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                shown ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                size: 18,
                color: cs.primary,
              ),
              const SizedBox(width: 8),
              Text(
                shown ? 'Hide details' : 'Show details',
                style: localeFont(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: cs.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<InfoTableRow> _customRows(DecryptedCard dec) {
    final rows = <InfoTableRow>[];
    for (var i = 0; i < dec.customFields.length; i++) {
      final f = dec.customFields[i];
      final risky = _isRisky(f.label);
      final revealed = _revealedCustom.contains(i);
      final display = (!risky || revealed)
          ? f.value
          : '•' * (f.value.isEmpty ? 4 : f.value.length.clamp(4, 12));
      rows.add(InfoTableDataRow(
        label: f.label,
        value: display,
        tappable: risky && !revealed,
        valueLeadingIcon: risky
            ? (revealed ? Icons.visibility_off_rounded : Icons.visibility_rounded)
            : null,
        onTap: risky && !revealed ? () => _revealCustom(i) : null,
        onLongPress: () => _copy(f.value, f.label),
      ));
    }
    return rows;
  }

  Widget _linkedAccount(ColorScheme cs, DecryptedCard dec) {
    final id = int.tryParse(dec.linkedAccountId ?? '');
    if (id == null) return const SizedBox.shrink();
    final accountsAsync = ref.watch(accountMapProvider);
    final account = accountsAsync.valueOrNull?[id];
    if (account == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: KuberSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _miniLabel(cs, 'LINKED ACCOUNT'),
          const SizedBox(height: KuberSpacing.sm),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  useRootNavigator: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => AccountDetailSheet(account: account),
                );
              },
              borderRadius: BorderRadius.circular(KuberRadius.md),
              child: Ink(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: cs.surfaceContainer,
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                  border: Border.all(color: cs.outline),
                ),
                child: Row(
                  children: [
                    Icon(Icons.account_balance_wallet_outlined,
                        size: 20, color: cs.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        account.name,
                        style: localeFont(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface),
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        size: 20, color: cs.onSurfaceVariant),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniLabel(ColorScheme cs, String text) => Text(
        text,
        style: localeFont(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.6,
          color: cs.onSurfaceVariant,
        ),
      );

  String _group(String raw) {
    final digits = raw.replaceAll(RegExp(r'\s'), '');
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buf.write(' ');
      buf.write(digits[i]);
    }
    return buf.toString();
  }

  String _titleCase(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  void _confirmDelete(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final controller = TextEditingController();
    final nickname = widget.card.nickname;
    final rootContext = Navigator.of(context, rootNavigator: true).context;

    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialog) {
            final canDelete = controller.text.trim() == nickname;
            return AlertDialog(
              backgroundColor: cs.surface,
              title: Text('Delete this card?',
                  style: localeFont(fontWeight: FontWeight.w700)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This permanently removes "$nickname" from your vault. This '
                    'cannot be undone.',
                    style: localeFont(color: cs.onSurfaceVariant, height: 1.45),
                  ),
                  const SizedBox(height: KuberSpacing.md),
                  Text('Type the nickname to confirm:',
                      style: localeFont(
                          fontSize: 12.5, color: cs.onSurfaceVariant)),
                  const SizedBox(height: KuberSpacing.sm),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    onChanged: (_) => setDialog(() {}),
                    style: localeFont(color: cs.onSurface),
                    decoration: InputDecoration(hintText: nickname),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: Text('Cancel', style: localeFont()),
                ),
                AppButton(
                  label: 'Delete',
                  type: AppButtonType.danger,
                  onPressed: canDelete
                      ? () {
                          // Fire the local delete + list reload, then pop and
                          // snackbar synchronously (no async gap on contexts;
                          // matches the account sheet's disable pattern).
                          final listNotifier =
                              ref.read(storedCardsProvider.notifier);
                          ref
                              .read(cardVaultServiceProvider)
                              .deleteCard(widget.card.id)
                              .then((_) => listNotifier.reload());
                          Navigator.pop(dialogCtx); // close dialog
                          Navigator.pop(context); // close sheet
                          showKuberSnackBar(rootContext, 'Card deleted.');
                        }
                      : null,
                ),
              ],
            );
          },
        );
      },
    );
  }
}
