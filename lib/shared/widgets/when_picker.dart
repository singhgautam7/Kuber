// The When component (components/when.md): one schedule picker for recurring
// rules, SIPs / RD installments and loan EMIs (constrained variant). Presets,
// Custom "Every N units", start date, anchor, Ends, and the live sentence with
// the next 3 dates. Built from KuberChip, KuberGroup / KuberListRow,
// KuberTextField, KuberDropdownChip and KuberDayGrid.

import 'package:flutter/material.dart';

import '../../core/schedule/schedule.dart';
import '../../core/schedule/schedule_engine.dart';
import '../../core/schedule/schedule_text.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/l10n_ext.dart';
import 'kuber_bottom_sheet.dart';
import 'kuber_chips.dart';
import 'kuber_form_widgets.dart';
import 'kuber_list.dart';
import 'money_widgets.dart';

enum WhenVariant { full, emi }

enum WhenPreset { daily, weekly, monthly, quarterly, halfYearly, yearly, custom }

/// The picker's value. [start] is the date the user chose; the first
/// occurrence is the first anchor day on or after it.
@immutable
class WhenValue {
  final DateTime start;
  final int count;
  final ScheduleUnit unit;
  final bool custom;
  final int? anchorDay; // month / year: day; week: weekday
  final int? anchorMonth; // year
  final ScheduleEnd endType;
  final DateTime? endDate;
  final int? endCount;

  const WhenValue({
    required this.start,
    this.count = 1,
    this.unit = ScheduleUnit.month,
    this.custom = false,
    this.anchorDay,
    this.anchorMonth,
    this.endType = ScheduleEnd.never,
    this.endDate,
    this.endCount,
  });

  factory WhenValue.fromSchedule(Schedule s) => WhenValue(
        start: s.startDate ?? DateUtils.dateOnly(DateTime.now()),
        count: s.intervalCount,
        unit: s.intervalUnit,
        custom: _presetOf(s.intervalCount, s.intervalUnit) == WhenPreset.custom,
        anchorDay: s.anchorDay,
        anchorMonth: s.anchorMonth,
        endType: s.endType,
        endDate: s.endDate,
        endCount: s.endCount,
      );

  WhenValue copyWith({
    DateTime? start,
    int? count,
    ScheduleUnit? unit,
    bool? custom,
    int? anchorDay,
    int? anchorMonth,
    ScheduleEnd? endType,
    DateTime? endDate,
    int? endCount,
    bool clearAnchor = false,
  }) =>
      WhenValue(
        start: start ?? this.start,
        count: count ?? this.count,
        unit: unit ?? this.unit,
        custom: custom ?? this.custom,
        anchorDay: clearAnchor ? null : (anchorDay ?? this.anchorDay),
        anchorMonth: clearAnchor ? null : (anchorMonth ?? this.anchorMonth),
        endType: endType ?? this.endType,
        endDate: endDate ?? this.endDate,
        endCount: endCount ?? this.endCount,
      );

  WhenPreset get preset => custom ? WhenPreset.custom : _presetOf(count, unit);

  static WhenPreset _presetOf(int count, ScheduleUnit unit) => switch ((count, unit)) {
        (1, ScheduleUnit.day) => WhenPreset.daily,
        (1, ScheduleUnit.week) => WhenPreset.weekly,
        (1, ScheduleUnit.month) => WhenPreset.monthly,
        (3, ScheduleUnit.month) => WhenPreset.quarterly,
        (6, ScheduleUnit.month) => WhenPreset.halfYearly,
        (1, ScheduleUnit.year) => WhenPreset.yearly,
        _ => WhenPreset.custom,
      };

  /// The day of month / weekday / date the schedule lands on.
  int get effectiveAnchor => switch (unit) {
        ScheduleUnit.week => anchorDay ?? start.weekday,
        _ => anchorDay ?? start.day,
      };

  DateTime get firstOccurrence {
    final s = DateUtils.dateOnly(start);
    switch (unit) {
      case ScheduleUnit.day:
        return s;
      case ScheduleUnit.week:
        return firstWeekdayOnOrAfter(s, effectiveAnchor);
      case ScheduleUnit.month:
        return firstMonthlyOnOrAfter(s, effectiveAnchor);
      case ScheduleUnit.year:
        final month = anchorMonth ?? s.month;
        final day = effectiveAnchor.clamp(1, daysInMonthOf(s.year, month));
        final thisYear = DateTime(s.year, month, day);
        if (!thisYear.isBefore(s)) return thisYear;
        return DateTime(s.year + 1, month,
            effectiveAnchor.clamp(1, daysInMonthOf(s.year + 1, month)));
    }
  }

