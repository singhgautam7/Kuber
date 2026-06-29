import 'package:isar_community/isar.dart';

part 'calculator_recent_use.g.dart';

/// Lightweight "recently used" tracking for the Tools landing page. Upserted
/// whenever a user opens a calculator, independent of whether they save it.
@collection
class CalculatorRecentUse {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String calculatorType; // tool route key

  late DateTime lastUsed;
  late int useCount;

  Map<String, dynamic> toMap() => {
        'id': id,
        'calculatorType': calculatorType,
        'lastUsed': lastUsed.toIso8601String(),
        'useCount': useCount,
      };
}
