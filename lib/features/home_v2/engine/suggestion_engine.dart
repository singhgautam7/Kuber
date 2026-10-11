/// Home v2 suggestion rules (suggestion-rules.md §3), pure Dart: no Flutter,
/// no Isar. The provider builds an [SgInput] snapshot from data already in
/// memory plus a few counts; [SuggestionEngine.evaluate] returns every
/// instance whose trigger is true. Choosing which one to show (caps,
/// cooldowns, snooze, priority) is `SgScheduler`'s job.
library;

/// Suggestion types. Data types 1 to 6, discovery D1 to D4.
enum SgType {
  loans(1),
  creditCard(2),
  recurring(3),
  investments(4),
  budget(5),
  ledger(6),
  askKuber(101),
  voice(102),
  homeWidget(103),
  kuberCards(104);

  const SgType(this.priority);

  /// Lower wins. Discovery types sort after every data type.
  final int priority;

  bool get isDiscovery => priority > 100;
}

/// One transaction, reduced to what the rules read.
class SgTxn {
  final DateTime at;
  final double amount;
  final bool isExpense;
  final bool isTransfer;
  final String name;
  final String categoryId;
  final String accountId;
  final bool fromSms;

  /// Raw SMS body for SMS-imported rows, else null.
  final String? smsText;

  /// Transaction note, if any.
  final String? note;

  const SgTxn({
    required this.at,
    required this.amount,
    required this.isExpense,
    this.isTransfer = false,
    required this.name,
    this.categoryId = '',
    this.accountId = '',
    this.fromSms = false,
    this.smsText,
    this.note,
  });
}

/// A staged (not yet imported) bank SMS.
class SgStagedSms {
  final DateTime at;
  final String text;
  final String sender;
  final double amount;
  const SgStagedSms({
    required this.at,
    required this.text,
    required this.sender,
    required this.amount,
  });
}

class SgAccount {
  final int id;
  final String name;
  final bool isCreditCard;
  final bool isBank;
  final int? billingDay;
  const SgAccount({
    required this.id,
    required this.name,
    this.isCreditCard = false,
    this.isBank = false,
    this.billingDay,
  });
}

class SgRule {
  final String name;
  final String categoryId;
  final double amount;
  final bool active;
  const SgRule({
    required this.name,
    required this.categoryId,
    required this.amount,
    this.active = true,
  });
}

class SgNote {
  final DateTime at;
  final String title;
  final String body;
  const SgNote({required this.at, required this.title, required this.body});
}

/// Everything the rules read. Transactions should be pre-filtered to the
/// longest look-back ([lookBackDays]); [totalTxnCount] counts all of them.
class SgInput {
  final DateTime now;
  final List<SgTxn> txns;
  final int totalTxnCount;
  final List<SgStagedSms> staged;
  final Map<String, String> categoryNames;
  final List<SgAccount> accounts;
  final List<SgRule> rules;
  final Set<String> activeBudgetCategoryIds;
  final int loanCount;
  final int investmentCount;
  final int ledgerCount;
  final int kuberCardCount;
  final bool cardsSetupStarted;
  final List<SgNote> notes;
  final String languageCode;

  // Discovery inputs. Null = unknown (not fetched): the rule stays false.
  final bool askOpened;
  final bool voiceUsed;
  final bool quickAddOnHome;
  final bool? speechAvailable;
  final bool isAndroid;
  final bool? pinWidgetSupported;
  final bool? hasHomeWidget;
  final int installAgeDays;

  const SgInput({
    required this.now,
    this.txns = const [],
    this.totalTxnCount = 0,
    this.staged = const [],
    this.categoryNames = const {},
    this.accounts = const [],
    this.rules = const [],
    this.activeBudgetCategoryIds = const {},
    this.loanCount = 0,
    this.investmentCount = 0,
    this.ledgerCount = 0,
    this.kuberCardCount = 0,
    this.cardsSetupStarted = false,
    this.notes = const [],
    this.languageCode = 'en',
    this.askOpened = false,
    this.voiceUsed = false,
    this.quickAddOnHome = false,
    this.speechAvailable,
    this.isAndroid = false,
    this.pinWidgetSupported,
    this.hasHomeWidget,
    this.installAgeDays = 0,
  });

