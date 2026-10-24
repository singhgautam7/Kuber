// Add / edit investment (design I.2). Pick a type first; it decides the form:
// market-valued (one time or SIP with yearly step-up), fixed return (FD, RD,
// PPF, bonds: terms with a live maturity preview), or other. "Already
// running?" records opening values that never change a balance.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/isar_service.dart';
import '../../../core/money_math/investment_math.dart';
import '../../../core/schedule/schedule.dart';
import '../../../core/schedule/schedule_text.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_chips.dart';
import '../../../shared/widgets/kuber_form_widgets.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/money_info_sheets.dart';
import '../../../shared/widgets/money_widgets.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../../shared/widgets/when_picker.dart';
import '../../settings/providers/settings_provider.dart';
import '../../tools/engine/fd_rd_engine.dart' show CompoundingFrequency;
import '../../transactions/widgets/entity_picker_rows.dart';
import '../data/investment.dart';
import '../domain/investment_engine.dart';
import '../domain/investment_service.dart';
import '../providers/investment_provider.dart';
import '../widgets/holding_sheet.dart';

class AddInvestmentScreen extends ConsumerStatefulWidget {
  final Investment? existing;

  /// Notes amount, Home v2 name / SIP prefills, and calculator query values
  /// (type, sip, principal, installment, rate, months, freq, from).
  final double? amountPrefill;
  final String? namePrefill;
  final double? sipPrefill;
  final Map<String, String> query;

  const AddInvestmentScreen({
    super.key,
    this.existing,
    this.amountPrefill,
    this.namePrefill,
    this.sipPrefill,
    this.query = const {},
  });

  @override
  ConsumerState<AddInvestmentScreen> createState() => _AddInvestmentScreenState();
}

const _marketTypes = ['mutual_fund', 'stocks', 'etf', 'gold', 'crypto'];
const _fixedTypes = ['fd', 'rd', 'ppf', 'bonds'];
const _otherTypes = ['real_estate', 'collectible', 'other'];

class _AddInvestmentScreenState extends ConsumerState<AddInvestmentScreen> {
  final _name = TextEditingController();
  final _invested = TextEditingController();
  final _value = TextEditingController();
  final _units = TextEditingController();
  final _sipAmount = TextEditingController();
  final _stepUp = TextEditingController();
  final _principal = TextEditingController();
  final _rate = TextEditingController();
  final _tenure = TextEditingController();

  String? _type;
  bool _sip = false;
  bool _stepUpOn = false;
  bool _stepUpPct = true;
  bool _running = false;
  int? _accountId;
  late WhenValue _when;
  DateTime _start = DateUtils.dateOnly(DateTime.now());
  bool _tenureYears = true;
  CompoundingFrequency _compounding = CompoundingFrequency.quarterly;
  PayoutType _payout = PayoutType.cumulative;
  bool _saving = false;
  String? _fromCalc;

  Investment? get _existing => widget.existing;
  InvestmentBehaviour get _behaviour => behaviourForType(_type ?? 'other');
  bool get _rd => _type == 'rd';
  bool get _ppf => _type == 'ppf';

