/// Regex-based extraction rules for Indian bank / UPI transaction SMS.
///
/// Each [SmsPattern] knows how to pull amount, type, account suffix, merchant
/// and date out of a matched message. Patterns are tried in [bankPatterns]
/// order and the first one whose [regex] matches wins, so more specific rules
/// (e.g. HDFC UPI) must come before generic fallbacks.
library;

/// A single SMS extraction rule.
class SmsPattern {
  final String name; // e.g. "HDFC debit (UPI)"
  final RegExp regex;
  final double Function(RegExpMatch) extractAmount;
  // 'expense' | 'income' | null (null = direction undetermined, skip).
  final String? Function(RegExpMatch) extractType;
  final String? Function(RegExpMatch)? extractAccountSuffix;
  final String? Function(RegExpMatch)? extractMerchant;
  final DateTime? Function(RegExpMatch)? extractDate;

  const SmsPattern({
    required this.name,
    required this.regex,
    required this.extractAmount,
    required this.extractType,
    this.extractAccountSuffix,
    this.extractMerchant,
    this.extractDate,
  });
}

// ── Shared helpers ──────────────────────────────────────────────────────────

/// Strips currency symbols, the words INR/Rs and thousands separators from
/// [raw] and parses the remainder as a double. Returns 0 on failure.
double parseAmount(String raw) {
  final cleaned = raw
      .replaceAll(RegExp(r'inr|rs\.?|₹', caseSensitive: false), '')
      .replaceAll(',', '')
      .trim();
  return double.tryParse(cleaned) ?? 0;
}

/// Words that mark money leaving the account, and money coming in.
const _debitWords = [
  'debited', 'debit', 'spent', 'paid', 'withdrawn', 'purchase', 'deducted',
  'sent',
];
const _creditWords = [
  'credited', 'credit', 'received', 'deposited', 'refund', 'added',
];

/// Decides direction by the *earliest* transaction keyword in [body]. Many bank
/// SMS contain both "debited" and "credited" (e.g. "X debited; Y credited") so
/// the word that appears first wins. Returns null when no keyword is present
/// (the message is not a transaction).
String? inferTypeFromBody(String body) {
  final lower = body.toLowerCase();
  int earliest(List<String> words) {
    var min = -1;
    for (final w in words) {
      final i = lower.indexOf(w);
      if (i >= 0 && (min < 0 || i < min)) min = i;
    }
    return min;
  }

  final d = earliest(_debitWords);
  final c = earliest(_creditWords);
  if (d < 0 && c < 0) return null;
  if (d < 0) return 'income';
  if (c < 0) return 'expense';
  return d <= c ? 'expense' : 'income';
}

const _months = {
  'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
  'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
};

/// Parses the common Indian bank SMS date formats into a [DateTime], or null
/// if unrecognised (caller then falls back to the SMS timestamp). Handles:
/// `28-May-26`, `28-May-2026`, `01/06/2026`, `01-06-2026`, `Jun 01`,
/// `01 Jun 2026`.
DateTime? parseSmsDate(String? raw, {DateTime? now}) {
  if (raw == null) return null;
  final s = raw.trim();
  if (s.isEmpty) return null;
  final ref = now ?? DateTime.now();

  // DD-Mon-YY / DD-Mon-YYYY  (separators - / space)
  final dMonY = RegExp(
    r'^(\d{1,2})[-\s]([A-Za-z]{3})[A-Za-z]*[-\s](\d{2,4})$',
  ).firstMatch(s);
  if (dMonY != null) {
    final day = int.parse(dMonY.group(1)!);
    final month = _months[dMonY.group(2)!.toLowerCase()];
    var year = int.parse(dMonY.group(3)!);
    if (month != null) {
      if (year < 100) year += 2000;
      return DateTime(year, month, day);
    }
  }

  // DD Mon YYYY
  final dMonFullY = RegExp(
    r'^(\d{1,2})\s+([A-Za-z]{3})[A-Za-z]*\s+(\d{4})$',
  ).firstMatch(s);
  if (dMonFullY != null) {
    final day = int.parse(dMonFullY.group(1)!);
    final month = _months[dMonFullY.group(2)!.toLowerCase()];
    final year = int.parse(dMonFullY.group(3)!);
    if (month != null) return DateTime(year, month, day);
  }

  // Mon DD  (no year -> assume reference year)
  final monD = RegExp(r'^([A-Za-z]{3})[A-Za-z]*\s+(\d{1,2})$').firstMatch(s);
  if (monD != null) {
    final month = _months[monD.group(1)!.toLowerCase()];
    final day = int.parse(monD.group(2)!);
    if (month != null) return DateTime(ref.year, month, day);
  }

  // DD/MM/YYYY or DD-MM-YYYY (numeric)
  final numeric = RegExp(
    r'^(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})$',
  ).firstMatch(s);
  if (numeric != null) {
    final day = int.parse(numeric.group(1)!);
    final month = int.parse(numeric.group(2)!);
    var year = int.parse(numeric.group(3)!);
    if (year < 100) year += 2000;
    if (month >= 1 && month <= 12 && day >= 1 && day <= 31) {
      return DateTime(year, month, day);
    }
  }

  return null;
}