  /// Longest look-back any rule needs: the recurring rule's three calendar
  /// months ending within the last 40 days.
  static const lookBackDays = 130;
}

/// One suggestion instance whose trigger is true.
class SgCandidate {
  final SgType type;
  final String key;

  /// Tie-break within a type: higher wins.
  final double rank;

  /// Display + prefill values (amounts as numbers; the UI formats them).
  final Map<String, Object?> data;

  const SgCandidate({
    required this.type,
    required this.key,
    this.rank = 0,
    this.data = const {},
  });

  @override
  String toString() => 'SgCandidate($key, rank: $rank)';
}

class SuggestionEngine {
  const SuggestionEngine._();

  static List<SgCandidate> evaluate(SgInput i) => [
    ?_loans(i),
    ..._creditCards(i),
    ..._recurring(i),
    ?_investments(i),
    ..._budgets(i),
    ?_ledger(i),
    ?_askKuber(i),
    ?_voice(i),
    ?_homeWidget(i),
    ?_kuberCards(i),
  ];

  // ── Helpers ───────────────────────────────────────────────────────────

  static final _upiHandle = RegExp(r'@\S*');
  static final _nonLetters = RegExp(r'[^a-z\s]');
  static final _spaces = RegExp(r'\s+');

  /// Payee name lowercased, UPI handle reduced to the payee name, digits and
  /// punctuation stripped.
  static String merchantKey(String raw) {
    var s = raw.toLowerCase();
    if (s.contains('@')) s = s.replaceAll(_upiHandle, ' ');
    s = s.replaceAll(_nonLetters, ' ').replaceAll(_spaces, ' ').trim();
    return s;
  }

  static bool _within(DateTime at, DateTime now, int days) =>
      !at.isAfter(now) && now.difference(at).inDays < days;

  static double _median(List<double> v) {
    final s = List.of(v)..sort();
    final n = s.length;
    return n.isOdd ? s[n ~/ 2] : (s[n ~/ 2 - 1] + s[n ~/ 2]) / 2;
  }

  static String _cat(SgInput i, String id) =>
      (i.categoryNames[id] ?? '').toLowerCase();

  static final _emi = RegExp(r'\bemi\b', caseSensitive: false);
  static final _sip = RegExp(
    r'\bsip\b|mutual fund|\bnach\b.*\b(amc|mutual|fund|mf)\b',
    caseSensitive: false,
  );

  /// Lender display name from an SMS sender id ("AX-HDFCBK" → "HDFC").
  static String lenderFromSender(String sender) {
    var s = sender.toUpperCase();
    final dash = s.indexOf('-');
    if (dash >= 0) s = s.substring(dash + 1);
    s = s.replaceAll(RegExp(r'[^A-Z]'), '');
    for (final suffix in ['BANK', 'BNK', 'BK', 'TXN', 'SMS']) {
      if (s.length > suffix.length + 1 && s.endsWith(suffix)) {
        s = s.substring(0, s.length - suffix.length);
        break;
      }
    }
    return s.isEmpty ? sender : s;
  }

  // ── 1. Loans ──────────────────────────────────────────────────────────

  static SgCandidate? _loans(SgInput i) {
    if (i.loanCount > 0) return null;
    // Newest EMI evidence: an EMI-tagged SMS transaction or a transaction in
    // a Loan / EMI category, or a staged SMS that mentions EMI.
    DateTime? at;
    double? amount;
    String? lender;
    for (final t in i.txns) {
      if (!t.isExpense || !_within(t.at, i.now, 60)) continue;
      final c = _cat(i, t.categoryId);
      final emiCat = c.contains('emi') || c.contains('loan');
      final emiSms = t.fromSms && _emi.hasMatch(t.smsText ?? '');
      if ((emiCat || emiSms) && (at == null || t.at.isAfter(at))) {
        at = t.at;
        amount = t.amount;
        lender = t.name;
      }
    }
    for (final s in i.staged) {
      if (!_within(s.at, i.now, 60) || !_emi.hasMatch(s.text)) continue;
      if (at == null || s.at.isAfter(at)) {
        at = s.at;
        amount = s.amount;
        lender = lenderFromSender(s.sender);
      }
    }
    if (at == null) return null;
    return SgCandidate(
      type: SgType.loans,
      key: 'loans',
      data: {'lender': lender, 'amount': amount, 'day': at.day},
    );
  }

