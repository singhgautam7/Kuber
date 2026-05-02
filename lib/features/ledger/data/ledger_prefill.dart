class LedgerPrefill {
  final String personName;
  final String type; // 'lent' | 'borrowed'
  final double amount;
  final String? notes;
  final DateTime? entryDate;

  const LedgerPrefill({
    required this.personName,
    required this.type,
    required this.amount,
    this.notes,
    this.entryDate,
  });
}
