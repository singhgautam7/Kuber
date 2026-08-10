import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/overflow_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../../shared/widgets/kuber_form_widgets.dart';
import '../../../shared/widgets/kuber_page_header.dart';
import '../../pro/feature_gates/gate_sheet_kuber_cards.dart';
import '../../pro/feature_gates/pro_gate.dart';
import '../../pro/paywall/pro_state.dart';
import '../card_info_configs.dart';
import '../data/stored_card.dart';
import '../providers/kuber_cards_provider.dart';
import '../widgets/cards_secure_scaffold.dart';
import '../widgets/card_detail_sheet.dart';
import '../widgets/card_list_row.dart';
import '../widgets/stored_card_visual.dart';
import 'setup_flow_screen.dart';

/// Route target for `/cards`. The single Pro-gate choke point for the feature,
/// then decides setup vs home; the home screen handles the unlock gate via
/// [CardsSecureScaffold].
class KuberCardsEntry extends ConsumerStatefulWidget {
  const KuberCardsEntry({super.key});

  @override
  ConsumerState<KuberCardsEntry> createState() => _KuberCardsEntryState();
}

class _KuberCardsEntryState extends ConsumerState<KuberCardsEntry> {
  bool _gatePassed = false;

  @override
  void initState() {
    super.initState();
    // PRO-GATE: every entry to Kuber Cards (nav shortcut, deep link, settings)
    // funnels through here. Gating is OFF now (hasProAccess == true), so this
    // always passes. See specs/pro-gating-disabled.md.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (proGate(context, ref, showKuberCardsGateSheet)) {
        setState(() => _gatePassed = true);
      } else if (context.canPop()) {
        context.pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_gatePassed) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final metaAsync = ref.watch(cardVaultMetaProvider);
    return metaAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(
            child: Text('Could not open Kuber Cards', style: localeFont())),
      ),
      data: (meta) {
        if (meta == null) {
          // On completion the flow invalidates cardVaultMetaProvider, which
          // rebuilds this entry into the home screen (replace, not push).
          return SetupFlowScreen(onDone: () {});
        }
        return const CardsHomeScreen();
      },
    );
  }
}

// ── Home ─────────────────────────────────────────────────────────────────────

enum _CardSort { recent, nickname }

class CardsHomeScreen extends ConsumerStatefulWidget {
  const CardsHomeScreen({super.key});

  @override
  ConsumerState<CardsHomeScreen> createState() => _CardsHomeScreenState();
}

