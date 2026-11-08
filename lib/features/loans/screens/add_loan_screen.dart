// Add / edit loan (design L.2 to L.4).
// Simple form: type, name, lender, EMI, pay from, EMI schedule (When EMI
// variant), record EMIs. Advanced options: interest type, loan numbers (any 3
// of principal / rate / tenure / EMI give the 4th, total payable can replace
// the rate, swap keeps the fill order), "Already running?" with three starting
// points, "Count only interest as expense", and (November release) received
// in, released in parts and interest before EMIs start.

import 'package:flutter/material.dart';
import 'package:kuber/core/models/overflow_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/background/background_reporter.dart';
import '../../../core/database/isar_service.dart';
import '../../../core/money_math/loan_math.dart';
import '../../../core/schedule/schedule.dart';
import '../../../core/schedule/schedule_engine.dart';
import '../../../core/schedule/schedule_text.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart' show CurrencyInputFormatter;
import '../../../core/utils/l10n_ext.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_form_widgets.dart';
import '../../../shared/widgets/money_info_sheets.dart';
import '../../../shared/widgets/money_widgets.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../../shared/widgets/when_picker.dart';
import '../../accounts/providers/account_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../transactions/widgets/entity_picker_rows.dart';
import '../data/loan.dart';
import '../domain/loan_engine.dart';
import '../domain/loan_service.dart';
import '../providers/loan_provider.dart';
import '../widgets/loan_add_sheet.dart';
import '../widgets/loan_adjust_sheet.dart';
import '../widgets/loan_sheet.dart';

/// One row of "Released so far".
class _Part {
  DateTime date;
  final TextEditingController amount;
  int? accountId;
  LoanAdjust adjust;

  /// The stored release this row edits (keeps its transaction link and note).
  final LoanRelease? origin;

  _Part(this.date, String amountText, {this.accountId, this.adjust = LoanAdjust.tenure, this.origin})
      : amount = TextEditingController(text: amountText);

  double get value => KuberAmountField.valueOf(amount);
}

class AddLoanScreen extends ConsumerStatefulWidget {
  final Loan? existing;

  /// Prefills: Kuber Notes amount (principal), Home v2 lender / EMI, the EMI
  /// calculator's "Add as loan" (principal, rate, months, from).
  final double? amountPrefill;
  final String? lenderPrefill;
  final double? emiPrefill;
  final double? ratePrefill;
  final int? monthsPrefill;
  final String? fromCalculator;

  const AddLoanScreen({
    super.key,
    this.existing,
    this.amountPrefill,
    this.lenderPrefill,
    this.emiPrefill,
    this.ratePrefill,
    this.monthsPrefill,
    this.fromCalculator,
  });

  @override
  ConsumerState<AddLoanScreen> createState() => _AddLoanScreenState();
}

class _AddLoanScreenState extends ConsumerState<AddLoanScreen> {
  final _name = TextEditingController();
  final _lender = TextEditingController();
  final _emi = TextEditingController();
  final _principal = TextEditingController();
  final _rate = TextEditingController();
  final _tenure = TextEditingController();
  final _total = TextEditingController();
  final _ioMonths = TextEditingController();
  final _outstanding = TextEditingController(); // run 1 override / run 2 input
  final _pastPrincipal = TextEditingController();
  final _pastInterest = TextEditingController();

  String _type = 'personal';
  int? _accountId;
  late WhenValue _when;
  bool _autoRecord = true;
  bool _advanced = false;
  LoanInterestType _interest = LoanInterestType.reducingBalance;
  bool _tenureYears = true;
  bool _running = false;
  LoanStartingPoint _start = LoanStartingPoint.originalDetails;

  /// "Add past EMIs as transactions" (Part B), and the EMI days the stored
  /// loan already has (a ledger row or a transaction), for the preview.
  bool _pastEmis = false;
  Set<int> _handled = const {};

  bool get _pastEmisApplies =>
      _running && _start == LoanStartingPoint.originalDetails && (_solution?.ok ?? false);
  bool _onlyInterest = false;
  bool _saving = false;
  String? _fromCalc;

  /// Anything that decides the loan's numbers changed since the form opened.
  /// An edit that only renames must save them as stored, not re-derive them.
  bool _numbersTouched = false;
  bool _whenTouched = false;

  // Released in parts and interest before EMIs (A1, A2).
  DateTime? _loanStart;
  int? _receivedId;
  bool _inParts = false;
  final List<_Part> _parts = [];
  final Set<int> _keepTxnIds = {};
  LoanPreEmi _preEmi = LoanPreEmi.payMonthly;
  final _preEmiDay = TextEditingController();
  final _preEmiAdded = TextEditingController();
  bool _preEmiEdited = false;
  double? _preEmiSeen;
  PreEmi? _ledgerNow;

  /// Fill order of the loan numbers (most recent last), at most 3; the
  /// missing one is calculated. All 4 present = mismatch check.
  final List<LoanField> _order = [];
  String? _swapHelp;
  bool _programmatic = false;

  Loan? get _existing => widget.existing;

  @override
  void initState() {
    super.initState();
    final l = _existing;
    _when = WhenValue(
      start: DateUtils.dateOnly(DateTime.now()),
      unit: ScheduleUnit.month,
      endType: ScheduleEnd.afterCount,
      endCount: 12,
    );
    if (l != null) {
      _type = l.loanType;
      _name.text = l.name;
      _lender.text = l.lenderName;
      _accountId = int.tryParse(l.accountId);
      if (l.emiAmount > 0) _emi.text = _amt(l.emiAmount);
      if (l.schedule != null) _when = WhenValue.fromSchedule(l.schedule!);
      _autoRecord = l.schedule?.autoRecord ?? l.autoAddTransaction;
      _interest = l.interestType;
      _running = l.alreadyRunning;
      _start = l.startingPoint;
      _pastEmis = l.addPastEmis;
      LoanService(ref.read(isarProvider)).handledDays(l).then((d) {
        if (mounted) setState(() => _handled = d);
      });
      _onlyInterest = l.countOnlyInterest;
      if (l.interestOnlyMonths > 0) _ioMonths.text = '${l.interestOnlyMonths}';
      _loanStart = l.loanStartDate;
      _inParts = l.releasedInParts;
      if (l.releasedInParts) {
        _parts.addAll([
          for (final r in loanReleases(l))
            _Part(r.date!, _amt(r.amount),
                accountId: int.tryParse(r.accountId ?? ''), adjust: r.adjust, origin: r),
        ]);
      } else {
        _receivedId = int.tryParse(l.releases.firstOrNull?.accountId ?? '');
      }
      if (l.preEmiMode != LoanPreEmi.none) _preEmi = l.preEmiMode;
      if (l.preEmiCycleDay != null) _preEmiDay.text = '${l.preEmiCycleDay}';
      if (l.preEmiOverride != null) {
        _preEmiEdited = true;
        _preEmiAdded.text = _amt(l.preEmiOverride!);
        _preEmiSeen = l.preEmiCalculated;
      }
      final hasNumbers = hasLoanNumbers(l);
      if (hasNumbers) {
        _advanced = true;
        if (l.principalAmount > 0) _principal.text = _amt(l.principalAmount);
        if (l.annualRate != null) _rate.text = _rateText(l.annualRate!);
        final months = l.tenureMonths!;
        _tenureYears = months % 12 == 0;
        _tenure.text = _tenureYears ? '${months ~/ 12}' : '$months';
        _order.addAll([LoanField.principal, LoanField.rate, LoanField.tenure, LoanField.emi]);
      }
      if (l.outstandingAtStart != null) {
        _outstanding.text = _amt(l.outstandingAtStart!);
        _outstandingEdited = true;
      }
      if (l.principalPaidBefore > 0) _pastPrincipal.text = _amt(l.principalPaidBefore);
      if (l.interestPaidBefore > 0) _pastInterest.text = _amt(l.interestPaidBefore);
      if (hasNumbers) {
        _recompute();
        _numbersTouched = false;
      }
    } else {
      if (widget.lenderPrefill != null) _lender.text = widget.lenderPrefill!;
      if ((widget.emiPrefill ?? 0) > 0) {
        _emi.text = _amt(widget.emiPrefill!);
        _order.add(LoanField.emi);
      }
      if ((widget.amountPrefill ?? 0) > 0) {
        _advanced = true;
        _principal.text = _amt(widget.amountPrefill!);
        _order.add(LoanField.principal);
      }
      if (widget.ratePrefill != null) {
        _advanced = true;
        _rate.text = _num(widget.ratePrefill!);
        _order.add(LoanField.rate);
      }
      if (widget.monthsPrefill != null) {
        _advanced = true;
        final m = widget.monthsPrefill!;
        _tenureYears = m % 12 == 0;
        _tenure.text = _tenureYears ? '${m ~/ 12}' : '$m';
        _order.add(LoanField.tenure);
      }
      _fromCalc = widget.fromCalculator;
      while (_order.length > 3) {
        _order.removeAt(0);
      }
      _recompute();
    }
  }

