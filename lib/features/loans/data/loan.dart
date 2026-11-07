import 'package:isar_community/isar.dart';

import '../../../core/schedule/schedule.dart';

part 'loan.g.dart';

enum LoanMode { simple, advanced }

enum LoanInterestType { reducingBalance, flatRate, interestOnlyFirst }

/// "Already running?" starting point.
enum LoanStartingPoint { originalDetails, outstandingToday, trackEmiOnly }

/// Stored by name; [chargeAdded] is a charge the bank added to the loan (it
/// raises the outstanding), [charge] a fee paid from an account.
enum LoanEventKind { rateChange, prepayment, charge, adjustment, chargeAdded }

/// "Interest before EMIs start" (nov-release A2). [none]: not modelled.
enum LoanPreEmi { none, payMonthly, addToLoan }

/// Why the outstanding was updated (adjustment events).
enum LoanAdjustReason { matchBank, interestAdded }

/// What a prepayment or rate change adjusts.
enum LoanAdjust { tenure, emi }

/// A dated change applied to the amortization schedule, in date order.
@embedded
class LoanEvent {
  @Enumerated(EnumType.name)
  LoanEventKind kind = LoanEventKind.prepayment;

  DateTime? date;

  /// Rate change: new annual rate (percent).
  double? newRate;

  @Enumerated(EnumType.name)
  LoanAdjust adjust = LoanAdjust.tenure;

  /// Prepayment: principal part. Charge: the charge amount. Adjustment: the
  /// signed difference to Kuber's outstanding on [date].
  double amount = 0;

  /// Adjustment: why (stored by name).
  @Enumerated(EnumType.name)
  LoanAdjustReason reason = LoanAdjustReason.matchBank;

  /// Prepayment charge (expense, never reduces the outstanding amount).
  double charge = 0;

  int? transactionId;
  int? chargeTransactionId;

  /// Add to loan: the user's note.
  String? note;

  LoanEvent();

  Map<String, dynamic> toMap() => {
    'kind': kind.name,
    'date': date?.toIso8601String(),
    'newRate': newRate,
    'adjust': adjust.name,
    'amount': amount,
    'charge': charge,
    'transactionId': transactionId,
    'chargeTransactionId': chargeTransactionId,
    'reason': reason.name,
    'note': note,
  };

  static LoanEvent fromMap(Map<String, dynamic> m) => LoanEvent()
    ..kind = LoanEventKind.values.firstWhere((k) => k.name == m['kind'],
        orElse: () => LoanEventKind.prepayment)
    ..date = m['date'] == null ? null : DateTime.parse(m['date'] as String)
    ..newRate = (m['newRate'] as num?)?.toDouble()
    ..adjust = LoanAdjust.values.firstWhere((a) => a.name == m['adjust'],
        orElse: () => LoanAdjust.tenure)
    ..amount = (m['amount'] as num?)?.toDouble() ?? 0
    ..charge = (m['charge'] as num?)?.toDouble() ?? 0
    ..transactionId = m['transactionId'] as int?
    ..chargeTransactionId = m['chargeTransactionId'] as int?
    ..reason = LoanAdjustReason.values.firstWhere((r) => r.name == m['reason'],
        orElse: () => LoanAdjustReason.matchBank)
    ..note = m['note'] as String?;
}

/// One payout of the loan (nov-release A1). Loans saved before this have none:
/// they read as one release of the full principal (see `loanReleases`).
@embedded
class LoanRelease {
  DateTime? date;

  double amount = 0;

  /// The account the money reached; null = "Not recorded" (no transaction).
  String? accountId;

  /// The `loan_disbursement` transaction, when [accountId] is set.
  int? transactionId;

  /// After EMIs started: what the extra balance changes.
  @Enumerated(EnumType.name)
  LoanAdjust adjust = LoanAdjust.tenure;

  String? note;

  LoanRelease();

  LoanRelease copy() => LoanRelease()
    ..date = date
    ..amount = amount
    ..accountId = accountId
    ..transactionId = transactionId
    ..adjust = adjust
    ..note = note;