  @override
  void initState() {
    super.initState();
    _when = WhenValue(start: DateUtils.dateOnly(DateTime.now()));
    final i = _existing;
    String num0(double v) => v % 1 == 0 ? v.toStringAsFixed(0) : '$v';
    if (i != null) {
      _type = i.investmentType == 'sip' ? 'mutual_fund' : i.investmentType;
      _name.text = i.name;
      if (i.investedAmount != null) _invested.text = num0(i.investedAmount!);
      if (i.currentValue != null) _value.text = num0(i.currentValue!);
      if (i.units != null) _units.text = '${i.units}';
      _accountId = int.tryParse(i.accountId ?? '');
      _running = i.alreadyRunning;
      if (i.sip != null) {
        _sip = true;
        _when = WhenValue.fromSchedule(i.sip!);
        _sipAmount.text = num0(i.sipAmount ?? i.installment ?? 0);
      }
      if (i.stepUpValue > 0) {
        _stepUpOn = true;
        _stepUp.text = num0(i.stepUpValue);
        _stepUpPct = i.stepUpKind == StepUpKind.percent;
      }
      if (i.fixedPrincipal != null) _principal.text = num0(i.fixedPrincipal!);
      if (i.installment != null) _principal.text = num0(i.installment!);
      if (i.fixedRate != null) _rate.text = '${i.fixedRate}';
      if (i.fixedStart != null) _start = i.fixedStart!;
      final months = i.fixedTenureMonths;
      if (months != null) {
        _tenureYears = months % 12 == 0;
        _tenure.text = _tenureYears ? '${months ~/ 12}' : '$months';
      }
      _compounding = i.compounding;
      _payout = i.payout;
    } else {
      final q = widget.query;
      if (widget.namePrefill != null) _name.text = widget.namePrefill!;
      if ((widget.amountPrefill ?? 0) > 0) _invested.text = num0(widget.amountPrefill!);
      final sip = double.tryParse(q['sip'] ?? '') ?? widget.sipPrefill;
      if (sip != null && sip > 0) {
        _type = 'mutual_fund';
        _sip = true;
        _sipAmount.text = num0(sip);
      }
      switch (q['type']) {
        case 'fd' || 'rd' || 'ppf':
          _type = q['type'];
          _principal.text = q['principal'] ?? q['installment'] ?? '';
          _rate.text = q['rate'] ?? '';
          final months = int.tryParse(q['months'] ?? '');
          if (months != null) {
            _tenureYears = months % 12 == 0;
            _tenure.text = _tenureYears ? '${months ~/ 12}' : '$months';
          }
          _compounding = CompoundingFrequency.values
                  .where((f) => f.name == q['freq'])
                  .firstOrNull ??
              _compounding;
          if (_type == 'rd') _sip = true;
          if (_type == 'ppf') {
            _sip = true;
            _when = WhenValue(start: _when.start, unit: ScheduleUnit.year);
          }
      }
      _fromCalc = q['from'];
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _invested, _value, _units, _sipAmount, _stepUp, _principal, _rate, _tenure]) {
      c.dispose();
    }
    super.dispose();
  }

  double _v(TextEditingController c) => KuberAmountField.valueOf(c);
  int? get _months {
    final t = double.tryParse(_tenure.text.trim());
    if (t == null || t <= 0) return null;
    return _tenureYears ? (t * 12).round() : t.round();
  }

  Investment _draft() {
    final base = _existing;
    final i = base ?? Investment();
    i
      ..name = _name.text.trim()
      ..investmentType = _type!
      ..behaviour = _behaviour
      ..accountId = _accountId == null ? null : '$_accountId'
      ..alreadyRunning = _running
      ..deductedFromAccount = !_running
      ..units = double.tryParse(_units.text.trim());
    switch (_behaviour) {
      case InvestmentBehaviour.fixedReturn:
        final amount = _v(_principal);
        i
          ..fixedRate = double.tryParse(_rate.text.trim())
          ..fixedStart = _start
          ..fixedTenureMonths = _months
          ..compounding = _compounding
          ..payout = _rd || _ppf ? PayoutType.cumulative : _payout;
        if (_rd || _ppf) {
          i
            ..installment = amount
            ..fixedPrincipal = null
            ..sipAmount = amount;
        } else {
          i
            ..fixedPrincipal = amount
            ..installment = null
            ..investedAmount = base?.investedAmount ?? amount
            ..currentValue = null;
        }
      case InvestmentBehaviour.market:
      case InvestmentBehaviour.other:
        if (_sip) {
          i
            ..sipAmount = _v(_sipAmount)
            ..stepUpValue = _stepUpOn ? (double.tryParse(_stepUp.text) ?? 0) : 0
            ..stepUpKind = _stepUpPct ? StepUpKind.percent : StepUpKind.amount;
          if (base == null) {
            i
              ..investedAmount = _running ? _v(_invested) : 0
              ..currentValue = _running ? _v(_value) : null;
          }
        } else if (base == null) {
          i
            ..investedAmount = _v(_invested)
            ..currentValue = _v(_value) > 0 ? _v(_value) : _v(_invested);
        }
    }
    return i;
  }

  Schedule? _schedule() {
    if (_behaviour == InvestmentBehaviour.fixedReturn) {
      if (!_rd && !_ppf) return null;
      final months = _months ?? 12;
      return _when
          .copyWith(
              start: _start,
              endType: ScheduleEnd.afterCount,
              endCount: _ppf ? (months / 12).round() : months)
          .toSchedule();
    }
    return _sip ? _when.toSchedule() : null;
  }

  bool get _canSave {
    if (_saving || _type == null || _name.text.trim().isEmpty) return false;
    switch (_behaviour) {
      case InvestmentBehaviour.fixedReturn:
        return _v(_principal) > 0 &&
            (double.tryParse(_rate.text) ?? -1) >= 0 &&
            _months != null &&
            (_running || _accountId != null);
      case InvestmentBehaviour.market:
      case InvestmentBehaviour.other:
        if (_sip) {
          return _v(_sipAmount) > 0 && _accountId != null && _when.error(context.l10n) == null;
        }
        return _v(_invested) > 0 || _v(_value) > 0;
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final i = _draft();
      final service = InvestmentService(ref.read(isarProvider));
      final schedule = _schedule();
      if (_existing == null) {
        final first = _behaviour == InvestmentBehaviour.fixedReturn && !_rd && !_ppf
            ? _v(_principal)
            : (_sip ? 0.0 : _v(_invested));
        await service.create(i, firstAmount: first, sip: schedule, firstDate: _start);
      } else {
        if (schedule != null) {
          final old = i.sip;
          i.sip = old == null
              ? schedule
              : (schedule
                ..processedThrough = old.processedThrough
                ..postedCount = old.postedCount
                ..paused = old.paused);
        } else {
          i.sip = null;
        }
        await service.save(i);
      }
      ref.invalidate(investmentListProvider);
      if (mounted) {
        showKuberSnackBar(context, context.l10n.msInvSave);
        context.pop();
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: KuberAppBar(
        showBack: true,
        closeIcon: true,
        onBack: () {
          if (_type != null && _existing == null && widget.query['type'] == null) {
            setState(() => _type = null);
          } else {
            context.pop();
          }
        },
        title: _existing == null ? l.msInvAdd : l.msInvEdit,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 140),
          child: _type == null ? _picker(context) : _form(context),
        ),
      ),
      bottomNavigationBar: _type == null
          ? null
          : KuberSaveButton(
              label: _existing == null ? l.msInvSave : l.msLoansSaveChanges,
              loading: _saving,
              onPressed: _canSave ? _save : null,
            ),
    );
  }

  Widget _picker(BuildContext context) {
    final l = context.l10n;
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    Widget group(String title, String sub, List<String> types) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(title, style: tt.titleSmall),
            Text(sub, style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 8),
            KuberGroup(children: [
              for (final t in types)
                KuberListRow(
                  minHeight: 56,
                  leading: KuberIconTile(icon: investmentIcon(t)),
                  title: investmentTypeLabel(context, t),
                  trailing: const KuberChevron(),
                  onTap: () => setState(() {
                    _type = t;
                    if (t == 'rd') _sip = true;
                    if (t == 'ppf') {
                      _sip = true;
                      _when = WhenValue(start: _when.start, unit: ScheduleUnit.year);
                      _tenure.text = '15';
                      _rate.text = '7.1';
                    }
                  }),
                ),
            ]),
          ],
        );
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(l.msInvPickIntro, style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
      group(l.msInvPickMarket, l.msInvPickMarketSub, _marketTypes),
      group(l.msInvPickFixed, l.msInvPickFixedSub, _fixedTypes),
      group(l.msInvPickOther, l.msInvPickOtherSub, _otherTypes),
    ]);
  }

  Widget _form(BuildContext context) {
    final l = context.l10n;
    final fmt = ref.watch(formatterProvider);
    final indian = fmt.system == NumberSystem.indian;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    String m(num v) => fmt.formatCurrency(v.round());
    final children = <Widget>[
      if (_fromCalc != null)
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
      KuberListRow(
        leading: KuberIconTile(icon: investmentIcon(_type!)),
        title: investmentTypeLabel(context, _type!),
        subtitle: switch (_behaviour) {
          InvestmentBehaviour.market => l.msInvPickMarketSub,
          InvestmentBehaviour.fixedReturn => l.msInvPickFixedSub,
          InvestmentBehaviour.other => l.msInvPickOtherSub,
        },
      ),
      KuberTextField(
        label: l.msInvName,
        controller: _name,
        textCapitalization: TextCapitalization.words,
        onChanged: (_) => setState(() {}),
      ),
    ];

    if (_behaviour == InvestmentBehaviour.fixedReturn) {
      final months = _months;
      final rate = double.tryParse(_rate.text.trim());
      final amount = _v(_principal);
      double? maturity;
      if (months != null && rate != null && amount > 0) {
        maturity = _rd
            ? rdMaturity(amount, rate, months)
            : _ppf
                ? ppfMaturity(amount, rate, (months / 12).round().clamp(1, 50))
                : (_payout == PayoutType.cumulative ? fdMaturity(amount, rate, months, _compounding) : amount);
      }
      final matDate = months == null ? null : DateTime(_start.year, _start.month + months, _start.day);
      children.addAll([
        CapsLabel(l.msInvTerms),
        KuberAmountField(
          label: _rd || _ppf ? l.msInvInstallment : l.msInvPrincipal,
          controller: _principal,
          symbol: fmt.symbol,
          indianGrouping: indian,
          onChanged: (_) => setState(() {}),
        ),
        KuberTextField.number(
            label: l.msInvRate, controller: _rate, suffixText: '%', onChanged: (_) => setState(() {})),
        DatePickerRow(
            label: l.msInvStartDate,
            value: fmtDayLong(_start),
            initial: _start,
            onChanged: (d) => setState(() => _start = d)),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(
              child: KuberTextField.number(
                  label: l.msInvTenure, controller: _tenure, decimal: false, onChanged: (_) => setState(() {}))),
          const SizedBox(width: 12),
          SizedBox(
            width: 180,
            child: KuberSegmented<bool>(
              groupValue: _tenureYears,
              onChanged: (v) => setState(() => _tenureYears = v),
              segments: [
                KuberSegment(value: true, label: l.msLoansYears),
                KuberSegment(value: false, label: l.msLoansMonths),
              ],
            ),
          ),
        ]),
        if (!_ppf) ...[
          CapsLabel(l.msInvCompounding,
              trailing: KuberInfoGlyph(onTap: () => showMoneyInfo(context, ref, MoneyInfo.compounding))),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final f in compoundingChips)
              KuberChip(
                label: compoundingLabel(context, f),
                selected: _compounding == f,
                showCheck: true,
                onTap: () => setState(() => _compounding = f),
              ),
          ]),
        ],
        if (!_rd && !_ppf) ...[
          CapsLabel(l.msInvPayout,
              trailing: KuberInfoGlyph(onTap: () => showMoneyInfo(context, ref, MoneyInfo.payout))),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final p in PayoutType.values)
              KuberChip(
                label: switch (p) {
                  PayoutType.cumulative => l.msInvPayCumulative,
                  PayoutType.monthly => l.msInvPayMonthly,
                  PayoutType.quarterly => l.msInvPayQuarterly,
                  PayoutType.yearly => l.msInvPayYearly,
                },
                selected: _payout == p,
                showCheck: true,
                onTap: () => setState(() => _payout = p),
              ),
          ]),
        ],
        if (_rd)
          KuberWhenPicker(
            value: _when.copyWith(start: _start),
            onChanged: (v) => setState(() {
              _when = v;
              _start = v.start;
            }),
          ),
        if (maturity != null && matDate != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: cs.secondaryContainer, borderRadius: KuberShape.largeR),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.msInvAtMaturity, style: tt.bodyMedium!.copyWith(color: cs.onSecondaryContainer)),
              Text(m(maturity), style: tt.headlineSmall!.copyWith(color: cs.onSecondaryContainer)),
              Text(
                _rd || _ppf
                    ? l.msInvMaturityLineRd(fmtDayLong(matDate), m(amount * (_ppf ? (months! / 12).round() : months!)))
                    : l.msInvMaturityLine(fmtDayLong(matDate), m(maturity - amount)),
                style: tt.bodySmall!.copyWith(color: cs.onSecondaryContainer),
              ),
            ]),
          ),
        Text(l.msInvAutoValue, style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
        AccountPickerRow(
            label: l.msInvFromAccount, selectedId: _accountId, onChanged: (id) => setState(() => _accountId = id)),
      ]);
    } else {
      if (_behaviour == InvestmentBehaviour.market) {
        children.addAll([
          CapsLabel(l.msInvHow),
          KuberSegmented<bool>(
            groupValue: _sip,
            onChanged: (v) => setState(() => _sip = v),
            segments: [
              KuberSegment(value: false, label: l.msInvOneTime),
              KuberSegment(value: true, label: l.msInvSip),
            ],
          ),
        ]);
      }
      if (!_sip || _running) {
        children.add(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: KuberAmountField(
              label: _running ? l.msInvInvestedSoFar : l.msInvAmountInvested,
              controller: _invested,
              symbol: fmt.symbol,
              indianGrouping: indian,
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: KuberAmountField(
              label: l.msInvCurrentValue,
              controller: _value,
              symbol: fmt.symbol,
              indianGrouping: indian,
              onChanged: (_) => setState(() {}),
            ),
          ),
        ]));
      }
      if (_behaviour == InvestmentBehaviour.market) {
        children.add(KuberTextField.number(label: l.msInvUnits, controller: _units, hint: l.msInvUnitsHint));
      }
      if (_sip) {
        final preview = _stepUpOn
            ? stepUpSeries(_v(_sipAmount), _stepUpPct, double.tryParse(_stepUp.text) ?? 0, 3)
            : const <double>[];
        final s0 = _when.firstOccurrence;
        children.addAll([
          KuberAmountField(
            label: l.msInvSipAmount,
            controller: _sipAmount,
            symbol: fmt.symbol,
            indianGrouping: indian,
            onChanged: (_) => setState(() {}),
          ),
          AccountPickerRow(
              label: l.msInvFromAccount, selectedId: _accountId, onChanged: (id) => setState(() => _accountId = id)),
          KuberWhenPicker(value: _when, onChanged: (v) => setState(() => _when = v)),
          KuberSwitchRow(
            icon: Icons.trending_up_rounded,
            name: l.msInvStepUp,
            sub: l.msInvStepUpSwitch,
            value: _stepUpOn,
            onChanged: (v) => setState(() => _stepUpOn = v),
          ),
          if (_stepUpOn) ...[
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(
                child: KuberTextField.number(
                  label: l.msInvStepUpField,
                  controller: _stepUp,
                  onInfo: () => showMoneyInfo(context, ref, MoneyInfo.stepup),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 120,
                child: KuberSegmented<bool>(
                  groupValue: _stepUpPct,
                  onChanged: (v) => setState(() => _stepUpPct = v),
                  segments: [
                    const KuberSegment(value: true, label: '%'),
                    KuberSegment(value: false, label: fmt.currency.narrow),
                  ],
                ),
              ),
            ]),
            if (preview.length == 3 && _v(_sipAmount) > 0)
              KuberCallout.text(
                l.msInvStepUpNotice(
                    m(preview[0]),
                    m(preview[1]),
                    fmtMonthYear(DateTime(s0.year + 1, s0.month, s0.day)),
                    m(preview[2]),
                    fmtMonthYear(DateTime(s0.year + 2, s0.month, s0.day))),
                tone: KuberCalloutTone.info,
              ),
          ],
        ]);
      } else {
        children.add(AccountPickerRow(
            label: l.msInvFromAccount, selectedId: _accountId, onChanged: (id) => setState(() => _accountId = id)));
      }
    }

    if (_existing == null) {
      children.addAll([
        KuberSwitchRow(
          icon: Icons.history_rounded,
          name: l.msAlreadyRunning,
          sub: l.msAlreadyRunningSubInv,
          value: _running,
          onChanged: (v) => setState(() => _running = v),
        ),
        if (_running) Text(l.msOpeningNote, style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
      ]);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      for (var k = 0; k < children.length; k++) ...[
        if (k > 0) const SizedBox(height: 12),
        children[k],
      ],
    ]);
  }
}
