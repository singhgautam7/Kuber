import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/overflow_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../core/services/shortcut_pin_service.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/kuber_search_filter_bar.dart';
import '../../../shared/widgets/kuber_chips.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../../shared/widgets/kuber_form_widgets.dart';
import '../../../shared/widgets/kuber_extended_fab.dart';
import '../../pro/feature_gates/gate_sheet_kuber_cards.dart';
import '../../pro/feature_gates/pro_gate.dart';
import '../../pro/paywall/pro_state.dart';
import '../card_info_configs.dart';
import '../data/stored_card.dart';
import '../providers/kuber_cards_provider.dart';
import '../widgets/cards_secure_scaffold.dart';
import '../widgets/card_detail_sheet.dart';
import '../widgets/card_icon.dart';
import '../widgets/card_list_row.dart';
import '../widgets/stored_card_visual.dart';
import 'setup_flow_screen.dart';

/// PRO-GATE: free-tier Kuber Cards limit. Free users see and manage the first
/// [kFreeCardLimit] cards fully; the rest are blurred behind the paywall, and
/// adding beyond the limit routes to the gate sheet. Pro is unlimited.
const kFreeCardLimit = 2;

/// Route target for `/cards`, then decides setup vs home; the home screen
/// handles the unlock gate via [CardsSecureScaffold].
///
/// PRO-GATE: Kuber Cards is reachable on the free tier — a free user may add up
/// to 2 cards. There is NO entry-level Pro gate; the only gate is the 3rd-card
/// blur in the home list (`i >= 2`). See specs/pro-gating-enabled.md.
class KuberCardsEntry extends ConsumerStatefulWidget {
  const KuberCardsEntry({super.key});

  @override
  ConsumerState<KuberCardsEntry> createState() => _KuberCardsEntryState();
}