  Map<String, dynamic> toMap() => {
    'date': date?.toIso8601String(),
    'amount': amount,
    'accountId': accountId,
    'transactionId': transactionId,
    'adjust': adjust.name,
    'note': note,
  };

  static LoanRelease fromMap(Map<String, dynamic> m) => LoanRelease()
    ..date = m['date'] == null ? null : DateTime.parse(m['date'] as String)
    ..amount = (m['amount'] as num?)?.toDouble() ?? 0
    ..accountId = m['accountId'] as String?
    ..transactionId = m['transactionId'] as int?
    ..adjust = LoanAdjust.values.firstWhere((a) => a.name == m['adjust'],
        orElse: () => LoanAdjust.tenure)
    ..note = m['note'] as String?;
}

@collection
class Loan {
  Id id = Isar.autoIncrement;

  late String uid; // UUID — used as linkedRuleId on payment transactions

  late String name; // e.g. "Home Loan", "Bike Loan"

  late String loanType; // 'home' | 'vehicle' | 'personal' | 'education' | 'other'

  late String lenderName; // e.g. "HDFC Housing Finance"

  String? referenceNumber; // e.g. "#HL-8829"

  late double principalAmount; // Total loan principal (informational)

  late double emiAmount; // Monthly EMI amount

  String? rateType; // 'fixed' | 'floating'

  double? interestRate; // e.g. 8.45 (percent p.a.)

  DateTime? loanStartDate; // Optional — loan disbursement / sanction date

  late int billDate; // Day of month EMI is due (1–28)

  late DateTime startDate; // Repayment start date

  DateTime? endDate; // Optional projected end date

  bool autoAddTransaction = false;

  late String accountId; // Debit account for EMI payments

  late String categoryId; // Auto-selected 'Loan EMI' system category

  String? notes;

  bool isCompleted = false;

  late DateTime createdAt;

  late DateTime updatedAt;

  // ── vNext (money schedules). Old fields above stay as they were at
  // migration and are read only from here on. ──────────────────────────

  @Enumerated(EnumType.name)
  LoanMode mode = LoanMode.simple;

  @Enumerated(EnumType.name)
  LoanInterestType interestType = LoanInterestType.reducingBalance;

  int interestOnlyMonths = 0;

  /// Total EMIs including interest-only months.
  int? tenureMonths;

  /// Annual rate in percent (canonical copy of [interestRate]).
  double? annualRate;

  /// Monthly EMI schedule (count = number of EMIs, or an end date).
  Schedule? schedule;

  bool alreadyRunning = false;

  @Enumerated(EnumType.name)
  LoanStartingPoint startingPoint = LoanStartingPoint.originalDetails;

  double principalPaidBefore = 0;
  double interestPaidBefore = 0;
  int emisPaidBefore = 0;
  double? outstandingAtStart;

  /// Opening adjustment when the user overrides the calculated outstanding.
  double adjustment = 0;

  bool countOnlyInterest = false;
  DateTime? countOnlyInterestFrom;

  List<LoanEvent> events = [];

  /// "Add past EMIs as transactions" (original details, already running):
  /// every EMI from the first EMI date is a transaction, so nothing is
  /// "paid before Kuber". [pastEmisAddedAt]: when they were last added.
  bool addPastEmis = false;
  DateTime? pastEmisAddedAt;

  DateTime? closedAt;

  // ── November release: loan released in parts, interest before EMIs. All
  // default to "nothing new", so older rows and backups read unchanged. ──

  /// Payouts, in date order. One entry with the switch off (it only carries
  /// the "received in" account), none on loans that never set it.
  List<LoanRelease> releases = [];

  bool releasedInParts = false;

  @Enumerated(EnumType.name)
  LoanPreEmi preEmiMode = LoanPreEmi.none;

  /// Day of month interest is charged before EMIs. Null = the EMI day.
  int? preEmiCycleDay;

  /// "Interest added before EMIs" edited by the user: what the pre-EMI period
  /// adds to the released amount. Applied on the first EMI date.
  double? preEmiOverride;

