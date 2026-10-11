import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:isar_community/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/database/isar_service.dart';
import '../../../core/utils/prefs_keys.dart';
import '../../accounts/providers/account_provider.dart';
import '../../budgets/providers/budget_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../investments/data/investment.dart';
import '../../kuber_cards/data/card_vault_meta.dart';
import '../../kuber_cards/data/stored_card.dart';
import '../../ledger/data/ledger.dart';
import '../../loans/data/loan.dart';
import '../../notes/data/kuber_note.dart';
import '../../pro/promo/home_promo_banner.dart';
import '../../recurring/providers/recurring_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../sms_import/data/sms_import_repository.dart';
import '../../sms_import/data/sms_transaction.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../widget_editor/providers/widget_editor_provider.dart';
import '../engine/suggestion_engine.dart';
import '../engine/suggestion_scheduler.dart';
import 'home_v2_provider.dart';

/// What the top slot shows for suggestions this session.
class SuggestionView {
  /// The card on screen, or null.
  final SgCandidate? card;

  /// In-card success (data types) after the flow was saved.
  final bool success;

  /// Bumped on every change so the slot animates in / out.
  final int version;

  const SuggestionView({this.card, this.success = false, this.version = 0});
}

/// Suggestion state for Home v2 (suggestion-rules.md §3).
///
/// Cost model: [resolve] is called by the top slot once the on-open batch is
/// ready and does nothing more than once per session. It returns before
/// touching any data when the install or session is not eligible (v1, Get
/// started not graduated 24 h ago, setting off, promo visible, session
/// locked) or when only a new suggestion could show and today's allowance or
/// the dismiss cooldown blocks it. Otherwise it builds one snapshot from
/// data already in memory plus a few Isar counts and runs the rules once.
class HomeSuggestionNotifier extends Notifier<SuggestionView> {
  int? _resolvedSession;
  int? _lockedSession;
  bool _resolving = false;

  /// Store before the last dismiss, for Undo.
  SgStore? _beforeDismiss;

  @override
  SuggestionView build() => const SuggestionView();

  bool get _sessionLocked => _lockedSession == ref.read(homeSessionProvider);

  Future<SgStore> _loadStore() async {
    final p = await SharedPreferences.getInstance();
    return SgStore.decode(
      instances: p.getString(PrefsKeys.sgInstances),
      lastNewShownDay: p.getInt(PrefsKeys.sgLastNewShownDay),
      lastDismissAt: p.getString(PrefsKeys.sgLastDismissAt),
      suppressed: p.getString(PrefsKeys.sgTypeSuppressedUntil),
    );
  }