/// Best-effort merchant extraction from a UPI / POS style body. Tries, in
/// order: `to VPA name@bank`, `to NAME`, `at MERCHANT`, `from NAME`. Returns
/// a trimmed, title-ish merchant string or null.
String? extractMerchantFrom(String body) {
  // to VPA swiggy@hdfc  ->  swiggy
  final vpa = RegExp(
    r'(?:to|VPA|to VPA)\s+([A-Za-z0-9._-]+)@[A-Za-z]+',
    caseSensitive: false,
  ).firstMatch(body);
  if (vpa != null) return _clean(vpa.group(1));

  // at MERCHANT NAME  (POS)
  final at = RegExp(
    r'\bat\s+([A-Za-z0-9&._\s]{2,30}?)(?:\s+on\b|\.|,|$)',
    caseSensitive: false,
  ).firstMatch(body);
  if (at != null) return _clean(at.group(1));

  // to MERCHANT NAME
  final to = RegExp(
    r'\bto\s+([A-Za-z0-9&._\s]{2,30}?)(?:\s+on\b|\.|,|$)',
    caseSensitive: false,
  ).firstMatch(body);
  if (to != null) return _clean(to.group(1));

  // from NAME (credits)
  final from = RegExp(
    r'\bfrom\s+([A-Za-z0-9&._\s]{2,30}?)(?:\s+on\b|\.|,|$)',
    caseSensitive: false,
  ).firstMatch(body);
  if (from != null) return _clean(from.group(1));

  return null;
}

String? _clean(String? raw) {
  if (raw == null) return null;
  final t = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
  // Drop obviously non-merchant tails like account refs.
  if (t.isEmpty || RegExp(r'^[0-9X*]+$').hasMatch(t)) return null;
  return t;
}

// Reusable sub-expressions.
const _amount = r'(?:INR|Rs\.?|₹)\s*([\d,]+(?:\.\d{1,2})?)';
const _amountLoose = r'(?:INR|Rs\.?|₹)\s*([\d,]+(?:\.\d{1,2})?)';
const _suffix = r'(?:A/?c|Acct|Account|card)(?:\s*(?:no\.?|number))?\s*[Xx*]*(\d{3,4})';
const _date = r'(\d{1,2}[-\s][A-Za-z]{3}[-\s]\d{2,4}|\d{1,2}[/-]\d{1,2}[/-]\d{2,4})';

// ── Patterns (order matters: specific first) ────────────────────────────────