  Schedule toSchedule() {
    final first = firstOccurrence;
    final sch = scheduleFrom(
      start: first,
      count: count,
      unit: unit,
      anchorDay: unit == ScheduleUnit.month || unit == ScheduleUnit.year
          ? effectiveAnchor
          : null,
      endType: endType,
      endDate: endType == ScheduleEnd.onDate ? endDate : null,
      endCount: endType == ScheduleEnd.afterCount ? endCount : null,
    );
    if (unit == ScheduleUnit.year) sch.anchorMonth = anchorMonth ?? first.month;
    return sch;
  }

  /// Validation message, or null when the value can be saved.
  String? error(AppLocalizations l) {
    if (count < 1) return l.msWhenErrCount;
    if (endType == ScheduleEnd.onDate &&
        (endDate == null || !endDate!.isAfter(firstOccurrence))) {
      return l.msWhenErrEndBeforeStart;
    }
    if (endType == ScheduleEnd.afterCount && (endCount ?? 0) < 1) {
      return l.msWhenErrCountPreview;
    }
    return null;
  }
}

class KuberWhenPicker extends StatefulWidget {
  final WhenValue value;
  final ValueChanged<WhenValue> onChanged;
  final WhenVariant variant;

  const KuberWhenPicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.variant = WhenVariant.full,
  });

  @override
  State<KuberWhenPicker> createState() => _KuberWhenPickerState();
}

class _KuberWhenPickerState extends State<KuberWhenPicker> {
  late final _countCtrl = TextEditingController(text: '${widget.value.count}');
  late final _endCountCtrl =
      TextEditingController(text: widget.value.endCount?.toString() ?? '');

  WhenValue get v => widget.value;
  bool get emi => widget.variant == WhenVariant.emi;

  @override
  void dispose() {
    _countCtrl.dispose();
    _endCountCtrl.dispose();
    super.dispose();
  }

  void _set(WhenValue next) => widget.onChanged(next);

  void _preset(WhenPreset p) {
    final (count, unit) = switch (p) {
      WhenPreset.daily => (1, ScheduleUnit.day),
      WhenPreset.weekly => (1, ScheduleUnit.week),
      WhenPreset.monthly => (1, ScheduleUnit.month),
      WhenPreset.quarterly => (3, ScheduleUnit.month),
      WhenPreset.halfYearly => (6, ScheduleUnit.month),
      WhenPreset.yearly => (1, ScheduleUnit.year),
      WhenPreset.custom => (v.count, v.unit),
    };
    _countCtrl.text = '$count';
    _set(v.copyWith(
        count: count,
        unit: unit,
        custom: p == WhenPreset.custom,
        clearAnchor: unit != v.unit));
  }