  Future<void> _saveStore(SgStore s) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(PrefsKeys.sgInstances, s.encodeInstances());
    final day = s.lastNewShownDay;
    if (day == null) {
      await p.remove(PrefsKeys.sgLastNewShownDay);
    } else {
      await p.setInt(PrefsKeys.sgLastNewShownDay, day);
    }
    final d = s.lastDismissAt;
    if (d == null) {
      await p.remove(PrefsKeys.sgLastDismissAt);
    } else {
      await p.setString(PrefsKeys.sgLastDismissAt, d.toIso8601String());
    }
    await p.setString(PrefsKeys.sgTypeSuppressedUntil, s.encodeSuppressed());
  }

  bool _eligible(DateTime now) {
    final s = ref.read(homeV2Provider);
    return SgScheduler.eligible(
      isV2: s.isV2,
      gsGraduatedAt: s.gsGraduatedAt,
      setting: s.sgSetting,
      promoVisible: ref.read(homePromoVisibleProvider),
      sessionLocked: _sessionLocked,
      now: now,
    );
  }

  /// Dev tools: run the rules again now, ignoring this session's lock.
  Future<void> runNow() {
    _lockedSession = null;
    return resolve(force: true);
  }

  /// Picks this session's card (at most once per session).
  Future<void> resolve({bool force = false}) async {
    final session = ref.read(homeSessionProvider);
    if (_resolving || (!force && _resolvedSession == session)) return;
    _resolving = true;
    try {
      _resolvedSession = session;
      final now = DateTime.now();
      if (!_eligible(now)) return _show(null);
      var store = await _loadStore();
      if (SgScheduler.activeInstance(store) == null &&
          SgScheduler.newBlocked(store, now)) {
        return _show(null);
      }
      final sw = Stopwatch()..start();
      final input = await buildInput(now);
      final built = sw.elapsedMilliseconds;
      final candidates = SuggestionEngine.evaluate(input);
      // Logged in every build mode: one line per session, used for the
      // on-device timing in specs/home-v2/performance-review.md.
      debugPrint(
        'Kuber homeV2: rules on ${input.txns.length} recent / '
        '${input.totalTxnCount} txns: input $built ms, '
        'rules ${sw.elapsedMilliseconds - built} ms',
      );
      final r = SgScheduler.select(store, candidates, now);
      store = r.store;
      await _saveStore(store);
      _show(r.shown);
    } finally {
      _resolving = false;
    }
  }

  void _show(SgCandidate? c, {bool success = false}) {
    state = SuggestionView(
      card: c,
      success: success,
      version: state.version + 1,
    );
  }

  /// Snapshot for the rules: transactions already in memory (last 130
  /// days), lists the app already holds, and Isar `count()` calls.
  Future<SgInput> buildInput(DateTime now) async {
    final isar = ref.read(isarProvider);
    final all = await ref.read(transactionListProvider.future);
    final from = now.subtract(const Duration(days: SgInput.lookBackDays));
    final txns = [
      for (final t in all)
        if (!t.createdAt.isBefore(from) && !t.isBalanceAdjustment)
          SgTxn(
            at: t.createdAt,
            amount: t.amount,
            isExpense: t.type == 'expense',
            isTransfer: t.isTransfer,
            name: t.name,
            categoryId: t.categoryId,
            accountId: t.accountId,
            fromSms: t.importSource == 'sms',
            smsText: t.importedFromSms,
            note: t.notes,
          ),
    ];
    final categories = await ref.read(categoryListProvider.future);
    final accounts = await ref.read(allAccountsProvider.future);
    final rules = await ref.read(recurringListProvider.future);
    final budgets = await ref.read(budgetListProvider.future);
    final staged = await isar.smsTransactions
        .filter()
        .reviewStatusEqualTo(SmsReviewStatus.unreviewed)
        .smsDateGreaterThan(now.subtract(const Duration(days: 60)))
        .findAll();
    final notes = await isar.kuberNotes
        .filter()
        .updatedAtGreaterThan(now.subtract(const Duration(days: 30)))
        .findAll();
    final snap = ref.read(homeV2Provider);
    final installAge = snap.installedAt == null
        ? 0
        : now.difference(snap.installedAt!).inDays;
    final isAndroid = !kIsWeb && Platform.isAndroid;
    final homeConfigs = ref.read(homeWidgetsProvider).valueOrNull ?? const [];

    // Platform calls only when the home-widget rule could pass otherwise.
    bool? pinSupported;
    bool? hasWidget;
    if (isAndroid && installAge >= 7 && all.length >= 15) {
      try {
        pinSupported = await HomeWidget.isRequestPinWidgetSupported();
        hasWidget = (await HomeWidget.getInstalledWidgets()).isNotEmpty;
      } catch (_) {
        pinSupported = false;
      }
    }

    return SgInput(
      now: now,
      txns: txns,
      totalTxnCount: all.length,
      staged: [
        for (final s in staged)
          SgStagedSms(
            at: s.smsDate,
            text: s.rawSms,
            sender: s.senderId,
            amount: s.parsedAmount,
          ),
      ],
      categoryNames: {for (final c in categories) '${c.id}': c.name},
      accounts: [
        for (final a in accounts)
          if (!a.isDisabled)
            SgAccount(
              id: a.id,
              name: a.name,
              isCreditCard: a.isCreditCard,
              isBank: a.type == 'bank' && !a.isCreditCard,
              billingDay: a.billGenerationDay,
            ),
      ],
      rules: [
        for (final r in rules)
          SgRule(
            name: r.name,
            categoryId: r.categoryId,
            amount: r.amount,
            active: !r.isPaused,
          ),
      ],
      activeBudgetCategoryIds: {
        for (final b in budgets)
          if (b.isActive) b.categoryId,
      },
      loanCount: await isar.loans.count(),
      investmentCount: await isar.investments.count(),
      ledgerCount: await isar.ledgers.count(),
      kuberCardCount: await isar.storedCards.count(),
      cardsSetupStarted: await isar.cardVaultMetas.count() > 0,
      notes: [
        for (final n in notes)
          SgNote(at: n.updatedAt, title: n.title, body: noteText(n.content)),
      ],
      languageCode:
          ref.read(settingsProvider).valueOrNull?.locale.languageCode ?? 'en',
      askOpened: snap.askOpened,
      voiceUsed: snap.voiceUsed,
      quickAddOnHome: homeConfigs.any((c) => c.id == 'quick_add' && c.enabled),
      // ponytail: "a speech recognizer is available" is read as "Android".
      // speech_to_text's initialize() can raise the mic permission prompt,
      // which a background check must never do.
      speechAvailable: isAndroid,
      isAndroid: isAndroid,
      pinWidgetSupported: pinSupported,
      hasHomeWidget: hasWidget,
      installAgeDays: installAge,
    );
  }

  // ── Card actions ─────────────────────────────────────────────────────

  /// Main action returned. Data types: accepted only if the flow saved
  /// (the trigger is now false). Discovery types: accepted on tap.
  Future<void> afterMainAction(SgCandidate c) async {
    final now = DateTime.now();
    var store = await _loadStore();
    final before = store;
    if (!c.type.isDiscovery) {
      final input = await buildInput(now);
      final stillTrue = SuggestionEngine.evaluate(
        input,
      ).any((x) => x.key == c.key);
      if (stillTrue) return; // left without saving: card stays
    }
    store = SgScheduler.accept(store, c.key, now);
    await _saveStore(store);
    if (c.type.isDiscovery) {
      _show(null);
    } else {
      _show(c, success: true);
    }
    // Next suggestion only when today's new allowance is unused.
    if (SgScheduler.canShowNextAfterAccept(before, now)) {
      await Future<void>.delayed(
        Duration(milliseconds: c.type.isDiscovery ? 830 : 1600 + 230 + 600),
      );
      await resolve(force: true);
    }
  }

  /// Hides the in-card success (after its 1600 ms hold).
  void clearSuccess() {
    if (state.success) _show(null);
  }

  Future<void> notNow(SgCandidate c) async {
    final store = SgScheduler.notNow(await _loadStore(), c.key, DateTime.now());
    await _saveStore(store);
    _lockedSession = ref.read(homeSessionProvider);
    _show(null);
  }

  Future<void> dismiss(SgCandidate c) async {
    final before = await _loadStore();
    _beforeDismiss = before;
    await _saveStore(SgScheduler.dismiss(before, c.key, DateTime.now()));
    _lockedSession = ref.read(homeSessionProvider);
    _show(null);
  }

  /// Undo on the dismiss snackbar: back to active, lock and cooldown cleared.
  Future<void> undoDismiss(SgCandidate c) async {
    final before = _beforeDismiss;
    if (before == null) return;
    _beforeDismiss = null;
    await _saveStore(before);
    _lockedSession = null;
    _show(c);
  }

  /// Dev tools: show [c] now, skipping eligibility, caps and cooldowns.
  Future<void> force(SgCandidate c) async {
    final now = DateTime.now();
    final store = await _loadStore();
    final prev = store.instances[c.key];
    final next = store.withInstance(
      (prev ?? SgInstance(key: c.key, type: c.type)).copyWith(
        state: SgState.active,
        firstShownAt: prev?.firstShownAt ?? now,
        shownDays: [SgScheduler.dayStamp(now)],
        snoozedUntil: () => null,
        resolvedAt: () => null,
      ),
    );
    await _saveStore(next);
    _lockedSession = null;
    _resolvedSession = ref.read(homeSessionProvider);
    _show(c);
  }
}

final homeSuggestionProvider =
    NotifierProvider<HomeSuggestionNotifier, SuggestionView>(
      HomeSuggestionNotifier.new,
    );

/// Plain text of a Kuber note (Quill delta JSON).
String noteText(String content) {
  try {
    final ops = jsonDecode(content) as List;
    return [
      for (final o in ops)
        if (o is Map && o['insert'] is String) o['insert'] as String,
    ].join();
  } catch (_) {
    return content;
  }
}
