import 'package:isar_community/isar.dart';

part 'bill.g.dart';

@collection
class Bill {
  Id id = Isar.autoIncrement;

  late String name;
  late double totalAmount;
  late String paidByPersonName;
  late String splitType; // 'equal' | 'unequal' | 'percentage' | 'fraction'
  late List<BillParticipant> participants;
  late DateTime createdAt;
  bool isArchived = false;
  DateTime? archivedAt;

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'totalAmount': totalAmount,
    'paidByPersonName': paidByPersonName,
    'splitType': splitType,
    'participantCount': participants.length,
    'createdAt': createdAt.toIso8601String(),
    'isArchived': isArchived,
    'archivedAt': archivedAt?.toIso8601String(),
  };
}

@embedded
class BillParticipant {
  late String personName;
  late double share;
  double? rawInput;
}
