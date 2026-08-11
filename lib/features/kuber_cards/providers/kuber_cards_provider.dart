import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/database/isar_service.dart';
import '../../../core/utils/prefs_keys.dart';
import '../data/card_vault_meta.dart';
import '../data/card_vault_service.dart';
import '../data/stored_card.dart';

/// Stateless crypto + repository service.
final cardVaultServiceProvider = Provider<CardVaultService>((ref) {
  return CardVaultService(ref.watch(isarProvider));
});

// ── Unlock session (in-memory key only, never the PIN) ───────────────────────

/// The live vault session. Holds the derived key ONLY while unlocked; cleared on
/// cold start (provider is fresh), background > 60s, and explicit "Lock now".
class CardSession {
  /// The 32-byte derived key, or null when locked.
  final List<int>? key;

  /// When the app was last backgrounded while unlocked (for the 60s auto-lock).
  final DateTime? backgroundedAt;

  const CardSession({this.key, this.backgroundedAt});

  bool get isUnlocked => key != null;
}

class CardSessionNotifier extends Notifier<CardSession> {
  /// Auto-lock threshold: backgrounded longer than this re-locks on resume.
  static const relockAfter = Duration(seconds: 60);

  @override
  CardSession build() => const CardSession();

  void unlock(List<int> key) => state = CardSession(key: key);

  void lock() => state = const CardSession();

  /// Record the moment the app went to background (only meaningful if unlocked).
  void noteBackgrounded() {
    if (!state.isUnlocked) return;
    state = CardSession(key: state.key, backgroundedAt: DateTime.now());
  }

  /// On resume: relock if we were backgrounded past the threshold.
  void relockIfExpired() {
    final bg = state.backgroundedAt;
    if (!state.isUnlocked || bg == null) return;
    if (DateTime.now().difference(bg) > relockAfter) {
      lock();
    } else {
      // Clear the marker so a later foreground toggle doesn't accumulate.
      state = CardSession(key: state.key);
    }
  }
}

final cardSessionProvider =
    NotifierProvider<CardSessionNotifier, CardSession>(CardSessionNotifier.new);

/// Convenience: is the vault currently unlocked?
final cardsUnlockedProvider = Provider<bool>((ref) {
  return ref.watch(cardSessionProvider.select((s) => s.isUnlocked));
});

// ── Vault metadata (hasVault, lockout, import banner) ────────────────────────

/// The singleton vault metadata, or null when no vault exists. Invalidate after
/// setup / change-PIN / import.
final cardVaultMetaProvider = FutureProvider<CardVaultMeta?>((ref) async {
  return ref.watch(cardVaultServiceProvider).readMeta();
});

/// True once the user has set up a vault. Defaults to false while loading.
final hasVaultProvider = Provider<bool>((ref) {
  return ref.watch(cardVaultMetaProvider).valueOrNull != null;
});

// ── Stored cards list (plaintext columns; no key needed to render) ───────────

class StoredCardsNotifier extends AsyncNotifier<List<StoredCard>> {
  @override
  Future<List<StoredCard>> build() {
    return ref.watch(cardVaultServiceProvider).allCards();
  }

  Future<void> reload() async {
    state = await AsyncValue.guard(
      () => ref.read(cardVaultServiceProvider).allCards(),
    );
  }
}

final storedCardsProvider =
    AsyncNotifierProvider<StoredCardsNotifier, List<StoredCard>>(
        StoredCardsNotifier.new);

/// The stored card (if any) that links a given account, for the "Linked to a
/// card in Kuber Cards" badge on the account view sheet. Reads plaintext
/// columns only, so it needs no key.
final cardLinkedToAccountProvider =
    Provider.family<StoredCard?, int>((ref, accountId) {
  final cards = ref.watch(storedCardsProvider).valueOrNull;
  if (cards == null) return null;
  for (final c in cards) {
    if (c.linkedAccountId == accountId.toString()) return c;
  }
  return null;
});

// ── Persisted card/list view preference ──────────────────────────────────────

enum CardsViewMode { card, list }

class CardsViewModeNotifier extends Notifier<CardsViewMode> {
  @override
  CardsViewMode build() {
    _load();
    return CardsViewMode.card; // card view is the default
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(PrefsKeys.cardsViewMode) == 'list') {
      state = CardsViewMode.list;
    }
  }

  Future<void> toggle() =>
      set(state == CardsViewMode.card ? CardsViewMode.list : CardsViewMode.card);

  Future<void> set(CardsViewMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      PrefsKeys.cardsViewMode,
      mode == CardsViewMode.list ? 'list' : 'card',
    );
  }
}

final cardsViewModeProvider =
    NotifierProvider<CardsViewModeNotifier, CardsViewMode>(
        CardsViewModeNotifier.new);

// ── Persisted card sort order (sort persists; filters intentionally do not) ───

enum CardsSortMode { recent, oldest, nickname }

class CardsSortNotifier extends Notifier<CardsSortMode> {
  @override
  CardsSortMode build() {
    _load();
    return CardsSortMode.recent; // newest first is the default
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    switch (prefs.getString(PrefsKeys.cardsSort)) {
      case 'oldest':
        state = CardsSortMode.oldest;
      case 'nickname':
        state = CardsSortMode.nickname;
    }
  }

  Future<void> set(CardsSortMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefsKeys.cardsSort, mode.name);
  }
}

final cardsSortProvider =
    NotifierProvider<CardsSortNotifier, CardsSortMode>(CardsSortNotifier.new);
