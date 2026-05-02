import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/bill.dart';
import 'bills_provider.dart';

/// Represents a person's net balance across all bills.
class PersonNet {
  final String name;
  final double amount; // positive = they owe you, negative = you owe them
  final int bills; // number of bills this person is in

  const PersonNet({
    required this.name,
    required this.amount,
    required this.bills,
  });

  bool get isSettled => amount.abs() < 0.01;
}

/// Summary of your overall net position across all bills.
class NetSummary {
  final double youReceive; // total owed to you
  final double youOwe; // total you owe
  final double net; // net = youReceive - youOwe
  final int activePeople; // people with unsettled balance

  const NetSummary({
    required this.youReceive,
    required this.youOwe,
    required this.net,
    required this.activePeople,
  });
}

/// "You" constant — must match how payer/participant is stored.
const kYouName = 'You';

/// Computes per-person net across all bills from "Your" perspective.
///
/// Positive amount → that person owes you.
/// Negative amount → you owe that person.
final personNetListProvider = Provider<AsyncValue<List<PersonNet>>>((ref) {
  final billsAsync = ref.watch(billsListProvider);
  return billsAsync.whenData(
    (bills) =>
        _computePersonNets(bills.where((bill) => !bill.isArchived).toList()),
  );
});

List<PersonNet> _computePersonNets(List<Bill> bills) {
  // Map: personName → running net (from "You" perspective)
  final Map<String, double> nets = {};
  final Map<String, int> billCounts = {};

  for (final bill in bills) {
    final payer = bill.paidByPersonName;
    final total = bill.totalAmount;

    // Build share map
    final Map<String, double> shares = {};
    for (final p in bill.participants) {
      shares[p.personName] = p.share;
    }

    // Determine what flows between "You" and each other person
    if (payer == kYouName) {
      // You paid → everyone else owes you their share
      for (final entry in shares.entries) {
        if (entry.key == kYouName) continue;
        nets[entry.key] = (nets[entry.key] ?? 0) + entry.value;
        billCounts[entry.key] = (billCounts[entry.key] ?? 0) + 1;
      }
    } else if (shares.containsKey(kYouName)) {
      // Someone else paid and you're a participant → you owe payer your share
      final yourShare = shares[kYouName] ?? (total / bill.participants.length);
      nets[payer] = (nets[payer] ?? 0) - yourShare;
      billCounts[payer] = (billCounts[payer] ?? 0) + 1;
    }

    // For bills where neither you paid nor you participate — no affect on you
  }

  // Sort by absolute amount descending
  final result =
      nets.entries
          .map(
            (e) => PersonNet(
              name: e.key,
              amount: e.value,
              bills: billCounts[e.key] ?? 0,
            ),
          )
          .toList()
        ..sort((a, b) => b.amount.abs().compareTo(a.amount.abs()));

  return result;
}

/// Overall net summary.
final netSummaryProvider = Provider<AsyncValue<NetSummary>>((ref) {
  final netListAsync = ref.watch(personNetListProvider);
  return netListAsync.whenData((netList) {
    double youReceive = 0;
    double youOwe = 0;
    int activePeople = 0;
    for (final p in netList) {
      if (p.amount > 0.01) {
        youReceive += p.amount;
        activePeople++;
      } else if (p.amount < -0.01) {
        youOwe += p.amount.abs();
        activePeople++;
      }
    }
    return NetSummary(
      youReceive: youReceive,
      youOwe: youOwe,
      net: youReceive - youOwe,
      activePeople: activePeople,
    );
  });
});

/// Determines your status in a specific bill (used for the bill row display).
enum BillStatus { youLent, youOwe, settled, notInvolved }

BillStatus billStatusForYou(Bill bill) {
  final payer = bill.paidByPersonName;
  final yourParticipant = bill.participants
      .where((p) => p.personName == kYouName)
      .firstOrNull;

  if (yourParticipant == null) return BillStatus.notInvolved;

  if (payer == kYouName) {
    // You paid — you lent money to others
    return BillStatus.youLent;
  } else {
    // Someone else paid — you owe them
    return BillStatus.youOwe;
  }
}

/// Your share amount in a specific bill.
double yourShareInBill(Bill bill) {
  final yourParticipant = bill.participants
      .where((p) => p.personName == kYouName)
      .firstOrNull;
  if (yourParticipant == null) return 0;
  if (bill.paidByPersonName == kYouName) {
    // You paid; your "share" here is what others owe you total
    final othersTotal = bill.participants
        .where((p) => p.personName != kYouName)
        .fold(0.0, (sum, p) => sum + p.share);
    return othersTotal;
  }
  return yourParticipant.share;
}

class SplitDebt {
  final String personName;
  final String type; // 'lent' | 'borrowed'
  final double amount;

  const SplitDebt({
    required this.personName,
    required this.type,
    required this.amount,
  });

  bool get isLent => type == 'lent';
}

List<SplitDebt> debtsForYou(Bill bill) {
  final shares = {
    for (final participant in bill.participants)
      participant.personName: participant.share,
  };

  if (bill.paidByPersonName == kYouName) {
    return bill.participants
        .where(
          (participant) =>
              participant.personName != kYouName && participant.share > 0.01,
        )
        .map(
          (participant) => SplitDebt(
            personName: participant.personName,
            type: 'lent',
            amount: participant.share,
          ),
        )
        .toList();
  }

  final yourShare = shares[kYouName];
  if (yourShare == null || yourShare <= 0.01) return const [];

  return [
    SplitDebt(
      personName: bill.paidByPersonName,
      type: 'borrowed',
      amount: yourShare,
    ),
  ];
}

String splitLedgerNote({
  required Bill bill,
  required SplitDebt debt,
  required String Function(double amount) formatAmount,
}) {
  final buffer = StringBuffer()
    ..writeln('Added from Split Calculator.')
    ..writeln(
      debt.isLent
          ? '${debt.personName} owes You ${formatAmount(debt.amount)}.'
          : 'You owe ${debt.personName} ${formatAmount(debt.amount)}.',
    )
    ..writeln('Bill: ${bill.name}')
    ..writeln('Total: ${formatAmount(bill.totalAmount)}')
    ..writeln('Paid by: ${bill.paidByPersonName}')
    ..writeln('Split details:');

  for (final participant in bill.participants) {
    buffer.writeln(
      '- ${participant.personName}: ${formatAmount(participant.share)}',
    );
  }

  return buffer.toString().trim();
}