  @override
  void dispose() {
    for (final c in [
      _name, _lender, _emi, _principal, _rate, _tenure, _total, _ioMonths,
      _outstanding, _pastPrincipal, _pastInterest, _preEmiDay, _preEmiAdded,
      for (final p in _parts) p.amount,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  static String _num(double v) => v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

  /// A stored rate as it is: rounding it here would change the loan on save.
  static String _rateText(double v) => v % 1 == 0 ? v.toStringAsFixed(0) : '$v';

  /// Amount text as the user would type it, grouped per the number format.
  String _amt(num v) => CurrencyInputFormatter(
          isIndian: ref.read(formatterProvider).system == NumberSystem.indian)
      .format(_num(v.toDouble()));

  /// Run 1: "Outstanding today" follows the calculated value until the user
  /// types their own figure.
  bool _outstandingEdited = false;
  double? _val(TextEditingController c) {
    final v = double.tryParse(c.text.replaceAll(',', '').trim());
    return v;
  }

  int? get _months {
    final t = _val(_tenure);
    if (t == null || t <= 0) return null;
    return _tenureYears ? (t * 12).round() : t.round();
  }

  int get _io =>
      _interest == LoanInterestType.interestOnlyFirst ? (int.tryParse(_ioMonths.text) ?? 0) : 0;

  RateKind get _kind => switch (_interest) {
        LoanInterestType.reducingBalance => RateKind.reducing,
        LoanInterestType.flatRate => RateKind.flat,
        LoanInterestType.interestOnlyFirst => RateKind.interestOnlyFirst,
      };

  LoanField? get _calculated {
    if (_val(_total) != null && (_val(_total) ?? 0) > 0) return LoanField.rate;
    if (_order.length != 3) return null;
    return LoanField.values.firstWhere((f) => !_order.contains(f));
  }

  TextEditingController _ctrl(LoanField f) => switch (f) {
        LoanField.principal => _principal,
        LoanField.rate => _rate,
        LoanField.tenure => _tenure,
        LoanField.emi => _emi,
      };

  String _fieldName(LoanField f) {
    final l = context.l10n;
    return switch (f) {
      LoanField.principal => l.msLoansPrincipal.toLowerCase(),
      LoanField.rate => l.msLoansRate.toLowerCase(),
      LoanField.tenure => l.msLoansTenure.toLowerCase(),
      LoanField.emi => l.msLoansEmi,
    };
  }

  void _typed(LoanField f) {
    if (_programmatic) return;
    _order.remove(f);
    if (_ctrl(f).text.trim().isNotEmpty) _order.add(f);
    _swapHelp = null;
    while (_order.length > 3) {
      final out = _order.removeAt(0);
      _swapHelp = context.l10n.msLoansSwapHelp(_fieldName(f), _fieldName(out));
    }
    _recompute();
  }

  LoanSolution? _solution;

  /// Parts and pre-EMI interest need a history to walk, which "outstanding
  /// today" and "just track the EMI" don't have.
  bool get _releasesApply => !_running || _start == LoanStartingPoint.originalDetails;

  /// An existing interest-only-first loan keeps its own card and months; the
  /// section below is the same thing for every other loan.
  bool get _legacyIo => _interest == LoanInterestType.interestOnlyFirst;

  DateTime get _startDay {
    final first = DateUtils.dateOnly(_when.firstOccurrence);
    final s = _loanStart;
    return s == null || s.isAfter(first) ? first : s;
  }

  /// First release to first EMI is longer than one EMI cycle, or in parts.
  bool get _preEmiShown {
    if (!_advanced || !_releasesApply || _legacyIo) return false;
    final s = _startDay;
    final oneCycle = DateTime(s.year, s.month + 1, s.day);
    return _inParts || oneCycle.isBefore(DateUtils.dateOnly(_when.firstOccurrence));
  }

  /// The walk to the first EMI as the form stands, or null when off.
  PreEmi? _ledger() {
    if (!_advanced || !_releasesApply) return null;
    final shown = _preEmiShown;
    if (!_inParts && !shown) return null;
    final rate = _val(_rate);
    if (rate == null) return null;
    final first = dayKey(_when.firstOccurrence);
    final releases = <(int, double)>[
      if (_inParts)
        for (final p in _parts)
          if (dayKey(p.date) <= first) (dayKey(p.date), p.value),
      if (!_inParts)
        (dayKey(_startDay), _val(_principal) ?? 0),
    ]..sort((a, b) => a.$1.compareTo(b.$1));
    if (releases.isEmpty) return null;
    final existing = _existing;
    bool before(AmortEvent e) => e.day < first || (e.day == first && !e.afterEmi);
    final mode = !shown
        ? PreEmiInterest.none
        : (_preEmi == LoanPreEmi.addToLoan ? PreEmiInterest.added : PreEmiInterest.paid);
    return preEmiLedger(
      rate: rate,
      mode: mode,
      cycleDay: int.tryParse(_preEmiDay.text) ?? _when.effectiveAnchor,
      firstEmiDay: first,
      releases: releases,
      events: existing == null ? const [] : amortEventsOf(existing).where(before).toList(),
      override: mode == PreEmiInterest.added && _preEmiEdited ? _val(_preEmiAdded) : null,
    );
  }

  /// Solves the missing number and writes it into its field.
  void _recompute() {
    _numbersTouched = true;
    final calc = _calculated;
    final total = _val(_total);
    final pre = _ledgerNow = _ledger();
    if (pre != null && pre.mode == PreEmiInterest.added && !_preEmiEdited) {
      _preEmiAdded.text = _amt(pre.calculatedAdded.round());
    }
    // A calculated EMI uses the outstanding on the first EMI date.
    final emiPrincipal = pre != null && pre.balance > 0 ? pre.balance : null;
    LoanSolution? s;
    if (total != null && total > 0) {
      s = solveLoan(
          principal: _val(_principal),
          months: _months,
          totalPayable: total,
          emi: _order.contains(LoanField.emi) ? _val(_emi) : null,
          kind: _kind,
          ioMonths: _io);
    } else if (calc != null || _order.length == 4) {
      s = solveLoan(
        principal: calc == LoanField.principal ? null : (emiPrincipal ?? _val(_principal)),
        rate: calc == LoanField.rate ? null : _val(_rate),
        months: calc == LoanField.tenure ? null : _months,
        emi: calc == LoanField.emi ? null : _val(_emi),
        kind: _kind,
        ioMonths: _io,
      );
    }
    _solution = s;
    if (s != null && s.ok) {
      _programmatic = true;
      switch (calc) {
        case LoanField.principal:
          _principal.text = _amt(s.principal.round());
        case LoanField.rate:
          _rate.text = s.rate.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
          if (total != null && !_order.contains(LoanField.emi)) {
            _emi.text = _amt(s.emi.round());
          }
        case LoanField.tenure:
          _tenureYears = s.months % 12 == 0;
          _tenure.text = _tenureYears ? '${s.months ~/ 12}' : '${s.months}';
        case LoanField.emi:
          _emi.text = _amt(s.emi.round());
        case null:
          break;
      }
      _programmatic = false;
      // The EMI schedule follows the tenure.
      if (_when.endType == ScheduleEnd.afterCount && s.months > 0 && !_running) {
        _when = _when.copyWith(endCount: s.months);
      }
    }
    if (mounted) setState(() {});
  }

  /// The loan as the form describes it (also drives the previews).
  Loan _draft() {
    final l = _existing?.copy() ?? Loan();
    final s = _solution;
    final numbers = _advanced && s != null && s.ok;
    // A stored loan keeps its numbers unless the user changed them.
    final stored = _existing;
    final keep = stored != null && hasLoanNumbers(stored) && (!_numbersTouched || !numbers);
    l
      ..name = _name.text.trim()
      ..loanType = _type
      ..lenderName = _lender.text.trim()
      ..accountId = '${_accountId ?? ''}'
      ..emiAmount = keep ? stored.emiAmount : (_val(_emi) ?? (numbers ? s.emi : 0))
      ..mode = numbers || keep ? LoanMode.advanced : LoanMode.simple
      ..interestType = _interest
      // New reducing loans count interest by days, like most banks. A saved
      // loan keeps its own (Interest calculation in its sheet's menu).
      ..interestMethod = _existing?.interestMethod ??
          (_interest == LoanInterestType.reducingBalance ? LoanInterestMethod.daily : LoanInterestMethod.monthly)
      ..interestOnlyMonths = _io
      ..alreadyRunning = _running
      ..countOnlyInterest = (numbers || keep) && _onlyInterest
      ..countOnlyInterestFrom = (numbers || keep) && _onlyInterest
          ? (_existing?.countOnlyInterest == true
              ? _existing!.countOnlyInterestFrom
              : DateUtils.dateOnly(DateTime.now()))
          : null;
    if (keep) {
      // The copy above already holds them.
    } else if (!numbers || (_running && _start == LoanStartingPoint.trackEmiOnly)) {
      l
        ..startingPoint = LoanStartingPoint.trackEmiOnly
        // A new loan has no principal yet (late field): 0 = not tracked.
        ..principalAmount = numbers ? s.principal : (_existing?.principalAmount ?? 0)
        ..annualRate = numbers ? s.rate : null
        ..tenureMonths = _when.endType == ScheduleEnd.afterCount ? _when.endCount : null;
    } else if (_running && _start == LoanStartingPoint.outstandingToday) {
      final o = _val(_outstanding) ?? 0;
      l
        ..startingPoint = LoanStartingPoint.outstandingToday
        ..outstandingAtStart = o
        ..annualRate = s.rate
        ..principalAmount = s.principal
        ..tenureMonths = emisLeftFor(o, s.rate, l.emiAmount,
                kind: _kind == RateKind.flat ? RateKind.flat : RateKind.reducing) ??
            s.months
        ..principalPaidBefore = _val(_pastPrincipal) ?? 0
        ..interestPaidBefore = _val(_pastInterest) ?? 0;
    } else {
      l
        ..startingPoint = LoanStartingPoint.originalDetails
        // The sanctioned amount, not what the EMI was worked out on.
        ..principalAmount = _ledgerNow != null ? (_val(_principal) ?? s.principal) : s.principal
        ..annualRate = s.rate
        ..tenureMonths = s.months;
    }
    l.createdAt = _existing?.createdAt ?? DateTime.now();
    if (keep && !_whenTouched) {
      l.schedule = stored.schedule?.copy()?..autoRecord = _autoRecord;
    } else {
      l.schedule = _schedule(l);
    }
    if (keep) return l;
    _applyReleases(l, numbers);
    // Run 1: an overridden outstanding is stored as an opening adjustment.
    if (numbers && _running && _start == LoanStartingPoint.originalDetails) {
      final calc = LoanService.openingValues(l)?.outstanding;
      final entered = _val(_outstanding);
      l.adjustment = calc != null && entered != null && (entered - calc).abs() >= 1
          ? outstandingAdjustment(calc, entered)
          : 0;
    } else {
      l.adjustment = 0;
    }
    return l;
  }

  /// Writes the "received in", parts and pre-EMI choices onto the draft.
  void _applyReleases(Loan l, bool numbers) {
    final on = numbers && _releasesApply;
    final stored = _existing?.releases.firstOrNull;
    l
      ..loanStartDate = on && _loanStart != null ? _loanStart : _existing?.loanStartDate
      ..releasedInParts = on && _inParts;
    if (on && _inParts) {
      l.releases = [
        for (final p in [..._parts]..sort((a, b) => a.date.compareTo(b.date)))
          LoanRelease()
            ..date = p.date
            ..amount = p.value
            ..accountId = p.accountId?.toString()
            ..transactionId = p.origin?.transactionId
            ..adjust = p.adjust
            ..note = p.origin?.note,
      ];
    } else if (on && _receivedId != null) {
      final today = DateUtils.dateOnly(DateTime.now());
      l.releases = [
        LoanRelease()
          ..date = _startDay.isAfter(today) ? today : _startDay
          ..amount = l.principalAmount
          ..accountId = '$_receivedId'
          ..transactionId = stored?.transactionId,
      ];
    } else {
      l.releases = [];
    }
    final shown = _preEmiShown;
    l
      ..preEmiMode = shown ? _preEmi : LoanPreEmi.none
      ..preEmiCycleDay = shown ? int.tryParse(_preEmiDay.text) : null
      ..preEmiOverride =
          shown && _preEmi == LoanPreEmi.addToLoan && _preEmiEdited ? _val(_preEmiAdded) : null
      ..preEmiCalculated = shown && _preEmi == LoanPreEmi.addToLoan && _preEmiEdited
          ? (_preEmiSeen ?? _ledgerNow?.calculatedAdded)
          : null;
  }

  Schedule _schedule(Loan l) {
    if (l.startingPoint == LoanStartingPoint.outstandingToday) {
      return scheduleFrom(
        start: _nextEmiFromToday(),
        unit: ScheduleUnit.month,
        anchorDay: _when.effectiveAnchor,
        endType: ScheduleEnd.afterCount,
        endCount: l.tenureMonths,
      )..autoRecord = _autoRecord;
    }
    final s = _when.copyWith(unit: ScheduleUnit.month, count: 1).toSchedule()
      ..autoRecord = _autoRecord;
    if (l.tenureMonths != null && l.startingPoint != LoanStartingPoint.trackEmiOnly) {
      s
        ..endType = ScheduleEnd.afterCount
        ..endCount = l.tenureMonths
        ..endDate = null;
    }
    return s;
  }

  /// Outstanding-today loans: the next EMI on or after today (and after the
  /// picked date) on the EMI day.
  DateTime _nextEmiFromToday() {
    final today = DateUtils.dateOnly(DateTime.now());
    return firstMonthlyOnOrAfter(_when.start.isBefore(today) ? today : _when.start, _when.effectiveAnchor);
  }

  bool get _canSave =>
      !_saving &&
      _name.text.trim().isNotEmpty &&
      _accountId != null &&
      (_val(_emi) ?? 0) > 0 &&
      _when.error(context.l10n) == null &&
      !(_advanced && _solution != null && !_solution!.ok) &&
      _partsError == null;

  /// The first problem with "Released so far".
  String? get _partsError {
    if (!_advanced || !_releasesApply || !_inParts) return null;
    final l = context.l10n;
    final today = DateUtils.dateOnly(DateTime.now());
    if (_parts.any((p) => p.value <= 0)) return l.msLoansErrPartAmount;
    final start = _parts.map((p) => p.date).reduce((a, b) => a.isBefore(b) ? a : b);
    final from = _loanStart ?? start;
    if (_parts.any((p) => p.date.isBefore(from) || p.date.isAfter(today))) {
      return l.msLoansErrPartDate;
    }
    final total = _parts.fold(0.0, (s, p) => s + p.value);
    if (total > (_val(_principal) ?? double.infinity) + 0.005) {
      return l.msLoansErrOverSanctioned;
    }
    if (_solution?.ok ?? false) {
      final a = loanAmortization(_draft());
      if (a != null && loanNeverEnds(a)) return l.msLoansErrNeverEnds;
    }
    return null;
  }

  /// Back to where the form was opened from; opened by a link or shortcut
  /// there is nothing below it, so go to Loans.
  void _leave() => context.canPop() ? context.pop() : context.go('/more/loans');

  Future<void> _save() async {
    final l10n = context.l10n;
    final wasOn = _existing?.addPastEmis ?? false;
    final wantOn = _pastEmis && _pastEmisApplies;
    // Turning "Add past EMIs" off: remove the ones it added?
    bool? remove;
    if (wasOn && !wantOn) {
      final r = await LoanService(ref.read(isarProvider)).pastEmisToRemove(_existing!);
      if (!mounted) return;
      if (r.removable.isNotEmpty) {
        remove = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.msLoansPastEmisRemoveTitle(r.removable.length),
                style: localeFont(fontWeight: FontWeight.w600)),
            content: Text(l10n.msLoansPastEmisRemoveBody, style: localeFont()),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.msLoansKeep)),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.msLoansRemove)),
            ],
          ),
        );
        if (remove == null) return;
      }
    }
    if (!mounted) return;
    final container = ProviderScope.containerOf(context, listen: false);
    setState(() => _saving = true);
    try {
      final draft = _draft();
      final service = LoanService(ref.read(isarProvider));
      final saved = await service.save(draft, draft.schedule!,
          isNew: _existing == null, keepTransactionIds: _keepTxnIds);
      container.invalidate(transactionListProvider);
      ref.invalidate(loanListProvider);
      if (wasOn && !wantOn) {
        final (removed, kept) = await service.removePastEmis(saved, remove: remove ?? false);
        container.invalidate(transactionListProvider);
        if (mounted && (removed > 0 || kept > 0)) {
          showKuberSnackBar(context, l10n.msLoansPastEmisRemoved(removed, kept));
        }
      }
      if (wantOn && !wasOn) {
        // In the background through the reporter; the form doesn't wait.
        // Lists refresh once at the end, not per transaction.
        final decimals = ref.read(formatterProvider).currency.decimals;
        BackgroundReporter.instance
            .run<List<int>>(
              l10n.bgStepPastEmis,
              (progress) => service.addPastEmis(saved, decimals: decimals, onProgress: progress),
              outcome: (ids) => ids.isEmpty
                  ? BgOutcome.none
                  : BgOutcome(l10n.bgAdded(ids.length), transactionIds: ids),
            )
            .then((_) {
              container
                ..invalidate(transactionListProvider)
                ..invalidate(loanListProvider);
            })
            .ignore();
      }
      if (mounted) {
        if (!(wasOn && !wantOn)) showKuberSnackBar(context, l10n.msLoansSaved);
        _leave();
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final fmt = ref.watch(formatterProvider);
    final indian = fmt.system == NumberSystem.indian;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: KuberAppBar(
        showBack: true,
        closeIcon: true,
        onBack: _leave,
        title: _existing == null ? l.msLoansAdd : l.msLoansEdit,
        // Delete sits in the menu, like the other pages' destructive actions.
        overflowConfig: _existing == null
            ? null
            : KuberOverflowConfig(items: [
                KuberOverflowItem(
                  icon: Icons.delete_outline_rounded,
                  label: l.deleteLoanAction,
                  isDestructive: true,
                  onTap: () async {
                    final deleted = await confirmDeleteLoan(context, ref, _existing!);
                    if (deleted && context.mounted) context.pop();
                  },
                ),
              ]),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 140),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_fromCalc != null) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: InputChip(
                    avatar: Icon(Icons.link_rounded, size: 18, color: cs.onSecondaryContainer),
                    label: Text(l.msFromCalculator(_fromCalc!)),
                    selected: true,
                    showCheckmark: false,
                    onDeleted: () => setState(() => _fromCalc = null),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              KuberFormSection(
                label: l.msLoansType,
                topGap: 0,
                children: [
                  KuberChipGrid<String>(
                    selected: _type,
                    onChanged: (v) => setState(() => _type = v),
                    options: [
                      KuberChipOption(value: 'home', label: l.loanTypeHome, icon: Icons.home_outlined),
                      KuberChipOption(value: 'vehicle', label: l.loanTypeVehicle, icon: Icons.directions_car_outlined),
                      KuberChipOption(value: 'personal', label: l.loanTypePersonal, icon: Icons.person_outline_rounded),
                      KuberChipOption(value: 'education', label: l.loanTypeEducation, icon: Icons.school_outlined),
                      KuberChipOption(value: 'credit_card', label: l.creditCardLabel, icon: Icons.credit_card_outlined),
                      KuberChipOption(value: 'other', label: l.loanTypeOther, icon: Icons.more_horiz_rounded),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              KuberTextField(
                label: l.msLoansName,
                controller: _name,
                hint: l.loanNameHint,
                textCapitalization: TextCapitalization.words,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              KuberTextField(
                label: l.msLoansLender,
                controller: _lender,
                hint: l.lenderHint,
                optional: true,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              KuberHeroAmountInput(
                label: l.msLoansEmiAmount,
                currencySymbol: fmt.symbol,
                controller: _emi,
                inputFormatters: [CurrencyInputFormatter(isIndian: indian)],
                onChanged: (_) => _typed(LoanField.emi),
              ),
              const SizedBox(height: 16),
              AccountPickerRow(
                label: l.msLoansPayFrom,
                selectedId: _accountId,
                onChanged: (id) => setState(() => _accountId = id),
              ),
              const SizedBox(height: 24),
              if (!(_running && _start == LoanStartingPoint.outstandingToday))
                KuberWhenPicker(
                  variant: WhenVariant.emi,
                  value: _when,
                  onChanged: (v) => setState(() {
                    _when = v;
                    _whenTouched = true;
                    if (v.endType == ScheduleEnd.afterCount && v.endCount != null &&
                        _order.contains(LoanField.tenure) == false && _advanced) {
                      _tenureYears = false;
                      _tenure.text = '${v.endCount}';
                    }
                  }),
                ),
              const SizedBox(height: 12),
              KuberSwitchRow(
                icon: Icons.bolt_rounded,
                name: l.msLoansRecordEmis,
                sub: _accountName().isEmpty
                    ? l.msLoansRecordAutoHelpNoAccount
                    : l.msLoansRecordAutoHelp(_accountName()),
                value: _autoRecord,
                onChanged: (v) => setState(() => _autoRecord = v),
              ),
              const SizedBox(height: 24),
              _AdvancedRow(
                open: _advanced,
                onTap: () => setState(() => _advanced = !_advanced),
              ),
              if (_advanced) ..._advancedSection(context),
            ],
          ),
        ),
      ),
      bottomNavigationBar: KuberSaveButton(
        label: _existing == null ? l.msLoansSave : l.msLoansSaveChanges,
        loading: _saving,
        onPressed: _canSave ? _save : null,
      ),
    );
  }

  String _accountName() {
    return ref.watch(accountMapProvider).valueOrNull?[_accountId]?.name ?? '';
  }

  List<Widget> _advancedSection(BuildContext context) {
    final l = context.l10n;
    final fmt = ref.watch(formatterProvider);
    final indian = fmt.system == NumberSystem.indian;
    final s = _solution;
    final calc = _calculated;
    String m(num v) => fmt.formatCurrency(v.round());
    final ioMonths = _io;
    final widgets = <Widget>[
      const SizedBox(height: 24),
      CapsLabel(l.msLoansInterestType),
      const SizedBox(height: 8),
      // Interest-only first lives in "Interest before EMIs start" now; a loan
      // already saved with it keeps its card and its exact numbers.
      for (final t in LoanInterestType.values)
        if (t != LoanInterestType.interestOnlyFirst ||
            _existing?.interestType == LoanInterestType.interestOnlyFirst) ...[
        KuberSelectCard(
          title: switch (t) {
            LoanInterestType.reducingBalance => l.msLoansReducing,
            LoanInterestType.flatRate => l.msLoansFlat,
            LoanInterestType.interestOnlyFirst => l.msLoansIo,
          },
          subtitle: switch (t) {
            LoanInterestType.reducingBalance => l.msLoansReducingSub,
            LoanInterestType.flatRate => l.msLoansFlatSub,
            LoanInterestType.interestOnlyFirst => l.msLoansIoSub,
          },
          selected: _interest == t,
          onTap: () {
            _interest = t;
            _recompute();
          },
          onInfo: () => showMoneyInfo(context, ref, switch (t) {
            LoanInterestType.reducingBalance => MoneyInfo.reducing,
            LoanInterestType.flatRate => MoneyInfo.flat,
            LoanInterestType.interestOnlyFirst => MoneyInfo.io,
          }),
        ),
        const SizedBox(height: 8),
      ],
      if (_interest == LoanInterestType.interestOnlyFirst) ...[
        KuberTextField.number(
          label: l.msLoansIoMonths,
          controller: _ioMonths,
          decimal: false,
          onChanged: (_) => _recompute(),
        ),
        if (s != null && s.ok && ioMonths > 0) ...[
          const SizedBox(height: 8),
          KuberCallout.text(
            l.msLoansIoNotice(
                m(s.ioEmi),
                fmtMonthYear(DateTime(_when.firstOccurrence.year, _when.firstOccurrence.month + ioMonths - 1)),
                m(s.emi),
                '${s.months - ioMonths}'),
            tone: KuberCalloutTone.info,
          ),
        ],
      ],
      const SizedBox(height: 24),
      CapsLabel(l.msLoansNumbers,
          trailing: KuberInfoGlyph(onTap: () => showMoneyInfo(context, ref, MoneyInfo.calculated))),
      if (_swapHelp != null || _order.isNotEmpty) ...[
        const SizedBox(height: 4),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.touch_app_outlined, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              _swapHelp ??
                  (_order.length >= 3
                      ? l.msLoansOrderHelp(_fieldName(_order[0]), _fieldName(_order[1]), _fieldName(_order[2]))
                      : ''),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ]),
      ],
      const SizedBox(height: 8),
      KuberAmountField(
        label: _inParts ? l.msLoansSanctioned : l.msLoansPrincipal,
        controller: _principal,
        symbol: fmt.symbol,
        indianGrouping: indian,
        calculatedLabel: calc == LoanField.principal ? l.msCalculated : null,
        onChanged: (_) => _typed(LoanField.principal),
      ),
      const SizedBox(height: 12),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: KuberTextField.number(
            label: l.msLoansRate,
            controller: _rate,
            suffixText: '%',
            calculatedLabel: calc == LoanField.rate ? l.msCalculated : null,
            onChanged: (_) => _typed(LoanField.rate),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: KuberAmountField(
            label: l.msLoansEmi,
            controller: _emi,
            symbol: fmt.symbol,
            indianGrouping: indian,
            calculatedLabel: calc == LoanField.emi ? l.msCalculated : null,
            errorText: s?.error == LoanError.emiTooLow ? l.msLoansErrNeverEnds : null,
            onChanged: (_) => _typed(LoanField.emi),
          ),
        ),
      ]),
      const SizedBox(height: 12),
      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Expanded(
          child: KuberTextField.number(
            label: l.msLoansTenure,
            controller: _tenure,
            decimal: false,
            calculatedLabel: calc == LoanField.tenure ? l.msCalculated : null,
            onChanged: (_) => _typed(LoanField.tenure),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 180,
          child: KuberSegmented<bool>(
            groupValue: _tenureYears,
            onChanged: (v) {
              final months = _months;
              _tenureYears = v;
              if (months != null) {
                _programmatic = true;
                _tenure.text = v ? _num(months / 12) : '$months';
                _programmatic = false;
              }
              _recompute();
            },
            segments: [
              KuberSegment(value: true, label: l.msLoansYears),
              KuberSegment(value: false, label: l.msLoansMonths),
            ],
          ),
        ),
      ]),
      const SizedBox(height: 12),
      KuberAmountField(
        label: l.msLoansTotalPayable,
        controller: _total,
        symbol: fmt.symbol,
        indianGrouping: indian,
        helperText: l.msLoansTotalPayableHint,
        onChanged: (_) => _recompute(),
      ),
      const SizedBox(height: 12),
      ..._previewOrNotice(context, s),
      if (_releasesApply) ..._releaseSection(context),
      const SizedBox(height: 24),
      KuberSwitchRow(
        icon: Icons.history_rounded,
        name: l.msAlreadyRunning,
        sub: l.msAlreadyRunningSubLoan,
        value: _running,
        onChanged: (v) {
          _running = v;
          _recompute();
        },
      ),
      if (_running) ..._runningSection(context),
      const SizedBox(height: 24),
      CapsLabel(l.msLoansSpending),
      const SizedBox(height: 8),
      KuberSwitchRow(
        icon: Icons.pie_chart_outline_rounded,
        name: l.msLoansOnlyInterest,
        sub: l.msLoansOnlyInterestHelp,
        value: _onlyInterest,
        enabled: s != null && s.ok && _start != LoanStartingPoint.trackEmiOnly,
        onChanged: (v) => setState(() => _onlyInterest = v),
        onInfo: () => showMoneyInfo(context, ref, MoneyInfo.interestOnly),
      ),
      if (_existing != null && _onlyInterest != (_existing!.countOnlyInterest))
        KuberCallout.text(l.msLoansFutureOnly, tone: KuberCalloutTone.warning),
    ];
    return widgets;
  }

  List<Widget> _previewOrNotice(BuildContext context, LoanSolution? s) {
    final l = context.l10n;
    final fmt = ref.watch(formatterProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    String m(num v) => fmt.formatCurrency(v.round());
    if (s == null) return const [];
    if (s.error == LoanError.emiTooLow) {
      return [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: cs.surfaceContainerHigh, borderRadius: KuberShape.largeR),
          child: Text(l.msLoansErrNeverEndsPreview(m(s.firstMonthInterest)), style: tt.titleSmall),
        ),
      ];
    }
    if (s.error == LoanError.totalTooLow) {
      return [KuberCallout.text(l.msLoansErrTotalLow, tone: KuberCalloutTone.error)];
    }
    if (!s.ok) return const [];
    final end = DateTime(_when.firstOccurrence.year, _when.firstOccurrence.month + s.months - 1);
    final totalInterest = s.emi * (s.months - _io) + s.ioEmi * _io - s.principal;
    final pre = _ledgerNow;
    if (pre != null) {
      final a = loanAmortization(_draft());
      return [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: cs.secondaryContainer, borderRadius: KuberShape.largeR),
          child: Text(
            l.msLoansPreEmiPreview(
                m(pre.balance),
                fmtMonthYear(a == null || a.rows.isEmpty ? end : dayOf(a.rows.last.day)),
                m(a?.allInterest ?? totalInterest)),
            style: tt.titleSmall!.copyWith(color: cs.onSecondaryContainer),
          ),
        ),
      ];
    }
    final widgets = <Widget>[];
    if (s.mismatch.abs() >= 1) {
      final diff = m(s.mismatch.abs());
      widgets
        ..add(KuberCallout.text(
          s.mismatch > 0 ? l.msLoansMismatchMore(diff) : l.msLoansMismatchLess(diff),
          tone: KuberCalloutTone.warning,
          onInfo: () => showMoneyInfo(context, ref, MoneyInfo.mismatch),
        ))
        ..add(const SizedBox(height: 8));
    }
    widgets.add(Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: cs.secondaryContainer, borderRadius: KuberShape.largeR),
      child: Text(
        s.rate == 0
            ? l.msLoansPreviewZero(m(s.emi), fmtMonthYear(end))
            : l.msLoansPreview(m(s.emi), fmtMonthYear(end), m(totalInterest)),
        style: tt.titleSmall!.copyWith(color: cs.onSecondaryContainer),
      ),
    ));
    return widgets;
  }

  void _setParts(bool on) async {
    final l = context.l10n;
    if (on) {
      setState(() {
        _inParts = true;
        if (_parts.isEmpty) {
          _parts.add(_Part(_startDay, _principal.text, accountId: _receivedId));
        }
      });
      _recompute();
      return;
    }
    if (_parts.length > 1) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l.msLoansPartsOffTitle, style: localeFont(fontWeight: FontWeight.w600)),
          content: Text(l.msLoansPartsOffBody, style: localeFont()),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancelLabel)),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.msLoansKeepFirst)),
          ],
        ),
      );
      if (ok != true) return;
    }
    if (!mounted) return;
    setState(() {
      _inParts = false;
      if (_parts.isNotEmpty) {
        _parts.sort((a, b) => a.date.compareTo(b.date));
        _receivedId = _parts.first.accountId;
        _parts.removeRange(1, _parts.length);
      }
    });
    _recompute();
  }

  void _addPart() {
    final today = DateUtils.dateOnly(DateTime.now());
    setState(() => _parts.add(_Part(today, '')));
    _recompute();
  }

  Future<void> _removePart(_Part p) async {
    final id = p.origin?.transactionId;
    final choice = await confirmDeletePart(context, hasTransaction: id != null);
    if (choice == null || !mounted) return;
    if (choice == false && id != null) _keepTxnIds.add(id);
    setState(() => _parts.remove(p));
    _recompute();
  }

  Widget _partCard(BuildContext context, int i, _Part p, bool afterFirstEmi) {
    final l = context.l10n;
    final fmt = ref.watch(formatterProvider);
    final cs = Theme.of(context).colorScheme;
    final today = DateUtils.dateOnly(DateTime.now());
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: KuberShape.largeR,
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Expanded(child: Text(l.msLoansPartTitle('${i + 1}'), style: Theme.of(context).textTheme.titleSmall)),
            if (i > 0)
              IconButton(
                icon: Icon(Icons.delete_outline_rounded, color: cs.error),
                tooltip: l.deleteLabel,
                onPressed: () => _removePart(p),
              )
            else
              const SizedBox(height: 48),
          ]),
          KuberAmountField(
            label: l.msRecAmount,
            controller: p.amount,
            symbol: fmt.symbol,
            indianGrouping: fmt.system == NumberSystem.indian,
            onChanged: (_) => _recompute(),
          ),
          const SizedBox(height: 8),
          DatePickerRow(
            label: i == 0 ? l.msLoansStartDate : l.msInvDate,
            value: fmtDayLong(p.date),
            initial: p.date.isAfter(today) ? today : p.date,
            last: today,
            onChanged: (d) {
              p.date = d;
              if (i == 0) _loanStart = d;
              setState(() => _parts.sort((a, b) => a.date.compareTo(b.date)));
              _recompute();
            },
          ),
          const SizedBox(height: 8),
          AccountPickerRow(
            label: l.msLoansReceivedInShort,
            selectedId: p.accountId,
            noneLabel: l.msLoansNotRecorded,
            onNone: () => setState(() {
              p.accountId = null;
              _numbersTouched = true;
            }),
            onChanged: (id) => setState(() {
              p.accountId = id;
              _numbersTouched = true;
            }),
          ),
          if (afterFirstEmi) ...[
            const SizedBox(height: 12),
            LoanKeepChoice(
              value: p.adjust,
              onChanged: (v) => setState(() {
                p.adjust = v;
                _recompute();
              }),
            ),
          ],
        ]),
      ),
    );
  }

  List<Widget> _releaseSection(BuildContext context) {
    final l = context.l10n;
    final fmt = ref.watch(formatterProvider);
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final indian = fmt.system == NumberSystem.indian;
    String m(num v) => fmt.formatCurrency(v.round());
    final today = DateUtils.dateOnly(DateTime.now());
    final firstEmi = dayKey(_when.firstOccurrence);
    final out = <Widget>[
      const SizedBox(height: 24),
      if (!_inParts) ...[
        DatePickerRow(
          label: l.msLoansStartDate,
          value: fmtDayLong(_startDay),
          initial: _startDay.isAfter(today) ? today : _startDay,
          last: today,
          onChanged: (d) {
            _loanStart = d;
            _recompute();
          },
        ),
        const SizedBox(height: 12),
      ],
      KuberSwitchRow(
        icon: Icons.account_tree_outlined,
        name: l.msLoansInParts,
        sub: l.msLoansInPartsSub,
        value: _inParts,
        onChanged: _setParts,
        onInfo: () => showMoneyInfo(context, ref, MoneyInfo.releasedParts),
      ),
    ];
    if (!_inParts) {
      out.addAll([
        const SizedBox(height: 12),
        AccountPickerRow(
          label: l.msLoansReceivedIn,
          selectedId: _receivedId,
          noneLabel: l.msLoansNotRecorded,
          onNone: () => setState(() {
            _receivedId = null;
            _numbersTouched = true;
          }),
          onChanged: (id) => setState(() {
            _receivedId = id;
            _numbersTouched = true;
          }),
        ),
        const SizedBox(height: 4),
        Text(l.msLoansReceivedInHelp, style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
      ]);
    } else {
      final released = _parts.fold(0.0, (s, p) => s + p.value);
      final sanctioned = _val(_principal) ?? 0;
      final error = _partsError;
      out.addAll([
        const SizedBox(height: 16),
        CapsLabel(l.msLoansReleasedSoFar,
            trailing: KuberInfoGlyph(onTap: () => showMoneyInfo(context, ref, MoneyInfo.receivedIn))),
        const SizedBox(height: 8),
        for (final (i, p) in _parts.indexed) _partCard(context, i, p, dayKey(p.date) > firstEmi),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _addPart,
            icon: const Icon(Icons.add_rounded),
            label: Text(l.msLoansAddPart),
          ),
        ),
        if (sanctioned > 0)
          Text(
            (released - sanctioned).abs() < 0.005
                ? l.msLoansFullyReleased
                : l.msLoansPartsSummary(m(released), m(sanctioned)),
            style: tt.titleSmall,
          ),
        const SizedBox(height: 4),
        Text(l.msLoansPartsHelp, style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
        if (error != null) ...[
          const SizedBox(height: 8),
          KuberCallout.text(error, tone: KuberCalloutTone.error),
        ],
      ]);
    }
    if (_preEmiShown) {
      out.addAll([
        const SizedBox(height: 24),
        CapsLabel(l.msLoansPreEmiTitle),
        const SizedBox(height: 8),
        KuberSelectCard(
          title: l.msLoansPreEmiPay,
          subtitle: l.msLoansPreEmiPaySub,
          selected: _preEmi == LoanPreEmi.payMonthly,
          onTap: () {
            _preEmi = LoanPreEmi.payMonthly;
            _recompute();
          },
          onInfo: () => showMoneyInfo(context, ref, MoneyInfo.preEmiPay),
        ),
        const SizedBox(height: 8),
        KuberSelectCard(
          title: l.msLoansPreEmiAdd,
          subtitle: l.msLoansPreEmiAddSub,
          selected: _preEmi == LoanPreEmi.addToLoan,
          onTap: () {
            _preEmi = LoanPreEmi.addToLoan;
            _recompute();
          },
          onInfo: () => showMoneyInfo(context, ref, MoneyInfo.preEmiAdd),
        ),
        const SizedBox(height: 12),
        KuberTextField.number(
          label: l.msLoansPreEmiDay,
          controller: _preEmiDay,
          decimal: false,
          hint: '${_when.effectiveAnchor}',
          helperText: l.msLoansPreEmiDayHelp,
          onChanged: (_) => _recompute(),
        ),
      ]);
      final pre = _ledgerNow;
      if (_preEmi == LoanPreEmi.addToLoan && pre != null) {
        final calc = pre.calculatedAdded;
        final moved = _preEmiEdited && _preEmiSeen != null && (calc - _preEmiSeen!).abs() >= 1;
        out.addAll([
          const SizedBox(height: 12),
          KuberAmountField(
            label: l.msLoansPreEmiAdded,
            controller: _preEmiAdded,
            symbol: fmt.symbol,
            indianGrouping: indian,
            calculatedLabel: _preEmiEdited ? l.msTxnEdited : l.msCalculated,
            onInfo: () => showMoneyInfo(context, ref, MoneyInfo.preEmiCalculated),
            onChanged: (v) {
              _preEmiEdited = v.trim().isNotEmpty;
              _preEmiSeen = _preEmiEdited ? (_preEmiSeen ?? calc) : null;
              _recompute();
            },
          ),
          if (moved) ...[
            const SizedBox(height: 8),
            KuberCallout(
              tone: KuberCalloutTone.info,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l.msLoansPreEmiNotice(m(calc))),
                Wrap(spacing: 8, children: [
                  TextButton(
                    onPressed: () {
                      _preEmiEdited = false;
                      _preEmiSeen = null;
                      _recompute();
                    },
                    child: Text(l.msLoansUse),
                  ),
                  TextButton(
                    onPressed: () {
                      _preEmiSeen = calc;
                      _recompute();
                    },
                    child: Text(l.msLoansKeepMine),
                  ),
                ]),
              ]),
            ),
          ],
        ]);
      }
    }
    return out;
  }

  List<Widget> _runningSection(BuildContext context) {
    final l = context.l10n;
    final fmt = ref.watch(formatterProvider);
    final indian = fmt.system == NumberSystem.indian;
    String m(num v) => fmt.formatCurrency(v.round());
    final cards = <(LoanStartingPoint, String, String, MoneyInfo)>[
      (LoanStartingPoint.originalDetails, l.msLoansRun1, l.msLoansRun1Sub, MoneyInfo.run1),
      (LoanStartingPoint.outstandingToday, l.msLoansRun2, l.msLoansRun2Sub, MoneyInfo.run2),
      (LoanStartingPoint.trackEmiOnly, l.msLoansRun3, l.msLoansRun3Sub, MoneyInfo.run3),
    ];
    final out = <Widget>[const SizedBox(height: 12)];
    for (final c in cards) {
      out
        ..add(KuberSelectCard(
          title: c.$2,
          subtitle: c.$3,
          selected: _start == c.$1,
          onTap: () {
            _start = c.$1;
            _recompute();
          },
          onInfo: () => showMoneyInfo(context, ref, c.$4),
        ))
        ..add(const SizedBox(height: 8));
    }
    // The start date lives in the EMI schedule above; with a running loan it
    // is asked here too (first EMI in the past, or the next EMI when only
    // today's outstanding is known, where the schedule block is hidden).
    final today = DateUtils.dateOnly(DateTime.now());
    void setStart(DateTime d) {
      _when = _when.copyWith(start: d, anchorDay: d.day);
      _whenTouched = true;
      _recompute();
    }

    out
      ..add(_start == LoanStartingPoint.outstandingToday
          ? DatePickerRow(
              label: l.msLoansNextEmiDate,
              value: fmtDayLong(_nextEmiFromToday()),
              initial: _nextEmiFromToday(),
              first: today,
              onChanged: setStart,
            )
          : DatePickerRow(
              label: l.msLoansFirstEmiDate,
              value: fmtDayLong(_when.start),
              initial: _when.start.isAfter(today) ? today : _when.start,
              last: today,
              onChanged: setStart,
            ))
      ..add(const SizedBox(height: 12));
    final s = _solution;
    switch (_start) {
      case LoanStartingPoint.originalDetails:
        final draft = s != null && s.ok ? _draft() : null;
        final o = draft == null ? null : LoanService.openingValues(draft);
        if (o != null) {
          if (!_outstandingEdited) {
            final calc = _amt(o.outstanding.round());
            if (_outstanding.text != calc) _outstanding.text = calc;
          }
          out.addAll([
            Text(l.msLoansRun1Help(fmtDayLong(_when.firstOccurrence)),
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            KvGrid(columns: 3, items: [
              KvItem(l.msLoansEmisPaid, '${o.emisPaid}'),
              KvItem(l.msLoansPrincipalPaid, m(o.principalPaid)),
              KvItem(l.msLoansInterestPaid, m(o.interestPaid)),
            ]),
            const SizedBox(height: 12),
            KuberAmountField(
              label: l.msLoansOutstandingToday,
              controller: _outstanding,
              symbol: fmt.symbol,
              indianGrouping: indian,
              onChanged: (_) => setState(() {
                _outstandingEdited = true;
                _numbersTouched = true;
              }),
            ),
          ]);
          final entered = _val(_outstanding);
          if (entered != null && (entered - o.outstanding).abs() >= 1) {
            out
              ..add(const SizedBox(height: 8))
              ..add(KuberCallout.text(
                l.msLoansAdjustment(m(entered - o.outstanding)),
                tone: KuberCalloutTone.info,
                onInfo: () => showMoneyInfo(context, ref, MoneyInfo.adjustment),
              ));
          }
          out
            ..add(const SizedBox(height: 12))
            ..add(KuberSwitchRow(
              icon: Icons.playlist_add_rounded,
              name: l.msLoansPastEmis,
              sub: l.msLoansPastEmisHelp,
              value: _pastEmis,
              onChanged: (v) => setState(() => _pastEmis = v),
              onInfo: () => showMoneyInfo(context, ref, MoneyInfo.pastEmis),
            ));
          if (_pastEmis) {
            final p = LoanService.pastEmisPreview(draft!, _handled,
                decimals: fmt.currency.decimals);
            final account = ref
                    .watch(accountListProvider)
                    .valueOrNull
                    ?.where((a) => a.id == _accountId)
                    .firstOrNull
                    ?.name ??
                '';
            if (p.count > 0) {
              out
                ..add(const SizedBox(height: 8))
                ..add(KuberCallout.text(
                  account.isEmpty
                      ? l.msLoansPastEmisPreviewNoAccount(p.count, fmtMonthYear(dayOf(p.from!)),
                          fmtMonthYear(dayOf(p.to!)), m(p.total))
                      : l.msLoansPastEmisPreview(p.count, fmtMonthYear(dayOf(p.from!)),
                          fmtMonthYear(dayOf(p.to!)), account, m(p.total)),
                  tone: KuberCalloutTone.info,
                ));
            }
          }
        }
      case LoanStartingPoint.outstandingToday:
        out.add(KuberAmountField(
          label: l.msLoansOutstanding,
          controller: _outstanding,
          symbol: fmt.symbol,
          indianGrouping: indian,
          onChanged: (_) => setState(() {
            _outstandingEdited = true;
            _numbersTouched = true;
          }),
        ));
        final o = _val(_outstanding);
        final rate = _val(_rate);
        final emi = _val(_emi);
        if (o != null && rate != null && emi != null) {
          final left = emisLeftFor(o, rate, emi);
          if (left != null) {
            final first = _nextEmiFromToday();
            out
              ..add(const SizedBox(height: 12))
              ..add(KvGrid(columns: 1, items: [
                KvItem(l.msLoansEmisLeft,
                    l.msLoansEmisLeftValue('$left', fmtMonthYear(DateTime(first.year, first.month + left - 1)))),
              ]));
          }
        }
        out.addAll([
          const SizedBox(height: 12),
          CapsLabel(l.msLoansPastTotals),
          Text(l.msLoansPastTotalsSub, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: KuberAmountField(
                  label: l.msLoansPrincipalPaid,
                  controller: _pastPrincipal,
                  symbol: fmt.symbol,
                  indianGrouping: indian,
                  optional: true),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: KuberAmountField(
                  label: l.msLoansInterestPaid,
                  controller: _pastInterest,
                  symbol: fmt.symbol,
                  indianGrouping: indian,
                  optional: true),
            ),
          ]),
        ]);
      case LoanStartingPoint.trackEmiOnly:
        out.add(KuberCallout.text(
          l.msLoansRun3Notice(m(_val(_emi) ?? 0), ordinalFor(_when.effectiveAnchor)),
          tone: KuberCalloutTone.info,
        ));
    }
    // With "Add past EMIs" on, the past EMIs do change the balance.
    if (!(_pastEmis && _start == LoanStartingPoint.originalDetails)) {
      out
        ..add(const SizedBox(height: 12))
        ..add(Text(l.msOpeningNote,
            style: localeFont(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)));
    }
    return out;
  }
}

class _AdvancedRow extends StatelessWidget {
  final bool open;
  final VoidCallback onTap;
  const _AdvancedRow({required this.open, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    return KuberPickerRow(
      leading: DecoratedBox(
        decoration: BoxDecoration(color: cs.secondaryContainer, borderRadius: KuberShape.mediumR),
        child: Icon(Icons.tune_rounded, size: 20, color: cs.onSecondaryContainer),
      ),
      label: l.msAdvancedSubLoan,
      value: l.msAdvanced,
      onTap: onTap,
    );
  }
}
