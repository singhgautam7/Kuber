import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

// Faithful in-app previews of each native home-screen widget. These reuse the
// Vault theme roles (income -> tertiary, expense -> error) so they adapt to
// light/dark, mirroring the native values/values-night colors.

class _P {
  final ColorScheme cs;
  final Color warning;
  final Color eventEmi;
  _P(BuildContext c)
      : cs = Theme.of(c).colorScheme,
        warning = c.kuberColors.warning,
        eventEmi = c.kuberColors.eventEmi;

  Color get income => cs.tertiary;
  Color get expense => cs.error;
  Color get primary => cs.primary;
  Color get text => cs.onSurface;
  Color get muted => cs.onSurfaceVariant;
  Color get surface => cs.surfaceContainer;
  Color get surfaceMuted => cs.surfaceContainerHighest;
  Color get border => cs.outlineVariant;
}

Widget _card(BuildContext context, {required double height, required Widget child}) {
  final p = _P(context);
  return Container(
    height: height,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: p.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: p.border),
    ),
    child: child,
  );
}

TextStyle _t(Color c, double size, {FontWeight w = FontWeight.w400}) =>
    TextStyle(color: c, fontSize: size, fontWeight: w, height: 1.2);

Widget _pill(String label, Color text, Color bg) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: _t(text, 8.5, w: FontWeight.w700)),
    );

/// Stacked income/expense bars (illustrative sample proportions).
Widget _bars(BuildContext context, {double gap = 6}) {
  final p = _P(context);
  const ex = [0.38, 0.22, 0.55, 0.30, 0.65, 0.20, 0.45];
  const inc = [0.18, 0.40, 0.12, 0.15, 0.20, 0.60, 0.10];
  return Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      for (var i = 0; i < ex.length; i++) ...[
        if (i > 0) SizedBox(width: gap),
        Expanded(
          child: FractionallySizedBox(
            widthFactor: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  flex: (ex[i] * 100).round(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: p.expense,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                    ),
                  ),
                ),
                Expanded(
                  flex: (inc[i] * 100).round(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: p.income,
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(2)),
                    ),
                  ),
                ),
                Expanded(flex: ((1 - ex[i] - inc[i]) * 100).round().clamp(0, 100), child: const SizedBox()),
              ],
            ),
          ),
        ),
      ],
    ],
  );
}

Widget _footerLink(BuildContext context, String label) {
  final p = _P(context);
  return Container(
    padding: const EdgeInsets.only(top: 6),
    decoration: BoxDecoration(border: Border(top: BorderSide(color: p.border))),
    alignment: Alignment.centerRight,
    child: Text(label, style: _t(p.primary, 10.5, w: FontWeight.w600)),
  );
}

// ---------------------------------------------------------------- SMALL

Widget monthlyNetPreview(BuildContext context) {
  final p = _P(context);
  return _card(context, height: 150, child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [
        Expanded(child: Text('THIS MONTH', style: _t(p.muted, 10, w: FontWeight.w700))),
        Container(
          width: 18, height: 18,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: p.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(5)),
          child: Text('₹', style: _t(p.primary, 10, w: FontWeight.w700)),
        ),
      ]),
      const Spacer(),
      Text('+₹18,240', style: _t(p.income, 26, w: FontWeight.w700)),
      const Spacer(),
      Text('Income ₹64,200 · Expense ₹45,960', style: _t(p.muted, 10)),
    ],
  ));
}

Widget accountBalancePreview(BuildContext context) {
  final p = _P(context);
  return _card(context, height: 150, child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [
        Expanded(child: Text('HDFC Savings', style: _t(p.muted, 10, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
        Container(width: 18, height: 18, decoration: BoxDecoration(color: p.surfaceMuted, borderRadius: BorderRadius.circular(5), border: Border.all(color: p.border))),
      ]),
      const Spacer(),
      Text('₹2,84,650', style: _t(p.income, 22, w: FontWeight.w700)),
      const Spacer(),
      Text('Last updated 4m ago', style: _t(p.muted, 10)),
    ],
  ));
}

