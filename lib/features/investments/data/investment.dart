import 'package:isar/isar.dart';

part 'investment.g.dart';

@collection
class Investment {
  Id id = Isar.autoIncrement;

  late String uid; // UUID — used as linkedRuleId on contribution transactions

  late String name; // e.g. "Bitcoin", "HDFC Index Fund"

  late String investmentType; // 'sip' | 'mutual_fund' | 'stocks' | 'crypto' | 'trading' | 'other'

  double? currentValue; // User-updated manually, for P&L display

  bool autoDebit = false; // Enable auto-debit for SIP

  double? sipAmount; // Monthly SIP amount (if autoDebit = true)

  int? sipDate; // Day of month for SIP (1–28)

  String? accountId; // Source account for SIP (required if autoDebit = true)

  late String categoryId; // Auto-selected 'Investment' system category

  String? notes;

  late DateTime createdAt;

  late DateTime updatedAt;
}
