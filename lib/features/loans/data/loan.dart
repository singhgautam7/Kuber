import 'package:isar_community/isar.dart';

part 'loan.g.dart';

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
}
