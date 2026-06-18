import 'sms_parser.dart';

/// Minimal view of a Kuber account the matcher needs. Keeping this a plain
/// value type (no Isar / Flutter) lets the matcher be unit-tested in isolation.
class MatchableAccount {
  final String id;
  final String name;
  final String? last4;

  const MatchableAccount({required this.id, required this.name, this.last4});
}

/// A learned sender -> account association.
class LearnedMapping {
  final String accountId;
  final int usageCount;

  const LearnedMapping({required this.accountId, required this.usageCount});
}

/// Outcome of account matching.
class AccountMatch {
  /// The single best account id, or null when ambiguous / no match.
  final String? accountId;

  /// True when the match is confident enough to auto-fill the review sheet
  /// (a unique suffix hit, or a learned mapping used >= 3 times).
  final bool autoSelected;

  /// When more than one account shares the parsed suffix, all of them.
  final List<String> candidateIds;

  /// How the match was made, for debugging / the learned-mapping banner.
  final AccountMatchSource source;

  const AccountMatch({
    this.accountId,
    this.autoSelected = false,
    this.candidateIds = const [],
    this.source = AccountMatchSource.none,
  });
}

enum AccountMatchSource { suffix, learned, name, none }

/// Resolves the Kuber account for a parsed SMS using three strategies, in
/// priority order: account-number suffix, learned sender mapping, then a fuzzy
/// sender-name match.
class AccountMatcher {
  const AccountMatcher();

  AccountMatch match(
    SmsParseResult result,
    List<MatchableAccount> accounts, {
    LearnedMapping? learnedForSender,
  }) {
    // 1. Suffix match.
    final suffix = result.accountSuffix;
    if (suffix != null && suffix.isNotEmpty) {
      final hits = accounts
          .where((a) => a.last4 != null && a.last4 == suffix)
          .toList();
      if (hits.length == 1) {
        return AccountMatch(
          accountId: hits.first.id,
          autoSelected: true,
          source: AccountMatchSource.suffix,
        );
      }
      if (hits.length > 1) {
        // Ambiguous: surface candidates but leave the user to pick.
        return AccountMatch(
          candidateIds: hits.map((a) => a.id).toList(),
          source: AccountMatchSource.suffix,
        );
      }
    }

    // 2. Learned mapping.
    if (learnedForSender != null) {
      final exists = accounts.any((a) => a.id == learnedForSender.accountId);
      if (exists) {
        return AccountMatch(
          accountId: learnedForSender.accountId,
          autoSelected: learnedForSender.usageCount >= 3,
          source: AccountMatchSource.learned,
        );
      }
    }

    // 3. Fuzzy name match: a known bank token from the sender appearing in an
    // account name (e.g. sender "VM-HDFCBK" -> account "HDFC Savings").
    final senderNorm = result.senderId.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]'),
      '',
    );
    if (senderNorm.isNotEmpty) {
      for (final a in accounts) {
        final accNorm = a.name.toLowerCase().replaceAll(
          RegExp(r'[^a-z0-9]'),
          '',
        );
        if (accNorm.isEmpty) continue;
        // Use the first word of the account name as the token to test.
        final firstWord = a.name.trim().split(RegExp(r'\s+')).first.toLowerCase();
        if (firstWord.length >= 3 && senderNorm.contains(firstWord)) {
          return AccountMatch(
            accountId: a.id,
            source: AccountMatchSource.name,
          );
        }
      }
    }

    // 4. No match.
    return const AccountMatch();
  }
}