  // ── 2. Credit card billing cycle ──────────────────────────────────────

  static List<SgCandidate> _creditCards(SgInput i) {
    final out = <SgCandidate>[];
    for (final a in i.accounts) {
      if (!a.isCreditCard || a.billingDay != null) continue;
      DateTime? latest;
      for (final t in i.txns) {
        if (t.fromSms &&
            t.accountId == '${a.id}' &&
            _within(t.at, i.now, 60) &&
            (latest == null || t.at.isAfter(latest))) {
          latest = t.at;
        }
      }
      if (latest == null) continue;
      out.add(
        SgCandidate(
          type: SgType.creditCard,
          key: 'cc:${a.id}',
          rank: latest.millisecondsSinceEpoch.toDouble(),
          data: {'card': a.name, 'accountId': a.id},
        ),
      );
    }
    return out;
  }

  // ── 3. Recurring ──────────────────────────────────────────────────────

  static int _monthIndex(DateTime d) => d.year * 12 + d.month - 1;

  /// Day-of-month with month ends folded together (28, 30 and 31 compare
  /// equal), so "last day of the month" charges match.
  static int _clampedDay(DateTime d) => d.day > 28 ? 28 : d.day;

  /// Known subscription services. Matched at the start of a word in the
  /// merchant key ("GOOGLE *YouTubePremium" → "google youtubepremium");
  /// tokens under 4 letters must be a whole word. Digits are already
  /// stripped ("Zee5" → "zee"). A match groups every spelling under one
  /// service ("NETFLIX.COM", "Netflix Entertainment") and needs 2 monthly
  /// charges instead of 3; the amount and day checks still apply, which is
  /// what keeps a prefix like "canva" in "canvas" from triggering on its
  /// own. Value: display name.
  static const _subscriptions = {
    'netflix': 'Netflix',
    'spotify': 'Spotify',
    'youtube premium': 'YouTube Premium',
    'youtube': 'YouTube Premium',
    'amazon prime': 'Amazon Prime',
    'prime video': 'Amazon Prime',
    'hotstar': 'JioHotstar',
    'jiohotstar': 'JioHotstar',
    'disney': 'JioHotstar',
    'jiocinema': 'JioHotstar',
    'sonyliv': 'Sony LIV',
    'sony liv': 'Sony LIV',
    'zee': 'ZEE5',
    'aha': 'aha',
    'sun nxt': 'Sun NXT',
    'sunnxt': 'Sun NXT',
    'discovery plus': 'discovery+',
    'mubi': 'MUBI',
    'crunchyroll': 'Crunchyroll',
    'apple com bill': 'Apple',
    'itunes': 'Apple',
    'icloud': 'iCloud',
    'apple music': 'Apple Music',
    'google one': 'Google One',
    'google storage': 'Google One',
    'gaana': 'Gaana',
    'jiosaavn': 'JioSaavn',
    'saavn': 'JioSaavn',
    'wynk': 'Wynk',
    'audible': 'Audible',
    'kindle unlimited': 'Kindle Unlimited',
    'linkedin': 'LinkedIn Premium',
    'openai': 'ChatGPT',
    'chatgpt': 'ChatGPT',
    'claude': 'Claude',
    'anthropic': 'Claude',
    'microsoft': 'Microsoft 365',
    'adobe': 'Adobe',
    'canva': 'Canva',
    'notion': 'Notion',
    'dropbox': 'Dropbox',
    'duolingo': 'Duolingo',
    'headspace': 'Headspace',
    'cult fit': 'cult.fit',
    'cultfit': 'cult.fit',
    'swiggy one': 'Swiggy One',
    'zomato gold': 'Zomato Gold',
    'times prime': 'Times Prime',
    'playstation': 'PlayStation Plus',
    'xbox': 'Xbox Game Pass',
  };

