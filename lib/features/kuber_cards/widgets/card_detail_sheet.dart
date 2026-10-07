import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_icon_button.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../accounts/providers/account_provider.dart';
import '../../accounts/widgets/account_detail_sheet.dart';
import '../data/card_clipboard_service.dart';
import '../data/card_vault_service.dart';
import '../data/stored_card.dart';
import '../providers/kuber_cards_provider.dart';
import 'stored_card_visual.dart';

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
  bool _revealed = false; // session-length reveal of number + expiry + custom

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

  void _copy(String value, String label) {
    CardClipboardService.copy(value);
    showKuberSnackBar(context, 'Copied $label.');
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
              label: 'Delete',
              icon: Icons.delete_outline_rounded,
              type: AppButtonType.danger,
              fullWidth: true,
              onPressed: () => _confirmDelete(context),
            ),
          ),
          const SizedBox(width: KuberSpace.md),
          Expanded(
            child: AppButton(
              label: 'Edit',
              icon: Icons.edit_outlined,
              type: AppButtonType.normal,
              fullWidth: true,
              onPressed: () {
                Navigator.pop(context);
                context.push('/cards/edit', extra: card);
              },
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
    // The reveal toggle governs number, expiry AND custom values, so show it
    // whenever any of those exist.
    final hasRevealable =
        hasNumber ||
        (dec.expiry ?? '').isNotEmpty ||
        dec.customFields.isNotEmpty;

    // The card face is the hero; below it a field table lists number, holder,
    // expiry and network (number + expiry stay masked until "Show details").
    // Long-press any row (or the card) copies that field's underlying value.
    final rows = <Widget>[
      _fieldRow(
        hasNumber
            ? (_revealed
                  ? _group(dec.number!)
                  : '•••• •••• •••• ${dec.last4 ?? '••••'}')
            : (dec.last4 != null ? '•••• ${dec.last4}' : '••••'),
        'Card number',
        hasNumber ? () => _copy(dec.number!, 'card number') : null,
        mono: true,
      ),
      if ((dec.expiry ?? '').isNotEmpty)
        _fieldRow(
          _revealed ? dec.expiry! : '••/••',
          'Expiry',
          () => _copy(dec.expiry!, 'Expiry'),
        ),
      if ((dec.cardholder ?? '').isNotEmpty)
        _fieldRow(
          dec.cardholder!,
          'Name on card',
          () => _copy(dec.cardholder!, 'cardholder'),
        ),
      if ((dec.network ?? '').isNotEmpty)
        _fieldRow(
          _titleCase(dec.network!),
          'Network',
          () => _copy(_titleCase(dec.network!), 'network'),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onLongPress: hasNumber
              ? () => _copy(dec.number!, 'card number')
              : null,
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
        const SizedBox(height: KuberSpace.lg),
        if (hasRevealable) ...[
          _revealButton(cs),
          const SizedBox(height: KuberSpace.lg),
        ],
        KuberGroup(children: rows),
        if (dec.customFields.isNotEmpty) ...[
          const SizedBox(height: KuberSpace.lg),
          const KuberSectionHeader(title: 'Custom fields'),
          KuberGroup(children: _customRows(dec)),
        ],
        _linkedAccount(cs, dec),
        const SizedBox(height: KuberSpace.md),
        Row(
          children: [
            Icon(
              Icons.credit_card_off_outlined,
              size: 16,
              color: cs.onSurfaceVariant,
            ),
            const SizedBox(width: KuberSpace.sm),
            Text(
              'CVV is never stored',
              style: Theme.of(
                context,
              ).textTheme.bodySmall!.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ],
    );
  }

  /// Reveal toggle: full-width tonal button under the card face.
  Widget _revealButton(ColorScheme cs) {
    final shown = _revealed;
    return AppButton(
      label: shown ? 'Hide details' : 'Show details',
      icon: shown ? Icons.visibility_off_outlined : Icons.visibility_outlined,
      type: AppButtonType.normal,
      fullWidth: true,
      onPressed: () => setState(() => _revealed = !_revealed),
    );
  }

  /// Value over its label, copy button on the right (board 3.24). Long-press
  /// still copies too.
  Widget _fieldRow(
    String value,
    String label,
    VoidCallback? onCopy, {
    bool mono = false,
  }) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return InkWell(
      onLongPress: onCopy,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: (mono ? monoFont(fontSize: 16) : tt.titleMedium!)
                        .copyWith(color: cs.onSurface),
                  ),
                  Text(
                    label,
                    style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            if (onCopy != null)
              AppIconButton(
                icon: Icons.copy_outlined,
                kind: AppIconButtonKind.plain,
                semanticLabel: 'Copy $label',
                onPressed: onCopy,
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _customRows(DecryptedCard dec) {
    // Values follow the single "Show details" toggle — no separate per-field
    // eye. Masked until revealed; copy always uses the real value.
    return [
      for (final f in dec.customFields)
        _fieldRow(
          _revealed
              ? f.value
              : '•' * (f.value.isEmpty ? 4 : f.value.length.clamp(4, 12)),
          f.label,
          () => _copy(f.value, f.label),
        ),
    ];
  }

  Widget _linkedAccount(ColorScheme cs, DecryptedCard dec) {
    final id = int.tryParse(dec.linkedAccountId ?? '');
    if (id == null) return const SizedBox.shrink();
    final accountsAsync = ref.watch(accountMapProvider);
    final account = accountsAsync.valueOrNull?[id];
    if (account == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: KuberSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const KuberSectionHeader(title: 'Linked account'),
          KuberGroup(
            children: [
              KuberListRow(
                leading: const KuberIconTile(
                  icon: Icons.account_balance_wallet_outlined,
                ),
                title: account.name,
                trailing: const KuberChevron(),
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
              ),
            ],
          ),
        ],
      ),
    );
  }

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
              title: Text(
                'Delete this card?',
                style: localeFont(fontWeight: FontWeight.w700),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This permanently removes "$nickname" from your vault. This '
                    'cannot be undone.',
                    style: localeFont(color: cs.onSurfaceVariant, height: 1.45),
                  ),
                  const SizedBox(height: KuberSpace.md),
                  Text(
                    'Type "$nickname" to confirm:',
                    style: localeFont(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: KuberSpace.sm),
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
                  filled: true,
                  onPressed: canDelete
                      ? () {
                          // Fire the local delete + list reload, then pop and
                          // snackbar synchronously (no async gap on contexts;
                          // matches the account sheet's disable pattern).
                          final listNotifier = ref.read(
                            storedCardsProvider.notifier,
                          );
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