Widget smsBadgePreview(BuildContext context) {
  final p = _P(context);
  return _card(context, height: 66, child: Row(children: [
    Expanded(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(Icons.sms_outlined, size: 12, color: p.primary),
          const SizedBox(width: 5),
          Text('IMPORT SMS', style: _t(p.primary, 9.5, w: FontWeight.w700)),
        ]),
        const SizedBox(height: 5),
        Text('unreviewed messages', style: _t(p.muted, 8.5)),
      ],
    )),
    Text('12', style: _t(p.text, 26, w: FontWeight.w700)),
  ]));
}

// ---------------------------------------------------------------- MEDIUM

Widget _eventRow(BuildContext context, String date, String title, Widget pill, String amount) {
  final p = _P(context);
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(children: [
      SizedBox(width: 44, child: Text(date, style: _t(p.muted, 10))),
      Expanded(child: Text(title, style: _t(p.text, 11.5), maxLines: 1, overflow: TextOverflow.ellipsis)),
      pill,
      const SizedBox(width: 8),
      Text(amount, style: _t(p.expense, 11.5, w: FontWeight.w700)),
    ]),
  );
}

Widget upcomingEventsPreview(BuildContext context) {
  final p = _P(context);
  return _card(context, height: 150, child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Upcoming events', style: _t(p.text, 13, w: FontWeight.w700)),
        Text('next 30 days', style: _t(p.muted, 10)),
      ]),
      const Spacer(),
      _eventRow(context, 'Today', 'Pay maid salary', _pill('REMINDER', p.primary, p.primary.withValues(alpha: 0.12)), '−₹3,000'),
      _eventRow(context, '5 Jul', 'Home Loan EMI', _pill('EMI', p.eventEmi, p.eventEmi.withValues(alpha: 0.12)), '−₹24,600'),
      _eventRow(context, '7 Jul', 'Nifty Index SIP', _pill('SIP', p.income, p.income.withValues(alpha: 0.12)), '−₹5,000'),
      const Spacer(),
      _footerLink(context, 'View all'),
    ],
  ));
}

Widget _txnRow(BuildContext context, Color dot, String name, String account, String amount, Color amtColor) {
  final p = _P(context);
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(children: [
      Container(width: 20, height: 20, decoration: BoxDecoration(color: dot.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6))),
      const SizedBox(width: 9),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, style: _t(p.text, 11.5), maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(account.toUpperCase(), style: _t(p.muted, 8.5)),
      ])),
      Text(amount, style: _t(amtColor, 11.5, w: FontWeight.w700)),
    ]),
  );
}

Widget recentTransactionsPreview(BuildContext context) {
  final p = _P(context);
  return _card(context, height: 150, child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Recent transactions', style: _t(p.text, 13, w: FontWeight.w700)),
      const Spacer(),
      _txnRow(context, p.warning, 'Swiggy order', 'HDFC Savings', '−₹460', p.expense),
      _txnRow(context, p.income, 'Salary credit', 'HDFC Savings', '+₹64,200', p.income),
      _txnRow(context, p.primary, 'Uber ride', 'ICICI Credit', '−₹212', p.expense),
      const Spacer(),
      _footerLink(context, 'View all'),
    ],
  ));
}

Widget _action(BuildContext context, IconData icon, String label) {
  final p = _P(context);
  return Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(icon, size: 16, color: p.primary),
    const SizedBox(height: 3),
    Text(label, style: _t(p.muted, 8.5, w: FontWeight.w500)),
  ]));
}

Widget quickActionsPreview(BuildContext context) {
  return _card(context, height: 62, child: Row(children: [
    _action(context, Icons.add, 'Add txn'),
    _action(context, Icons.repeat, 'Recurring'),
    _action(context, Icons.chat_bubble_outline, 'Ask Kuber'),
    _action(context, Icons.sms_outlined, 'Import SMS'),
  ]));
}