  /// The subscription service in a merchant key, as its display name.
  static String? subscriptionOf(String key) {
    final padded = ' $key ';
    for (final e in _subscriptions.entries) {
      final t = e.key.length < 4 ? ' ${e.key} ' : ' ${e.key}';
      if (padded.contains(t)) return e.value;
    }
    return null;
  }

  static List<SgCandidate> _recurring(SgInput i) {
    // Grouping key per raw name, looked up once per distinct name: a
    // subscription service's display name, else the merchant key.
    final keyMemo = <String, String>{};
    final subDisplay = <String, String>{}; // group key → service name
    String groupKey(String raw) => keyMemo.putIfAbsent(raw, () {
      final k = merchantKey(raw);
      final sub = subscriptionOf(k);
      if (sub == null) return k;
      final sk = merchantKey(sub);
      subDisplay[sk] = sub;
      return sk;
    });

    // group key → month index → latest charge in that month.
    final byMerchant = <String, Map<int, SgTxn>>{};
    for (final t in i.txns) {
      if (!t.isExpense || t.isTransfer) continue;
      final key = groupKey(t.name);
      if (key.length < 2) continue;
      final months = byMerchant.putIfAbsent(key, () => {});
      final m = _monthIndex(t.at);
      final prev = months[m];
      if (prev == null || t.at.isAfter(prev.at)) months[m] = t;
    }
    final out = <SgCandidate>[];
    byMerchant.forEach((key, months) {
      final service = subDisplay[key];
      final need = service != null ? 2 : 3;
      if (months.length < need) return;
      final latestMonth = months.keys.reduce((a, b) => a > b ? a : b);
      final latest = months[latestMonth]!;
      if (!_within(latest.at, i.now, 40)) return;
      final run = [for (var k = 0; k < need; k++) months[latestMonth - k]];
      if (run.any((t) => t == null)) return;
      final charges = run.cast<SgTxn>();
      final amounts = [for (final t in charges) t.amount];
      final med = _median(amounts);
      if (med < 50) return;
      final tol = med * 0.10 > 20 ? med * 0.10 : 20;
      if (amounts.any((a) => (a - med).abs() > tol)) return;
      final days = [for (final t in charges) _clampedDay(t.at).toDouble()];
      final medDay = _median(days);
      if (days.any((d) => (d - medDay).abs() > 3)) return;
      // Already covered by an active recurring rule?
      final covered = i.rules.any(
        (r) =>
            r.active &&
            (groupKey(r.name) == key ||
                (r.categoryId == latest.categoryId &&
                    (r.amount - med).abs() <= med * 0.10)),
      );
      if (covered) return;
      var streak = need;
      while (months.containsKey(latestMonth - streak)) {
        streak++;
      }
      final next = DateTime(latest.at.year, latest.at.month + 1, latest.at.day);
      out.add(
        SgCandidate(
          type: SgType.recurring,
          key: 'recurring:$key',
          rank: med,
          data: {
            'merchant': service ?? latest.name,
            'amount': med,
            // Months in a row with a charge, for the card copy.
            'months': streak,
            'nextDate': next,
            'accountId': latest.accountId,
            'categoryId': latest.categoryId,
          },
        ),
      );
    });
    return out;
  }

  // ── 4. Investments ────────────────────────────────────────────────────

  static const _amcs = [
    'sbi mutual',
    'hdfc mutual',
    'icici prudential',
    'axis mutual',
    'nippon',
    'kotak mahindra mutual',
    'aditya birla',
    'uti mutual',
    'mirae',
    'parag parikh',
    'dsp',
    'tata mutual',
    'quant',
    'motilal',
    'groww',
    'zerodha',
  ];

  static String? _amcIn(String text) {
    final t = text.toLowerCase();
    for (final a in _amcs) {
      if (t.contains(a)) return a;
    }
    return null;
  }