  Future<DateTime?> _pickDate(DateTime initial, {DateTime? first}) => showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: first ?? DateTime(1900),
        lastDate: DateTime(2100),
      ).unfocusOnComplete(context);

  Future<void> _pickDay() async {
    final picked = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => KuberBottomSheet(
        title: emi ? ctx.l10n.msWhenEmiDay : ctx.l10n.msWhenOnDay,
        child: KuberDayGrid(
          selected: v.effectiveAnchor,
          onChanged: (d) => Navigator.of(ctx).pop(d),
        ),
      ),
    );
    if (picked != null) _set(v.copyWith(anchorDay: picked));
  }

  String _presetLabel(AppLocalizations l, WhenPreset p) => switch (p) {
        WhenPreset.daily => l.msWhenDaily,
        WhenPreset.weekly => l.msWhenWeekly,
        WhenPreset.monthly => l.msWhenMonthly,
        WhenPreset.quarterly => l.msWhenQuarterly,
        WhenPreset.halfYearly => l.msWhenHalfYearly,
        WhenPreset.yearly => l.msWhenYearly,
        WhenPreset.custom => l.msWhenCustom,
      };

  Widget _dateRow(IconData icon, String label, String value, VoidCallback onTap) =>
      KuberListRow(
        leading: KuberIconTile(icon: icon, tone: KuberTone.secondary),
        title: value,
        subtitle: label,
        trailing: const KuberChevron(),
        onTap: onTap,
      );

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final err = v.error(l);
    final monthly = v.unit == ScheduleUnit.month;
    final yearly = v.unit == ScheduleUnit.year;
    final weekly = v.unit == ScheduleUnit.week;

    final children = <Widget>[
      CapsLabel(emi ? l.msWhenTitleEmi : l.msWhenTitle),
      if (emi)
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
              color: cs.surfaceContainerHigh, borderRadius: KuberShape.mediumR),
          child: Row(children: [
            Icon(Icons.lock_outline_rounded, size: 16, color: cs.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(child: Text(l.msWhenLockedMonthly, style: tt.bodyMedium)),
            Text(l.msWhenLockedHint,
                style: tt.labelMedium!.copyWith(color: cs.onSurfaceVariant)),
          ]),
        )
      else ...[
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final p in WhenPreset.values)
            KuberChip(
              label: _presetLabel(l, p),
              selected: v.preset == p,
              showCheck: true,
              onTap: () => _preset(p),
            ),
        ]),
        if (v.preset == WhenPreset.custom)
          Row(children: [
            Text(l.msWhenEvery, style: tt.bodyLarge),
            const SizedBox(width: 12),
            SizedBox(
              width: 72,
              child: KuberTextField.number(
                showLabel: false,
                label: l.msWhenEvery,
                controller: _countCtrl,
                decimal: false,
                onChanged: (t) => _set(v.copyWith(count: int.tryParse(t) ?? 0)),
              ),
            ),
            const SizedBox(width: 12),
            KuberDropdownChip<ScheduleUnit>(
              value: v.unit,
              options: [
                KuberDropdownOption(ScheduleUnit.day, l.msWhenUnitDays),
                KuberDropdownOption(ScheduleUnit.week, l.msWhenUnitWeeks),
                KuberDropdownOption(ScheduleUnit.month, l.msWhenUnitMonths),
                KuberDropdownOption(ScheduleUnit.year, l.msWhenUnitYears),
              ],
              onChanged: (u) =>
                  _set(v.copyWith(unit: u, custom: true, clearAnchor: true)),
            ),
          ]),
      ],
      KuberGroup(children: [
        _dateRow(Icons.event_rounded, emi ? l.msWhenFirstEmi : l.msWhenStartsOn,
            fmtDayLong(emi ? v.firstOccurrence : v.start), () async {
          final d = await _pickDate(v.start);
          if (d != null) _set(v.copyWith(start: d));
        }),
        if (monthly || emi)
          _dateRow(
              Icons.calendar_view_month_rounded,
              emi ? l.msWhenEmiDay : l.msWhenOnDay,
              emi
                  ? l.msWhenEmiDayValue(ordinalFor(v.effectiveAnchor))
                  : l.msWhenOnDayValue(ordinalFor(v.effectiveAnchor)),
              _pickDay),
        if (yearly)
          _dateRow(Icons.today_rounded, l.msWhenOn,
              fmtDayShort(DateTime(2024, v.anchorMonth ?? v.start.month, v.effectiveAnchor)),
              () async {
            final d = await _pickDate(
                DateTime(v.start.year, v.anchorMonth ?? v.start.month,
                    v.effectiveAnchor.clamp(1, 28)));
            if (d != null) _set(v.copyWith(anchorDay: d.day, anchorMonth: d.month));
          }),
      ]),
      if (weekly) ...[
        CapsLabel(l.msWhenOn),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var wd = 1; wd <= 7; wd++)
              _WeekdayDot(
                label: fmtWeekdayNarrow(wd),
                selected: v.effectiveAnchor == wd,
                onTap: () => _set(v.copyWith(anchorDay: wd)),
              ),
          ],
        ),
      ],
      CapsLabel(l.msWhenEnds),
      Wrap(spacing: 8, runSpacing: 8, children: [
        if (!emi)
          KuberChip(
            label: l.msWhenEndsNever,
            selected: v.endType == ScheduleEnd.never,
            showCheck: true,
            onTap: () => _set(v.copyWith(endType: ScheduleEnd.never)),
          ),
        KuberChip(
          label: emi ? l.msWhenNumberOfEmis : l.msWhenEndsAfter,
          selected: v.endType == ScheduleEnd.afterCount,
          showCheck: true,
          onTap: () => _set(v.copyWith(endType: ScheduleEnd.afterCount)),
        ),
        KuberChip(
          label: emi ? l.msWhenLastEmi : l.msWhenEndsOnDate,
          selected: v.endType == ScheduleEnd.onDate,
          showCheck: true,
          onTap: () => _set(v.copyWith(
              endType: ScheduleEnd.onDate,
              endDate: v.endDate ?? DateTime(v.start.year + 1, v.start.month, v.start.day))),
        ),
      ]),
      if (v.endType == ScheduleEnd.onDate)
        KuberGroup(children: [
          _dateRow(Icons.event_busy_rounded, emi ? l.msWhenLastEmi : l.msWhenEndDate,
              fmtDayLong(v.endDate ?? v.start), () async {
            final d = await _pickDate(v.endDate ?? v.start, first: v.firstOccurrence);
            if (d != null) _set(v.copyWith(endDate: d));
          }),
        ]),
      if (v.endType == ScheduleEnd.afterCount)
        Row(children: [
          SizedBox(
            width: 96,
            child: KuberTextField.number(
              showLabel: false,
              label: l.msWhenTimes,
              controller: _endCountCtrl,
              decimal: false,
              onChanged: (t) => _set(v.copyWith(endCount: int.tryParse(t) ?? 0)),
            ),
          ),
          const SizedBox(width: 12),
          Text(emi ? l.msLoansEmi : l.msWhenTimes, style: tt.bodyLarge),
        ]),
      WhenPreview(value: v, emi: emi, error: err),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          children[i],
        ],
      ],
    );
  }
}

