import 'package:isar_community/isar.dart';

part 'saved_calculation.g.dart';

/// Reference-only saved calculator states. NOT linked to Kuber's Loans or
/// Investments features — saving a calculation never creates a loan or an
/// investment, and nothing here reads or writes those collections.
@collection
class SavedCalculation {
  Id id = Isar.autoIncrement;

  /// Tool route key, e.g. 'emi-calculator', 'goal-planner'. Indexed for the
  /// Saved Calculations filter chips.
  @Index()
  late String tool;

  /// User-given memorable name, e.g. "Home loan — Mumbai".
  late String name;

  /// All inputs for this tool, serialized as a JSON map string (each tool owns
  /// its own shape).
  late String inputsJson;

  /// Denormalized one-line summary for the list card,
  /// e.g. "₹25,00,000 @ 8.5% for 20y → EMI ₹21,696".
  late String summary;

  late DateTime savedAt;
  late DateTime updatedAt;

  Map<String, dynamic> toMap() => {
        'id': id,
        'tool': tool,
        'name': name,
        'inputsJson': inputsJson,
        'summary': summary,
        'savedAt': savedAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