  static SgCandidate? _investments(SgInput i) {
    if (i.investmentCount > 0) return null;
    DateTime? at;
    double? amount;
    String? amc;
    bool sipText(String s) => _sip.hasMatch(s) || _amcIn(s) != null;
    for (final t in i.txns) {
      if (!_within(t.at, i.now, 60)) continue;
      final text = '${t.name} ${t.smsText ?? ''}';
      if (sipText(text) && (at == null || t.at.isAfter(at))) {
        at = t.at;
        amount = t.amount;
        amc = _amcIn(text);
      }
    }
    for (final s in i.staged) {
      if (!_within(s.at, i.now, 60) || !sipText(s.text)) continue;
      if (at == null || s.at.isAfter(at)) {
        at = s.at;
        amount = s.amount;
        amc = _amcIn(s.text);
      }
    }
    if (at == null) return null;
    return SgCandidate(
      type: SgType.investments,
      key: 'investments',
      data: {'amount': amount, 'amc': amc, 'day': at.day},
    );
  }

  // ── 5. Budget ─────────────────────────────────────────────────────────

  static bool _budgetExcluded(String categoryName) {
    for (final w in const [
      'transfer',
      'emi',
      'loan',
      'investment',
      'rent',
      'lent',
      'borrow',
    ]) {
      if (categoryName.contains(w)) return true;
    }
    return false;
  }

  /// ISO-8601 week number key (year * 100 + week).
  static int isoWeekKey(DateTime d) {
    final day = DateTime.utc(d.year, d.month, d.day);
    final thursday = day.add(Duration(days: 4 - day.weekday));
    final firstDay = DateTime.utc(thursday.year, 1, 1);
    final week = (thursday.difference(firstDay).inDays ~/ 7) + 1;
    return thursday.year * 100 + week;
  }

  static List<SgCandidate> _budgets(SgInput i) {
    final count = <String, int>{};
    final total = <String, double>{};
    final weeks = <String, Set<int>>{};
    for (final t in i.txns) {
      if (!t.isExpense || t.isTransfer || !_within(t.at, i.now, 30)) continue;
      final c = t.categoryId;
      if (c.isEmpty || i.activeBudgetCategoryIds.contains(c)) continue;
      if (_budgetExcluded(_cat(i, c))) continue;
      count[c] = (count[c] ?? 0) + 1;
      total[c] = (total[c] ?? 0) + t.amount;
      (weeks[c] ??= {}).add(isoWeekKey(t.at));
    }
    final out = <SgCandidate>[];
    count.forEach((c, n) {
      final sum = total[c]!;
      if (n < 4 || weeks[c]!.length < 3 || sum < 1000) return;
      out.add(
        SgCandidate(
          type: SgType.budget,
          key: 'budget:$c',
          rank: sum,
          data: {
            'categoryId': c,
            'category': i.categoryNames[c] ?? c,
            'total': sum,
            'amount': (sum / 500).ceil() * 500.0,
          },
        ),
      );
    });
    return out;
  }

  // ── 6. Lend and borrow ────────────────────────────────────────────────

  /// Localized "lending" keywords. English and Hindi ship first
  /// (open-decisions 22); the note variant is off for other languages.
  static const ledgerKeywords = <String, List<String>>{
    'en': ['lent', 'borrowed', 'gave', 'owe', 'udhaar', 'udhar'],
    'hi': ['lent', 'borrowed', 'gave', 'owe', 'udhaar', 'udhar', 'उधार'],
  };

  static const _merchantWords = {
    'store',
    'stores',
    'mart',
    'pvt',
    'ltd',
    'limited',
    'restaurant',
    'cafe',
    'foods',
    'food',
    'swiggy',
    'zomato',
    'amazon',
    'flipkart',
    'uber',
    'ola',
    'paytm',
    'phonepe',
    'gpay',
    'bank',
    'services',
    'technologies',
    'india',
    'enterprises',
    'traders',
    'medical',
    'pharmacy',
    'petrol',
    'fuel',
    'recharge',
    'airtel',
    'jio',
    'netflix',
    'spotify',
    'google',
    'apple',
    'shop',
    'retail',
    'hotel',
    'pay',
    'bill',
    'insurance',
    'electricity',
  };

