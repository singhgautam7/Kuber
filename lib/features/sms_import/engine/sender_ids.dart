/// Known Indian bank and payment-service SMS sender IDs. This is the single
/// source of truth for what counts as a "bank SMS" — the inbox scan filters on
/// it, so a message from an unrecognised sender is never read.
///
/// Real Android sender fields are prefixed by the operator header (TRAI DLT
/// format), e.g. `VM-HDFCBK`, `AD-SBIINB-S`, `JD-ICICIB`. [isKnownBankSender]
/// matches the bank token regardless of that prefix/suffix decoration.
const List<String> knownBankSenderIds = [
  // HDFC Bank
  'HDFCBK', 'HDFCBANK', 'HDFC',
  // SBI
  'SBIINB', 'SBIPSG', 'SBI',
  // ICICI Bank
  'ICICIB', 'ICICIBANK', 'ICICI',
  // Axis Bank
  'AXISBK', 'AXISBANK', 'AXIS',
  // Kotak Bank
  'KOTAKB', 'KOTAK',
  // IndusInd Bank
  'INDUSB', 'INDUSLND',
  // Yes Bank
  'YESBK', 'YESBANK',
  // IDFC First Bank
  'IDFCFB', 'IDFCBANK',
  // Bank of Baroda
  'BOBIMT', 'BOBTXN',
  // Punjab National Bank
  'PNBSMS',
  // Canara Bank
  'CNRBSMS',
  // Union Bank
  'UBINAT',
  // Federal Bank
  'FEDBNK',
  // RBL Bank
  'RBLBNK',
  // AU Small Finance
  'AUSFBL',
  // UPI / Payment platforms
  'PAYTMB', 'PYTMBNK',
  'PHONEPE', 'PHPE',
  'GPAYSC',
  // Credit cards (sometimes a distinct sender)
  'HDFCCC', 'ICICCC', 'SBICARD',
];

/// Lowercased copy for case-insensitive matching.
final List<String> _lowerSenderIds = [
  for (final s in knownBankSenderIds) s.toLowerCase(),
];

/// True if [senderId] corresponds to a known bank/payment sender. The real
/// sender header is decorated (e.g. `VM-HDFCBK-S`); we strip non-alphanumerics
/// and check whether any known token is contained in it.
bool isKnownBankSender(String senderId) {
  final normalized = senderId.toLowerCase().replaceAll(
    RegExp(r'[^a-z0-9]'),
    '',
  );
  if (normalized.isEmpty) return false;
  for (final token in _lowerSenderIds) {
    if (normalized.contains(token)) return true;
  }
  return false;
}