class _KuberCardsEntryState extends ConsumerState<KuberCardsEntry> {
  @override
  Widget build(BuildContext context) {
    final metaAsync = ref.watch(cardVaultMetaProvider);
    return metaAsync.when(
      loading: () => Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        body: Center(
          child: Text('Could not open Kuber Cards', style: localeFont()),
        ),
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

  bool get _hasActiveFilters =>
      _typeFilter.isNotEmpty || _networkFilter.isNotEmpty;

  @override
  void initState() {
    super.initState();
    // Warm the bundled bank SVGs on first home open (lazy, never at app boot),
    // so the card list draws them from cache instead of decoding mid-frame.
    warmBankIconCache();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final viewMode = ref.watch(cardsViewModeProvider);
    // While locked, the opaque unlock overlay covers this screen, so building
    // the card list (Isar query + a bank-SVG decode per card) here would be
    // pure invisible work competing with the unlock screen's first paint — the
    // source of the "PIN screen lags on open" jank. Gate the list on the
    // unlocked state; the cheap app bar + header still build for a stable
    // layout underneath the overlay.
    final unlocked = ref.watch(cardsUnlockedProvider);

    return CardsSecureScaffold(
      child: Scaffold(
        floatingActionButton: KuberExtendedFab(
          icon: Icons.add_rounded,
          label: 'Add card',
          onPressed: _onAddCard,
        ),
        floatingActionButtonLocation: kuberFabLocation,
        backgroundColor: cs.surface,
        // Nothing here is pinned: the app bar, page header, and the search +
        // count rows all scroll with the card list (parity with the
        // More -> Accounts landing).
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: KuberAppBar(
                title: 'Kuber Cards',
                showBack: true,
                pinShortcut: const PinShortcutSpec(
                  shortcutId: 'kuber_cards',
                  shortLabel: 'Cards',
                  longLabel: 'Kuber Cards',
                  iconDrawable: 'ic_shortcut_cards',
                  deepLink: 'kuber://app/cards',
                ),
                infoConfig: aboutKuberCardsInfo,
                search:
                    unlocked &&
                        (ref
                                .watch(storedCardsProvider)
                                .valueOrNull
                                ?.isNotEmpty ??
                            false)
                    ? KuberHeaderSearch(
                        controller: _searchCtrl,
                        hint: 'Search cards',
                        onChanged: (v) =>
                            setState(() => _query = v.trim().toLowerCase()),
                      )
                    : null,
                overflowConfig: KuberOverflowConfig(
                  items: [
                    KuberOverflowItem(
                      icon: Icons.settings_outlined,
                      label: 'Settings',
                      onTap: () => context.push('/cards/settings'),
                    ),
                    KuberOverflowItem(
                      icon: Icons.lock_rounded,
                      label: 'Lock now',
                      onTap: () =>
                          ref.read(cardSessionProvider.notifier).lock(),
                    ),
                  ],
                ),
              ),
            ),

            if (unlocked)
              ...ref
                  .watch(storedCardsProvider)
                  .when(
                    loading: () => const [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ],
                    error: (e, _) => [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(
                            'Could not load cards',
                            style: localeFont(),
                          ),
                        ),
                      ),
                    ],
                    data: (cards) => _contentSlivers(
                      cs,
                      cards,
                      viewMode,
                      ref.watch(cardsSortProvider),
                    ),
                  )
            else
              const SliverToBoxAdapter(child: SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  List<Widget> _contentSlivers(
    ColorScheme cs,
    List<StoredCard> cards,
    CardsViewMode viewMode,
    CardsSortMode sort,
  ) {
    if (cards.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: KuberEmptyState(
            icon: Icons.credit_card_rounded,
            title: 'No cards yet',
            description: 'Add your first card to keep it safe here.',
          ),
        ),
      ];
    }

    final filtered = _applyFilters(cards, sort);
    // PRO-GATE: Kuber Cards free tier shows 2 cards fully; the 3rd onward is
    // blurred behind the paywall. See specs/pro-gating-enabled.md.
    final hasPro = ref.watch(kuberProStateProvider).hasProAccess;

    return [
      // "SHOWING N CARDS" eyebrow, mirroring the History tab's count row.
      SliverToBoxAdapter(child: _countRow(cs, filtered.length, viewMode)),
      SliverPadding(
        padding: const EdgeInsets.symmetric(
          horizontal: KuberSpace.screenMargin,
        ),
        // Card <-> list view cross-fades (review round 3).
        sliver: SliverToBoxAdapter(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.topCenter,
              children: [...previous, ?current],
            ),
            child: viewMode == CardsViewMode.card
                ? KeyedSubtree(
                    key: const ValueKey('cards-card'),
                    child: _cardColumn(filtered, hasPro),
                  )
                : KeyedSubtree(
                    key: const ValueKey('cards-list'),
                    child: _listGroup(filtered, hasPro),
                  ),
          ),
        ),
      ),
      const SliverToBoxAdapter(
        child: SizedBox(height: KuberExtendedFab.clearance),
      ),
    ];
  }

  /// "SHOWING N CARDS" + the card / list view toggle (board 3.24).
  Widget _countRow(ColorScheme cs, int count, CardsViewMode viewMode) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        KuberSpace.screenMargin,
        0,
        KuberSpace.lg,
        KuberSpace.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Showing $count ${count == 1 ? 'card' : 'cards'}'.toUpperCase(),
              style: sectionHeaderStyle(context),
            ),
          ),
          // Filter + change view (round 4): the type / network filter sheet
          // fills the filter button while applied; sort never lights it up.
          KuberFilterButton(
            onPressed: _showFilterSheet,
            active: _hasActiveFilters,
          ),
          KuberViewModeButton<CardsViewMode>(
            value: viewMode,
            options: const [
              (CardsViewMode.card, Icons.style_outlined, 'Card view'),
              (CardsViewMode.list, Icons.view_list_rounded, 'List view'),
            ],
            onChanged: (_) => ref.read(cardsViewModeProvider.notifier).toggle(),
          ),
        ],
      ),
    );
  }

  Widget _cardColumn(List<StoredCard> cards, bool hasPro) {
    return Column(
      children: [
        for (final (i, card) in cards.indexed)
          Padding(
            padding: EdgeInsets.only(top: i == 0 ? 0 : KuberSpace.md),
            // PRO-GATE: free users see cards[0] and cards[1]; blur the rest.
            child: !hasPro && i >= kFreeCardLimit
                ? _BlurredCard(card: card)
                : _TappableCard(card: card, onTap: () => _openDetail(card)),
          ),
      ],
    );
  }

  Widget _listGroup(List<StoredCard> cards, bool hasPro) {
    return KuberGroup(
      children: [
        for (final (i, card) in cards.indexed)
          () {
            final locked = !hasPro && i >= kFreeCardLimit; // PRO-GATE
            return CardListRow(
              card: card,
              locked: locked,
              // PRO-GATE: a locked row opens the gate sheet, never the detail
              // sheet.
              onTap: locked
                  ? () => proGate(context, ref, showKuberCardsGateSheet)
                  : () => _openDetail(card),
            );
          }(),
      ],
    );
  }

  void _openDetail(StoredCard card) => showCardDetailSheet(context, ref, card);

  /// PRO-GATE: free users may hold up to [kFreeCardLimit] cards. Once at the
  /// limit, the "Add card" action opens the gate sheet instead of the add flow,
  /// so a non-Pro user cannot create a 3rd card (any extras that arrive from a
  /// backup restore still appear, blurred, in the list). Pro is unlimited.
  void _onAddCard() {
    final hasPro = ref.read(kuberProStateProvider).hasProAccess;
    final count = ref.read(storedCardsProvider).valueOrNull?.length ?? 0;
    if (!hasPro && count >= kFreeCardLimit) {
      showKuberCardsGateSheet(context);
      return;
    }
    context.push('/cards/add');
  }

  List<StoredCard> _applyFilters(List<StoredCard> cards, CardsSortMode sort) {
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
    // `cards` arrives most-recently-updated first (the repository's default), so
    // `recent` needs no re-sort.
    switch (sort) {
      case CardsSortMode.recent:
        break;
      case CardsSortMode.oldest:
        list.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
      case CardsSortMode.nickname:
        list.sort(
          (a, b) =>
              a.nickname.toLowerCase().compareTo(b.nickname.toLowerCase()),
        );
    }
    return list;
  }

  void _showFilterSheet() {
    const types = [
      'debit',
      'credit',
      'prepaid',
      'forex',
      'gift',
      'travel',
      'fuel',
      'meal',
      'corporate',
      'other',
    ];
    const networks = <String, String>{
      'visa': 'Visa',
      'mastercard': 'Mastercard',
      'rupay': 'RuPay',
      'amex': 'Amex',
      'discover': 'Discover',
      'other': 'Other',
    };
    // Local mirror of the persisted sort so the radio updates in-sheet; the
    // provider is the source of truth and survives app close.
    var sort = ref.read(cardsSortProvider);
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
                        KuberChip(
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
                  const SizedBox(height: KuberSpace.lg),
                  const KuberFieldLabel('Network'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final e in networks.entries)
                        KuberChip(
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
                  const SizedBox(height: KuberSpace.lg),
                  const KuberFieldLabel('Sort by'),
                  KuberGroup(
                    children: [
                      for (final (mode, label) in const [
                        (CardsSortMode.recent, 'Newest first'),
                        (CardsSortMode.oldest, 'Oldest first'),
                        (CardsSortMode.nickname, 'Name (A to Z)'),
                      ])
                        KuberListRow(
                          dense: true,
                          title: label,
                          trailing: Icon(
                            sort == mode
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: sort == mode
                                ? cs.primary
                                : cs.onSurfaceVariant,
                          ),
                          onTap: () {
                            setSheet(() => sort = mode);
                            ref.read(cardsSortProvider.notifier).set(mode);
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: KuberSpace.md),
                  // Clears applied filters only. Sort is a saved preference, so
                  // it is left untouched here.
                  TextButton(
                    onPressed: () => setSheet(() {
                      _typeFilter.clear();
                      _networkFilter.clear();
                    }),
                    child: const Text('Clear filters'),
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

class _TappableCard extends StatelessWidget {
  final StoredCard card;
  final VoidCallback onTap;
  const _TappableCard({required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onTap,
      borderRadius: BorderRadius.circular(KuberShape.medium),
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

/// Free-tier blurred card + paywall CTA.
/// PRO-GATE: only rendered when the user is not Pro and the card is beyond the
/// 2 free slots.
class _BlurredCard extends ConsumerWidget {
  final StoredCard card;
  const _BlurredCard({required this.card});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: KuberShape.cardR,
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
                    const KuberIconTile(icon: Icons.lock_rounded),
                    const SizedBox(height: KuberSpace.sm),
                    Text(
                      'Unlock with Kuber Pro',
                      style: Theme.of(
                        context,
                      ).textTheme.titleSmall!.copyWith(color: cs.onSurface),
                    ),
                    const SizedBox(height: KuberSpace.sm),
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