Widget chartCompactPreview(BuildContext context) {
  final p = _P(context);
  return _card(context, height: 150, child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Last 7 days', style: _t(p.text, 13, w: FontWeight.w700)),
        Text('−₹8,940', style: _t(p.expense, 12, w: FontWeight.w700)),
      ]),
      const SizedBox(height: 8),
      Expanded(child: _bars(context)),
      const SizedBox(height: 6),
      Row(children: [
        Text('Income ₹22,100', style: _t(p.income, 9.5)),
        const SizedBox(width: 14),
        Text('Expense ₹31,040', style: _t(p.expense, 9.5)),
      ]),
    ],
  ));
}

// ---------------------------------------------------------------- LARGE

Widget _chip(BuildContext context, String label, bool selected) {
  final p = _P(context);
  return Container(
    margin: const EdgeInsets.only(right: 6),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: selected ? p.primary.withValues(alpha: 0.14) : p.surfaceMuted,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: selected ? p.primary : p.border),
    ),
    child: Text(label, style: _t(selected ? p.primary : p.muted, 9.5, w: selected ? FontWeight.w700 : FontWeight.w500)),
  );
}

Widget trendsPreview(BuildContext context) {
  final p = _P(context);
  return _card(context, height: 224, child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Trends', style: _t(p.text, 13, w: FontWeight.w700)),
        Text('−₹42,300', style: _t(p.expense, 12, w: FontWeight.w700)),
      ]),
      const SizedBox(height: 8),
      Row(children: [_chip(context, '7D', true), _chip(context, '4W', false), _chip(context, '6M', false)]),
      const SizedBox(height: 10),
      Expanded(child: _bars(context, gap: 7)),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.only(top: 6),
        decoration: BoxDecoration(border: Border(top: BorderSide(color: p.border))),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Income ₹22,100', style: _t(p.income, 9)),
          Text('Expense ₹64,400', style: _t(p.expense, 9)),
          Text('View analytics', style: _t(p.primary, 9, w: FontWeight.w700)),
        ]),
      ),
    ],
  ));
}

Widget _legend(BuildContext context, Color dot, String name, String value) {
  final p = _P(context);
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: dot, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 6),
      Expanded(child: Text(name, style: _t(p.text, 10.5), maxLines: 1, overflow: TextOverflow.ellipsis)),
      Text(value, style: _t(p.muted, 10)),
    ]),
  );
}

Widget categoryDonutPreview(BuildContext context) {
  final p = _P(context);
  return _card(context, height: 224, child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Top categories', style: _t(p.text, 13, w: FontWeight.w700)),
      Text('this month', style: _t(p.muted, 10)),
      const SizedBox(height: 6),
      Expanded(child: Row(children: [
        SizedBox(width: 88, height: 88, child: CustomPaint(painter: _DonutPainter([
          (0.42, p.primary), (0.26, p.warning), (0.17, p.eventEmi), (0.15, p.surfaceMuted),
        ], p.surface))),
        const SizedBox(width: 16),
        Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          _legend(context, p.primary, 'Food', '₹19,300 · 42%'),
          _legend(context, p.warning, 'Transport', '₹11,900 · 26%'),
          _legend(context, p.eventEmi, 'Shopping', '₹7,800 · 17%'),
        ])),
      ])),
      _footerLink(context, 'View analytics'),
    ],
  ));
}

class _DonutPainter extends CustomPainter {
  final List<(double, Color)> segments;
  final Color holeColor;
  _DonutPainter(this.segments, this.holeColor);
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    var start = -1.5708;
    final paint = Paint()..style = PaintingStyle.fill;
    for (final (frac, color) in segments) {
      paint.color = color;
      final sweep = frac * 6.28319;
      canvas.drawArc(rect, start, sweep, true, paint);
      start += sweep;
    }
    canvas.drawCircle(size.center(Offset.zero), size.width * 0.28, Paint()..color = holeColor);
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => false;
}

