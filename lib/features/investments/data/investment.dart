import 'package:isar_community/isar.dart';

import '../../../core/schedule/schedule.dart';
import '../../tools/engine/fd_rd_engine.dart' show CompoundingFrequency;

part 'investment.g.dart';

/// How a holding's value changes (design: three behaviours).
enum InvestmentBehaviour { market, fixedReturn, other }

enum StepUpKind { percent, amount }

enum PayoutType { cumulative, monthly, quarterly, yearly }

enum InvestmentStatus { active, closed }

/// A dated value point. The first is the value at migration / creation.
@embedded
class ValueSnapshot {
  DateTime? date;
  double value = 0;

  ValueSnapshot();

  Map<String, dynamic> toMap() =>
      {'date': date?.toIso8601String(), 'value': value};

  static ValueSnapshot fromMap(Map<String, dynamic> m) => ValueSnapshot()
    ..date = m['date'] == null ? null : DateTime.parse(m['date'] as String)
    ..value = (m['value'] as num?)?.toDouble() ?? 0;
}

/// A redemption: invested reduces by invested x (redeemed / value).
@embedded
class Withdrawal {
  DateTime? date;
  double redeemed = 0;
  double charges = 0;
  double received = 0;
  String? accountId;
  double investedReduction = 0;
  double realizedGain = 0;
  int? transactionId;

  Withdrawal();

  Map<String, dynamic> toMap() => {
    'date': date?.toIso8601String(),
    'redeemed': redeemed,
    'charges': charges,
    'received': received,
    'accountId': accountId,
    'investedReduction': investedReduction,
    'realizedGain': realizedGain,
    'transactionId': transactionId,
  };

  static Withdrawal fromMap(Map<String, dynamic> m) => Withdrawal()
    ..date = m['date'] == null ? null : DateTime.parse(m['date'] as String)
    ..redeemed = (m['redeemed'] as num?)?.toDouble() ?? 0
    ..charges = (m['charges'] as num?)?.toDouble() ?? 0
    ..received = (m['received'] as num?)?.toDouble() ?? 0
    ..accountId = m['accountId'] as String?
    ..investedReduction = (m['investedReduction'] as num?)?.toDouble() ?? 0
    ..realizedGain = (m['realizedGain'] as num?)?.toDouble() ?? 0
    ..transactionId = m['transactionId'] as int?;
}

@collection
class Investment {
  Id id = Isar.autoIncrement;

  late String uid; // UUID — used as linkedRuleId on contribution transactions

  late String name; // e.g. "Bitcoin", "HDFC Index Fund"

  late String investmentType; // 'sip' | 'mutual_fund' | 'stocks' | 'etf' | 'bonds' | 'gold' | 'real_estate' | 'crypto' | 'fd' | 'rd' | 'collectible' | 'other'

  double? currentValue; // User-updated manually, for P&L display

  double? investedAmount; // Total amount invested (initial + contributions)

  bool autoDebit = false; // Enable auto-debit for SIP

  double? sipAmount; // Monthly SIP amount (if autoDebit = true)

  int? sipDate; // Day of month for SIP (1–28)

  String? accountId; // Source account for SIP (required if autoDebit = true)

  late String categoryId; // Auto-selected 'Investment' system category

  String? notes;

  bool deductedFromAccount = true;

  late DateTime createdAt;

  late DateTime updatedAt;

  // ── vNext. Old SIP fields (autoDebit, sipAmount, sipDate) stay as they
  // were at migration and are read only from here on. ──────────────────

  @Enumerated(EnumType.name)
  InvestmentBehaviour behaviour = InvestmentBehaviour.market;

  /// SIP / RD installment schedule (any interval).
  Schedule? sip;

  @Enumerated(EnumType.name)
  StepUpKind stepUpKind = StepUpKind.percent;

  /// 0 = no yearly step-up.
  double stepUpValue = 0;

  double? units;

  List<ValueSnapshot> snapshots = [];

  List<Withdrawal> withdrawals = [];

  // Fixed return (FD, RD, PPF, bonds). The value is calculated, not stored.
  double? fixedPrincipal;
  double? installment;
  double? fixedRate;

  @Enumerated(EnumType.name)
  CompoundingFrequency compounding = CompoundingFrequency.quarterly;

  @Enumerated(EnumType.name)
  PayoutType payout = PayoutType.cumulative;

  DateTime? fixedStart;
  int? fixedTenureMonths;
  DateTime? maturityDate;
  bool maturityHandled = false;

  @Enumerated(EnumType.name)
  InvestmentStatus status = InvestmentStatus.active;

  DateTime? closedAt;

  bool alreadyRunning = false;
  double openingInvested = 0;
  double? openingValue;
  DateTime? openingDate;

  /// 0 = not migrated to vNext yet.
  int dataVersion = 0;

  Map<String, dynamic> toMap() => {
    'id': id,
    'uid': uid,
    'name': name,
    'investmentType': investmentType,
    'currentValue': currentValue,
    'investedAmount': investedAmount,
    'autoDebit': autoDebit,
    'sipAmount': sipAmount,
    'sipDate': sipDate,
    'accountId': accountId,
    'categoryId': categoryId,
    'notes': notes,
    'deductedFromAccount': deductedFromAccount,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'behaviour': behaviour.name,
    'sip': sip?.toMap(),
    'stepUpKind': stepUpKind.name,
    'stepUpValue': stepUpValue,
    'units': units,
    'snapshots': snapshots.map((s) => s.toMap()).toList(),
    'withdrawals': withdrawals.map((w) => w.toMap()).toList(),
    'fixedPrincipal': fixedPrincipal,
    'installment': installment,
    'fixedRate': fixedRate,
    'compounding': compounding.name,
    'payout': payout.name,
    'fixedStart': fixedStart?.toIso8601String(),
    'fixedTenureMonths': fixedTenureMonths,
    'maturityDate': maturityDate?.toIso8601String(),
    'maturityHandled': maturityHandled,
    'status': status.name,
    'closedAt': closedAt?.toIso8601String(),
    'alreadyRunning': alreadyRunning,
    'openingInvested': openingInvested,
    'openingValue': openingValue,
    'openingDate': openingDate?.toIso8601String(),
    'dataVersion': dataVersion,
  };
}