  /// ponytail: heuristic "person payee": an SMS-imported debit whose payee
  /// is 1 to 3 alphabetic words with no merchant word. Replace with a
  /// parser flag if the SMS parser ever classifies P2P payments.
  static bool isPersonPayee(String name) {
    final key = merchantKey(name);
    if (key.isEmpty || key.length < 3) return false;
    final words = key.split(' ');
    if (words.length > 3) return false;
    return !words.any(_merchantWords.contains);
  }

  static bool _isLatin(String w) => RegExp(r'^[a-z]+$').hasMatch(w);

  static SgCandidate? _ledger(SgInput i) {
    if (i.ledgerCount > 0) return null;
    // Transfer variant: payments to the same person in the last 30 days.
    final byPerson = <String, double>{};
    final display = <String, String>{};
    for (final t in i.txns) {
      if (!t.isExpense || !t.fromSms || !_within(t.at, i.now, 30)) continue;
      final upi = (t.smsText ?? '').toLowerCase().contains('upi');
      if (!upi || !isPersonPayee(t.name)) continue;
      final k = merchantKey(t.name);
      byPerson[k] = (byPerson[k] ?? 0) + t.amount;
      display[k] = t.name;
    }
    String? best;
    for (final e in byPerson.entries) {
      if (e.value >= 1000 && (best == null || e.value > byPerson[best]!)) {
        best = e.key;
      }
    }
    if (best != null) {
      return SgCandidate(
        type: SgType.ledger,
        key: 'ledger',
        rank: byPerson[best]!,
        data: {
          'variant': 'transfer',
          'name': display[best],
          'amount': byPerson[best],
        },
      );
    }
    // Note variant.
    final words = ledgerKeywords[i.languageCode];
    if (words == null) return null;
    // Latin keywords match whole words ("owe" does not match "flower");
    // other scripts (उधार) match as substrings.
    final latin = RegExp(
      '\\b(${words.where(_isLatin).map(RegExp.escape).join('|')})\\b',
    );
    final other = words.where((w) => !_isLatin(w)).toList();
    bool hit(String s) {
      final l = s.toLowerCase();
      return latin.hasMatch(l) || other.any(l.contains);
    }

    for (final n in i.notes) {
      if (_within(n.at, i.now, 30) && hit('${n.title} ${n.body}')) {
        return SgCandidate(
          type: SgType.ledger,
          key: 'ledger',
          data: {'variant': 'note', 'note': n.title},
        );
      }
    }
    for (final t in i.txns) {
      final note = t.note;
      if (note != null && _within(t.at, i.now, 30) && hit(note)) {
        return SgCandidate(
          type: SgType.ledger,
          key: 'ledger',
          data: {'variant': 'note', 'note': note, 'amount': t.amount},
        );
      }
    }
    return null;
  }

  // ── Discovery ─────────────────────────────────────────────────────────

  static SgCandidate? _askKuber(SgInput i) =>
      i.totalTxnCount >= 20 && !i.askOpened
      ? const SgCandidate(type: SgType.askKuber, key: 'ask_kuber')
      : null;

  static SgCandidate? _voice(SgInput i) =>
      i.totalTxnCount >= 10 &&
          i.quickAddOnHome &&
          !i.voiceUsed &&
          i.speechAvailable == true
      ? const SgCandidate(type: SgType.voice, key: 'voice')
      : null;

  static SgCandidate? _homeWidget(SgInput i) =>
      i.isAndroid &&
          i.pinWidgetSupported == true &&
          i.hasHomeWidget == false &&
          i.installAgeDays >= 7 &&
          i.totalTxnCount >= 15
      ? const SgCandidate(type: SgType.homeWidget, key: 'home_widget')
      : null;

  static SgCandidate? _kuberCards(SgInput i) =>
      i.accounts.any((a) => a.isBank || a.isCreditCard) &&
          i.kuberCardCount == 0 &&
          !i.cardsSetupStarted &&
          i.installAgeDays >= 14
      ? const SgCandidate(type: SgType.kuberCards, key: 'kuber_cards')
      : null;
}
