/// Bundled monochrome bank monogram marks for the Kuber Cards icon picker.
/// Each is an abstract initials mark (not a brand logo), tintable via
/// `flutter_svg` colorFilter. Keys use the `bank/` prefix so `CardIcon` and the
/// icon picker render them as `assets/bank_icons/<name>.svg`.
/// Generated set; see specs/plans/kuber-cards.md §5.1.
class BankIcon {
  final String key; // e.g. 'bank/hdfc'
  final String label;
  final List<String> tags;
  const BankIcon(this.key, this.label, this.tags);
}

const List<BankIcon> kBankIcons = [
  BankIcon('bank/hdfc', 'HDFC Bank', ['hdfc']),
  BankIcon('bank/sbi', 'State Bank of India', ['sbi', 'state bank']),
  BankIcon('bank/icici', 'ICICI Bank', ['icici']),
  BankIcon('bank/axis', 'Axis Bank', ['axis']),
  BankIcon('bank/kotak', 'Kotak Mahindra Bank', ['kotak', 'mahindra']),
  BankIcon('bank/pnb', 'Punjab National Bank', ['pnb', 'punjab national']),
  BankIcon('bank/bob', 'Bank of Baroda', ['bob', 'baroda']),
  BankIcon('bank/canara', 'Canara Bank', ['canara']),
  BankIcon('bank/union', 'Union Bank of India', ['union']),
  BankIcon('bank/indusind', 'IndusInd Bank', ['indusind', 'indus']),
  BankIcon('bank/yesbank', 'Yes Bank', ['yes bank', 'yes']),
  BankIcon('bank/idfc', 'IDFC First Bank', ['idfc', 'idfc first']),
  BankIcon('bank/federal', 'Federal Bank', ['federal']),
  BankIcon('bank/rbl', 'RBL Bank', ['rbl']),
  BankIcon('bank/bandhan', 'Bandhan Bank', ['bandhan']),
  BankIcon('bank/au', 'AU Small Finance Bank', ['au', 'au small finance']),
  BankIcon('bank/citi', 'Citibank', ['citi', 'citibank']),
  BankIcon('bank/hsbc', 'HSBC', ['hsbc']),
  BankIcon('bank/scb', 'Standard Chartered', ['standard chartered', 'scb']),
  BankIcon('bank/dbs', 'DBS Bank', ['dbs']),
  BankIcon('bank/amex', 'American Express', ['amex', 'american express']),
  BankIcon('bank/boi', 'Bank of India', ['boi', 'bank of india']),
  BankIcon('bank/central', 'Central Bank of India', ['central bank']),
  BankIcon('bank/indianbank', 'Indian Bank', ['indian bank']),
  BankIcon('bank/idbi', 'IDBI Bank', ['idbi']),
];

/// All bank keys, in catalog order (used to prepend to the picker so banks sort
/// first).
final List<String> kBankIconKeys = [for (final b in kBankIcons) b.key];

/// Display labels for `bank/*` keys.
final Map<String, String> kBankIconLabels = {
  for (final b in kBankIcons) b.key: b.label,
};

/// Search tags for `bank/*` keys.
final Map<String, List<String>> kBankIconTags = {
  for (final b in kBankIcons) b.key: b.tags,
};