class _WeekdayDot extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _WeekdayDot({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: selected ? cs.primary : Colors.transparent,
      shape: CircleBorder(side: BorderSide(color: selected ? cs.primary : cs.outlineVariant)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: Text(label,
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: selected ? cs.onPrimary : cs.onSurfaceVariant)),
          ),
        ),
      ),
    );
  }
}

/// The preview: sentence + next 3 dates (+ flags), last line, month-end note;
/// or the error. Updates on every change, no animation.
class WhenPreview extends StatelessWidget {
  final WhenValue value;
  final bool emi;
  final String? error;
  const WhenPreview({super.key, required this.value, this.emi = false, this.error});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    if (error != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: cs.errorContainer, borderRadius: KuberShape.largeR),
        child: Row(children: [
          Icon(Icons.error_rounded, size: 20, color: cs.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
              child: Text(error!, style: tt.titleSmall!.copyWith(color: cs.onErrorContainer))),
        ]),
      );
    }
    final s = value.toSchedule();
    final today = todayKey();
    final next = upcomingOccurrences(s, limit: 3);
    final total = totalOccurrences(s);
    final last = lastDate(s);
    final fg = cs.onSecondaryContainer;
    String? flag(int day) {
      if (day == today) return l.msWhenFlagToday;
      if (isClampedDay(s, day)) return l.msWhenFlagLastDay;
      if (day == next.first.day && day > today) return l.msWhenFlagNext;
      return null;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cs.secondaryContainer, borderRadius: KuberShape.largeR),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.event_repeat_rounded, size: 20, color: fg),
            const SizedBox(width: 12),
            Expanded(
              child: Text(scheduleSentence(l, s, emis: emi),
                  style: tt.titleSmall!.copyWith(color: fg)),
            ),
          ]),
          for (final (i, o) in next.indexed) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Row(children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                      color: fg.withValues(alpha: [1.0, 0.75, 0.5][i]),
                      shape: BoxShape.circle),
                ),
                const SizedBox(width: 10),
                Text(fmtDayLong(dayOf(o.day)), style: tt.bodyMedium!.copyWith(color: fg)),
                if (flag(o.day) != null) ...[
                  const SizedBox(width: 8),
                  Text(flag(o.day)!,
                      style: tt.labelSmall!.copyWith(color: fg.withValues(alpha: 0.8))),
                ],
              ]),
            ),
          ],
          if (last != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Text(
                emi
                    ? l.msWhenLastEmiOn(fmtDayLong(dayOf(last)))
                    : value.endType == ScheduleEnd.afterCount
                        ? l.msWhenCountTotal('${total ?? 0}')
                        : l.msWhenLastOn(fmtDayLong(dayOf(last))),
                style: tt.bodySmall!.copyWith(color: fg),
              ),
            ),
          ],
          if ((value.unit == ScheduleUnit.month || value.unit == ScheduleUnit.year) &&
              value.effectiveAnchor >= 29) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.info_outline_rounded, size: 16, color: fg),
                const SizedBox(width: 6),
                Expanded(
                    child: Text(l.msWhenMonthEnd, style: tt.bodySmall!.copyWith(color: fg))),
              ]),
            ),
          ],
        ],
      ),
    );
  }
}