  /// Kuber's own figure when [preEmiOverride] was last accepted, to notice
  /// when it moves ("Kuber now calculates").
  double? preEmiCalculated;

  /// 0 = not migrated to vNext yet.
  int dataVersion = 0;

  /// A detached copy (forms edit a copy; the stored row changes on save).
  Loan copy() => Loan()
    ..id = id
    ..uid = uid
    ..name = name
    ..loanType = loanType
    ..lenderName = lenderName
    ..referenceNumber = referenceNumber
    ..principalAmount = principalAmount
    ..emiAmount = emiAmount
    ..rateType = rateType
    ..interestRate = interestRate
    ..loanStartDate = loanStartDate
    ..billDate = billDate
    ..startDate = startDate
    ..endDate = endDate
    ..autoAddTransaction = autoAddTransaction
    ..accountId = accountId
    ..categoryId = categoryId
    ..notes = notes
    ..isCompleted = isCompleted
    ..createdAt = createdAt
    ..updatedAt = updatedAt
    ..mode = mode
    ..interestType = interestType
    ..interestOnlyMonths = interestOnlyMonths
    ..tenureMonths = tenureMonths
    ..annualRate = annualRate
    ..schedule = schedule?.copy()
    ..alreadyRunning = alreadyRunning
    ..startingPoint = startingPoint
    ..principalPaidBefore = principalPaidBefore
    ..interestPaidBefore = interestPaidBefore
    ..emisPaidBefore = emisPaidBefore
    ..outstandingAtStart = outstandingAtStart
    ..adjustment = adjustment
    ..countOnlyInterest = countOnlyInterest
    ..countOnlyInterestFrom = countOnlyInterestFrom
    ..events = [...events]
    ..addPastEmis = addPastEmis
    ..pastEmisAddedAt = pastEmisAddedAt
    ..closedAt = closedAt
    ..releases = [for (final r in releases) r.copy()]
    ..releasedInParts = releasedInParts
    ..preEmiMode = preEmiMode
    ..preEmiCycleDay = preEmiCycleDay
    ..preEmiOverride = preEmiOverride
    ..preEmiCalculated = preEmiCalculated
    ..dataVersion = dataVersion;

  Map<String, dynamic> toMap() => {
    'id': id,
    'uid': uid,
    'name': name,
    'loanType': loanType,
    'lenderName': lenderName,
    'referenceNumber': referenceNumber,
    'principalAmount': principalAmount,
    'emiAmount': emiAmount,
    'rateType': rateType,
    'interestRate': interestRate,
    'loanStartDate': loanStartDate?.toIso8601String(),
    'billDate': billDate,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'autoAddTransaction': autoAddTransaction,
    'accountId': accountId,
    'categoryId': categoryId,
    'notes': notes,
    'isCompleted': isCompleted,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'mode': mode.name,
    'interestType': interestType.name,
    'interestOnlyMonths': interestOnlyMonths,
    'tenureMonths': tenureMonths,
    'annualRate': annualRate,
    'schedule': schedule?.toMap(),
    'alreadyRunning': alreadyRunning,
    'startingPoint': startingPoint.name,
    'principalPaidBefore': principalPaidBefore,
    'interestPaidBefore': interestPaidBefore,
    'emisPaidBefore': emisPaidBefore,
    'outstandingAtStart': outstandingAtStart,
    'adjustment': adjustment,
    'countOnlyInterest': countOnlyInterest,
    'countOnlyInterestFrom': countOnlyInterestFrom?.toIso8601String(),
    'events': events.map((e) => e.toMap()).toList(),
    'addPastEmis': addPastEmis,
    'pastEmisAddedAt': pastEmisAddedAt?.toIso8601String(),
    'closedAt': closedAt?.toIso8601String(),
    'releases': releases.map((r) => r.toMap()).toList(),
    'releasedInParts': releasedInParts,
    'preEmiMode': preEmiMode.name,
    'preEmiCycleDay': preEmiCycleDay,
    'preEmiOverride': preEmiOverride,
    'preEmiCalculated': preEmiCalculated,
    'dataVersion': dataVersion,
  };
}