class _CardsHomeScreenState extends ConsumerState<CardsHomeScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  final Set<String> _typeFilter = {};
  final Set<String> _networkFilter = {};
  _CardSort _sort = _CardSort.recent;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final viewMode = ref.watch(cardsViewModeProvider);
    final cardsAsync = ref.watch(storedCardsProvider);

    return CardsSecureScaffold(
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: KuberAppBar(
          showBack: true,
          showHome: true,
          showBrand: false,
          infoConfig: aboutKuberCardsInfo,
          overflowConfig: KuberOverflowConfig(
            items: [
              KuberOverflowItem(
                icon: viewMode == CardsViewMode.card
                    ? Icons.view_list_rounded
                    : Icons.view_agenda_outlined,
                label: viewMode == CardsViewMode.card
                    ? 'Switch to list view'
                    : 'Switch to card view',
                onTap: () => ref.read(cardsViewModeProvider.notifier).toggle(),
              ),
              KuberOverflowItem(
                icon: Icons.settings_outlined,
                label: 'Settings',
                onTap: () => context.push('/cards/settings'),
              ),
              KuberOverflowItem(
                icon: Icons.lock_rounded,
                label: 'Lock now',
                onTap: () => ref.read(cardSessionProvider.notifier).lock(),
              ),
            ],
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KuberPageHeader(
              title: 'Kuber Cards',
              description: 'Your cards, encrypted on-device',
              actionIcon: Icons.add_rounded,
              actionTooltip: 'Add card',
              onAction: () => context.push('/cards/add'),
            ),
            Expanded(
              child: cardsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                    child: Text('Could not load cards', style: localeFont())),
                data: (cards) => _body(cs, cards, viewMode),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(ColorScheme cs, List<StoredCard> cards, CardsViewMode viewMode) {
    if (cards.isEmpty) {
      return KuberEmptyState(
        icon: Icons.credit_card_rounded,
        title: 'No cards yet',
        description: 'Add your first card to keep it safe here.',
        actionLabel: 'Add card',
        onAction: () => context.push('/cards/add'),
      );
    }

    final filtered = _applyFilters(cards);
    // PRO-GATE: Kuber Cards free tier shows 2 cards fully; the 3rd onward is
    // blurred behind the paywall. Gating is globally OFF right now
    // (hasProAccess == true), so nothing blurs today. See specs/pro-gating-disabled.md.
    final hasPro = ref.watch(kuberProStateProvider).hasProAccess;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _controlsRow(cs, viewMode),
        // "SHOWING N CARDS" eyebrow, mirroring the History tab's count row.
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
          child: RichText(
            text: TextSpan(
              style: localeFont(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: cs.onSurfaceVariant,
              ),
              children: [
                const TextSpan(text: 'SHOWING '),
                TextSpan(
                  text: '${filtered.length} ',
                  style: TextStyle(color: cs.primary),
                ),
                TextSpan(text: filtered.length == 1 ? 'CARD' : 'CARDS'),
              ],
            ),
          ),
        ),
        Expanded(
          child: viewMode == CardsViewMode.card
              ? _cardView(filtered, hasPro)
              : _listView(cs, filtered, hasPro),
        ),
      ],
    );
  }

  Widget _controlsRow(ColorScheme cs, CardsViewMode viewMode) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 42,
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                style: localeFont(fontSize: 14, color: cs.onSurface),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Search cards',
                  hintStyle:
                      localeFont(fontSize: 14, color: cs.onSurfaceVariant),
                  prefixIcon: Icon(Icons.search_rounded,
                      size: 20, color: cs.onSurfaceVariant),
                  filled: true,
                  fillColor: cs.surfaceContainer,
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                    borderSide: BorderSide(color: cs.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                    borderSide: BorderSide(color: cs.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                    borderSide: BorderSide(color: cs.outline),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _iconBtn(cs, Icons.tune_rounded, 'Filter', _showFilterSheet,
              active: _typeFilter.isNotEmpty ||
                  _networkFilter.isNotEmpty ||
                  _sort != _CardSort.recent),
          const SizedBox(width: 8),
          _iconBtn(
            cs,
            viewMode == CardsViewMode.card
                ? Icons.view_list_rounded
                : Icons.view_agenda_outlined,
            'Toggle view',
            () => ref.read(cardsViewModeProvider.notifier).toggle(),
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(
      ColorScheme cs, IconData icon, String tooltip, VoidCallback onTap,
      {bool active = false}) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          child: Ink(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: active ? cs.primary.withValues(alpha: 0.10) : cs.surfaceContainer,
              borderRadius: BorderRadius.circular(KuberRadius.md),
              border: Border.all(color: active ? cs.primary : cs.outline),
            ),
            child: Icon(icon,
                size: 20, color: active ? cs.primary : cs.onSurfaceVariant),
          ),
        ),
      ),
    );
  }

  Widget _cardView(List<StoredCard> cards, bool hasPro) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
      itemCount: cards.length,
      itemBuilder: (context, i) {
        final card = cards[i];
        // PRO-GATE: free users see cards[0] and cards[1]; blur the rest.
        final locked = !hasPro && i >= 2;
        return Padding(
          padding: EdgeInsets.only(top: i == 0 ? 0 : KuberSpacing.md),
          child: locked
              ? _BlurredCard(card: card)
              : _TappableCard(card: card, onTap: () => _openDetail(card)),
        );
      },
    );
  }

  Widget _listView(ColorScheme cs, List<StoredCard> cards, bool hasPro) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
      itemCount: cards.length,
      itemBuilder: (context, i) {
        final card = cards[i];
        final locked = !hasPro && i >= 2; // PRO-GATE
        return CardListRow(
          card: card,
          locked: locked,
          isFirst: i == 0,
          isLast: i == cards.length - 1,
          // PRO-GATE: a locked row opens the gate sheet, never the detail sheet.
          onTap: locked
              ? () => proGate(context, ref, showKuberCardsGateSheet)
              : () => _openDetail(card),
        );
      },
    );
  }

  void _openDetail(StoredCard card) => showCardDetailSheet(context, ref, card);

  List<StoredCard> _applyFilters(List<StoredCard> cards) {
    var list = cards.where((c) {
      if (_typeFilter.isNotEmpty &&
          (c.cardType == null || !_typeFilter.contains(c.cardType))) {
        return false;
      }
      if (_networkFilter.isNotEmpty &&
          (c.network == null || !_networkFilter.contains(c.network))) {
        return false;
      }
      if (_query.isEmpty) return true;
      final hay = [
        c.nickname,
        c.last4 ?? '',
        c.network ?? '',
        c.cardType ?? '',
      ].join(' ').toLowerCase();
      return hay.contains(_query);
    }).toList();
    if (_sort == _CardSort.nickname) {
      list.sort((a, b) =>
          a.nickname.toLowerCase().compareTo(b.nickname.toLowerCase()));
    }
    return list;
  }

  void _showFilterSheet() {
    const types = [
      'debit', 'credit', 'prepaid', 'forex', 'gift',
      'travel', 'fuel', 'meal', 'corporate', 'other',
    ];
    const networks = <String, String>{
      'visa': 'Visa',
      'mastercard': 'Mastercard',
      'rupay': 'RuPay',
      'amex': 'Amex',
      'discover': 'Discover',
      'other': 'Other',
    };
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            final cs = Theme.of(ctx).colorScheme;
            return KuberBottomSheet(
              title: 'Filter and sort',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const KuberFieldLabel('Card type'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final t in types)
                        _FilterChip(
                          label: t[0].toUpperCase() + t.substring(1),
                          selected: _typeFilter.contains(t),
                          onTap: () => setSheet(() {
                            _typeFilter.contains(t)
                                ? _typeFilter.remove(t)
                                : _typeFilter.add(t);
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: KuberSpacing.lg),
                  const KuberFieldLabel('Network'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final e in networks.entries)
                        _FilterChip(
                          label: e.value,
                          selected: _networkFilter.contains(e.key),
                          onTap: () => setSheet(() {
                            _networkFilter.contains(e.key)
                                ? _networkFilter.remove(e.key)
                                : _networkFilter.add(e.key);
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: KuberSpacing.lg),
                  const KuberFieldLabel('Sort by'),
                  _SortOptionRow(
                    label: 'Recently updated',
                    selected: _sort == _CardSort.recent,
                    onTap: () => setSheet(() => _sort = _CardSort.recent),
                  ),
                  _SortOptionRow(
                    label: 'Name (A to Z)',
                    selected: _sort == _CardSort.nickname,
                    onTap: () => setSheet(() => _sort = _CardSort.nickname),
                  ),
                  const SizedBox(height: KuberSpacing.md),
                  TextButton(
                    onPressed: () => setSheet(() {
                      _typeFilter.clear();
                      _networkFilter.clear();
                      _sort = _CardSort.recent;
                    }),
                    child: Text('Clear filters',
                        style: localeFont(color: cs.onSurfaceVariant)),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() => setState(() {}));
  }
}

/// A single-select sort option row (radio-style), matching the settings choice
/// list look rather than a segmented tab.
class _SortOptionRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SortOptionRow(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: KuberSpacing.xs),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? cs.primary.withValues(alpha: 0.08) : cs.surfaceContainer,
            borderRadius: BorderRadius.circular(KuberRadius.md),
            border: Border.all(
              color: selected ? cs.primary.withValues(alpha: 0.35) : cs.outline,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: localeFont(
                    fontSize: 14.5,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    color: selected ? cs.primary : cs.onSurface,
                  ),
                ),
              ),
              if (selected)
                Icon(Icons.check_circle_rounded, color: cs.primary, size: 22)
              else
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: cs.outline.withValues(alpha: 0.5), width: 2),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TappableCard extends StatelessWidget {
  final StoredCard card;
  final VoidCallback onTap;
  const _TappableCard({required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onTap,
      borderRadius: BorderRadius.circular(KuberRadius.xl),
      child: StoredCardVisual(
        nickname: card.nickname,
        last4: card.last4,
        bankIcon: card.bankIcon,
        network: card.network,
        colorValue: card.colorValue,
        isGradient: card.isGradient,
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? cs.primary.withValues(alpha: 0.12)
                : cs.surfaceContainer,
            borderRadius: BorderRadius.circular(KuberRadius.md),
            border: Border.all(color: selected ? cs.primary : cs.outline),
          ),
          child: Text(
            label,
            style: localeFont(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? cs.primary : cs.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

/// Free-tier blurred card + paywall CTA.
/// PRO-GATE: only rendered when the user is not Pro and the card is beyond the
/// 2 free slots. Gating is OFF right now, so this never appears.
class _BlurredCard extends ConsumerWidget {
  final StoredCard card;
  const _BlurredCard({required this.card});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(KuberRadius.xl),
      child: Stack(
        children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: StoredCardVisual(
              // Never real digits on a blurred card, even during layout.
              nickname: card.nickname,
              last4: null,
              bankIcon: card.bankIcon,
              network: card.network,
              colorValue: card.colorValue,
              isGradient: card.isGradient,
            ),
          ),
          Positioned.fill(
            child: ColoredBox(
              color: cs.surface.withValues(alpha: 0.55),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(KuberRadius.md),
                      ),
                      child: Icon(Icons.lock_rounded, size: 20, color: cs.primary),
                    ),
                    const SizedBox(height: KuberSpacing.sm),
                    Text(
                      'Unlock with Kuber Pro',
                      style: localeFont(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: KuberSpacing.sm),
                    AppButton(
                      label: 'See Kuber Pro',
                      type: AppButtonType.primary,
                      height: 40,
                      onPressed: () =>
                          proGate(context, ref, showKuberCardsGateSheet),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