final List<SmsPattern> bankPatterns = [
  // 10. UPI debit — "Paid Rs.X to NAME via PhonePe/GPay/Paytm"
  SmsPattern(
    name: 'UPI debit',
    regex: RegExp(
      r'(?:paid|sent)\s+' +
          _amountLoose +
          r'.*?(?:to)\s+([A-Za-z0-9._@-]{2,40}).*?(?:via|using|through)\s+(?:phonepe|gpay|google pay|paytm|bhim|upi)',
      caseSensitive: false,
      dotAll: true,
    ),
    extractAmount: (m) => parseAmount(m.group(1)!),
    extractType: (_) => 'expense',
    extractMerchant: (m) => extractMerchantFrom(m.input),
    extractDate: (m) {
      final d = RegExp(_date).firstMatch(m.input);
      return parseSmsDate(d?.group(1));
    },
  ),

  // 11. UPI credit — "Received Rs.X from NAME"
  SmsPattern(
    name: 'UPI credit',
    regex: RegExp(
      r'received\s+' + _amountLoose + r'.*?from\s+([A-Za-z0-9._@-]{2,40})',
      caseSensitive: false,
      dotAll: true,
    ),
    extractAmount: (m) => parseAmount(m.group(1)!),
    extractType: (_) => 'income',
    extractMerchant: (m) => extractMerchantFrom(m.input),
    extractDate: (m) {
      final d = RegExp(_date).firstMatch(m.input);
      return parseSmsDate(d?.group(1));
    },
  ),

  // 1. HDFC debit (also covers HDFC UPI debit) —
  //    "INR X debited from A/c XXNNNN on DD-Mon-YY [to VPA name@bank]"
  SmsPattern(
    name: 'HDFC debit',
    regex: RegExp(
      _amount + r'\s+debited\s+from\s+' + _suffix + r'\s+on\s+' + _date,
      caseSensitive: false,
    ),
    extractAmount: (m) => parseAmount(m.group(1)!),
    extractType: (_) => 'expense',
    extractAccountSuffix: (m) => m.group(2),
    extractDate: (m) => parseSmsDate(m.group(3)),
    extractMerchant: (m) => extractMerchantFrom(m.input),
  ),

  // 2. HDFC credit —
  //    "INR X credited to A/c XXNNNN on DD-Mon-YY"
  SmsPattern(
    name: 'HDFC credit',
    regex: RegExp(
      _amount + r'\s+credited\s+to\s+' + _suffix + r'\s+on\s+' + _date,
      caseSensitive: false,
    ),
    extractAmount: (m) => parseAmount(m.group(1)!),
    extractType: (_) => 'income',
    extractAccountSuffix: (m) => m.group(2),
    extractDate: (m) => parseSmsDate(m.group(3)),
    extractMerchant: (m) => extractMerchantFrom(m.input),
  ),

  // 3. SBI debit — "Rs.X debited from SBI A/c XXXXNNNN"
  SmsPattern(
    name: 'SBI debit',
    regex: RegExp(
      _amount + r'\s+debited\s+from\s+(?:SBI\s+)?' + _suffix,
      caseSensitive: false,
    ),
    extractAmount: (m) => parseAmount(m.group(1)!),
    extractType: (_) => 'expense',
    extractAccountSuffix: (m) => m.group(2),
    extractDate: (m) {
      final d = RegExp(_date).firstMatch(m.input);
      return parseSmsDate(d?.group(1));
    },
    extractMerchant: (m) => extractMerchantFrom(m.input),
  ),

  // 4. SBI credit — "Rs.X credited to SBI A/c XXXXNNNN"
  SmsPattern(
    name: 'SBI credit',
    regex: RegExp(
      _amount + r'\s+credited\s+to\s+(?:SBI\s+)?' + _suffix,
      caseSensitive: false,
    ),
    extractAmount: (m) => parseAmount(m.group(1)!),
    extractType: (_) => 'income',
    extractAccountSuffix: (m) => m.group(2),
    extractDate: (m) {
      final d = RegExp(_date).firstMatch(m.input);
      return parseSmsDate(d?.group(1));
    },
    extractMerchant: (m) => extractMerchantFrom(m.input),
  ),

  // 5. ICICI — "ICICI Bank A/c XXNNNN: Rs X debited/credited"
  SmsPattern(
    name: 'ICICI',
    regex: RegExp(
      r'ICICI\s+Bank\s+' +
          _suffix +
          r'[^.]*?' +
          _amount +
          r'\s+(debited|credited|spent|received)',
      caseSensitive: false,
    ),
    extractAmount: (m) => parseAmount(m.group(2)!),
    extractType: (m) {
      final verb = m.group(3)!.toLowerCase();
      return (verb == 'credited' || verb == 'received') ? 'income' : 'expense';
    },
    extractAccountSuffix: (m) => m.group(1),
    extractDate: (m) {
      final d = RegExp(_date).firstMatch(m.input);
      return parseSmsDate(d?.group(1));
    },
    extractMerchant: (m) => extractMerchantFrom(m.input),
  ),

  // 6. Axis — "INR X debited from Axis Bank A/c NNNN"
  SmsPattern(
    name: 'Axis',
    regex: RegExp(
      _amount +
          r'\s+(debited|credited)\s+(?:from|to)\s+Axis\s+Bank\s+' +
          _suffix,
      caseSensitive: false,
    ),
    extractAmount: (m) => parseAmount(m.group(1)!),
    extractType: (m) =>
        m.group(2)!.toLowerCase() == 'credited' ? 'income' : 'expense',
    extractAccountSuffix: (m) => m.group(3),
    extractDate: (m) {
      final d = RegExp(_date).firstMatch(m.input);
      return parseSmsDate(d?.group(1));
    },
    extractMerchant: (m) => extractMerchantFrom(m.input),
  ),

  // 7. Kotak — "Kotak Mahindra Bank: Rs.X debited/credited"
  SmsPattern(
    name: 'Kotak',
    regex: RegExp(
      r'Kotak[^.]*?' + _amount + r'\s+(debited|credited)',
      caseSensitive: false,
    ),
    extractAmount: (m) => parseAmount(m.group(1)!),
    extractType: (m) =>
        m.group(2)!.toLowerCase() == 'credited' ? 'income' : 'expense',
    extractAccountSuffix: (m) {
      final s = RegExp(_suffix, caseSensitive: false).firstMatch(m.input);
      return s?.group(1);
    },
    extractDate: (m) {
      final d = RegExp(_date).firstMatch(m.input);
      return parseSmsDate(d?.group(1));
    },
    extractMerchant: (m) => extractMerchantFrom(m.input),
  ),

  // 8. Generic catch-all — the first currency amount in the message, with the
  //    direction inferred from the earliest debit/credit keyword. Covers
  //    formats the specific rules miss (e.g. "spent using ... Card",
  //    "debited for Rs X ... credited" where the amount follows the verb).
  //    Returns null type (skipped) when no transaction keyword is present.
  SmsPattern(
    name: 'Generic',
    regex: RegExp(_amount, caseSensitive: false),
    extractAmount: (m) => parseAmount(m.group(1)!),
    extractType: (m) => inferTypeFromBody(m.input),
    extractAccountSuffix: (m) {
      final s = RegExp(_suffix, caseSensitive: false).firstMatch(m.input);
      return s?.group(1);
    },
    extractDate: (m) {
      final d = RegExp(_date).firstMatch(m.input);
      return parseSmsDate(d?.group(1));
    },
    extractMerchant: (m) => extractMerchantFrom(m.input),
  ),
];