Widget _budgetRow(BuildContext context, String name, String value, double pct, Color color) {
  final p = _P(context);
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Column(children: [
      Row(children: [
        Expanded(child: Text(name, style: _t(p.text, 10.5))),
        Text(value, style: _t(p.muted, 10.5)),
      ]),
      const SizedBox(height: 4),
      ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: LinearProgressIndicator(
          value: pct, minHeight: 5, backgroundColor: p.surfaceMuted, color: color,
        ),
      ),
    ]),
  );
}

Widget budgetStatusPreview(BuildContext context) {
  final p = _P(context);
  return _card(context, height: 224, child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Budget status', style: _t(p.text, 13, w: FontWeight.w700)),
      Text('this month', style: _t(p.muted, 10)),
      const Spacer(),
      _budgetRow(context, 'Food', '₹19,300 / ₹20,000 · 96%', 0.96, p.warning),
      _budgetRow(context, 'Transport', '₹11,900 / ₹15,000 · 79%', 0.79, p.primary),
      _budgetRow(context, 'Shopping', '₹9,800 / ₹8,000 · 122%', 1.0, p.expense),
      const Spacer(),
      Container(
        padding: const EdgeInsets.only(top: 6),
        decoration: BoxDecoration(border: Border(top: BorderSide(color: p.border))),
        alignment: Alignment.centerLeft,
        child: Text('+ 2 more', style: _t(p.muted, 10)),
      ),
    ],
  ));
}

Widget _gridAction(BuildContext context, IconData icon, String label) {
  final p = _P(context);
  return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(icon, size: 17, color: p.primary),
    const SizedBox(height: 4),
    Text(label, style: _t(p.muted, 8)),
  ]);
}

Widget quickActionsExtendedPreview(BuildContext context) {
  final p = _P(context);
  return _card(context, height: 224, child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Quick actions', style: _t(p.text, 13, w: FontWeight.w700)),
      const SizedBox(height: 8),
      Expanded(child: GridView.count(
        crossAxisCount: 4, physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.1,
        children: [
          _gridAction(context, Icons.add, 'Add txn'),
          _gridAction(context, Icons.repeat, 'Recurring'),
          _gridAction(context, Icons.account_balance_outlined, 'Add loan'),
          _gridAction(context, Icons.trending_up, 'Invest'),
          _gridAction(context, Icons.swap_horiz, 'Lend/Borrow'),
          _gridAction(context, Icons.chat_bubble_outline, 'Ask Kuber'),
          _gridAction(context, Icons.calculate_outlined, 'Calculators'),
          _gridAction(context, Icons.description_outlined, 'Notes'),
        ],
      )),
    ],
  ));
}

Widget _noteRow(BuildContext context, String title, String preview, String time) {
  final p = _P(context);
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: _t(p.text, 11.5, w: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
      const SizedBox(height: 2),
      Row(children: [
        Expanded(child: Text(preview, style: _t(p.muted, 9.5), maxLines: 1, overflow: TextOverflow.ellipsis)),
        const SizedBox(width: 8),
        Text(time, style: _t(p.muted, 9)),
      ]),
    ]),
  );
}

Widget notesPreview(BuildContext context) {
  final p = _P(context);
  return _card(context, height: 224, child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Kuber Notes', style: _t(p.text, 13, w: FontWeight.w700)),
        Text('Add note', style: _t(p.primary, 10.5, w: FontWeight.w600)),
      ]),
      const Spacer(),
      _noteRow(context, 'Rent renewal - landlord terms', 'Deposit 2 months, 11% hike from Aug…', '2h ago'),
      _noteRow(context, 'Trip budget - Goa Aug', 'Flights ₹9k, stay ₹14k, buffer 20%…', '1d ago'),
      _noteRow(context, 'Tax docs checklist FY26', 'Form 16, 80C proofs, rent receipts…', '3d ago'),
      const Spacer(),
      _footerLink(context, 'View all notes'),
    ],
  ));
}
