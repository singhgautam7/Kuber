import 'package:isar_community/isar.dart';

import '../../../core/database/base_repository.dart';
import 'sms_transaction.dart';

/// Status constants for [SmsTransaction.reviewStatus].
class SmsReviewStatus {
  static const unreviewed = 'unreviewed';
  static const imported = 'imported';
  static const dismissed = 'dismissed';
}

/// Low-level CRUD for the [SmsTransaction] staging collection. All writes go
/// through `isar.writeTxn` per the repository rule.
class SmsImportRepository extends BaseRepository<SmsTransaction> {
  SmsImportRepository(super.isar);

  Future<List<SmsTransaction>> getAll() {
    return isar.smsTransactions.where().sortBySmsDateDesc().findAll();
  }

  Future<List<SmsTransaction>> getByStatus(String status) {
    if (status == SmsReviewStatus.imported) {
      return isar.smsTransactions
          .filter()
          .reviewStatusEqualTo(status)
          .sortByImportedAtDesc()
          .findAll();
    } else {
      return isar.smsTransactions
          .filter()
          .reviewStatusEqualTo(status)
          .sortBySmsDateDesc()
          .findAll();
    }
  }

  Future<SmsTransaction?> getByHash(String hash) {
    return isar.smsTransactions
        .filter()
        .rawSmsHashEqualTo(hash)
        .findFirst();
  }

  Future<SmsTransaction?> getById(int id) => isar.smsTransactions.get(id);

  Future<int> put(SmsTransaction s) {
    return isar.writeTxn(() => isar.smsTransactions.put(s));
  }

  /// Inserts only rows whose hash is not already staged, so re-scanning
  /// resets an existing row's review status. Also checks (senderId, smsDate, parsedAmount) triple.
  Future<int> insertNew(List<SmsTransaction> rows) async {
    if (rows.isEmpty) return 0;
    return isar.writeTxn(() async {
      var inserted = 0;
      for (final row in rows) {
        final existingHash = await isar.smsTransactions
            .filter()
            .rawSmsHashEqualTo(row.rawSmsHash)
            .findFirst();
        if (existingHash != null) continue;

        final existingTriple = await isar.smsTransactions
            .filter()
            .senderIdEqualTo(row.senderId)
            .and()
            .smsDateEqualTo(row.smsDate)
            .and()
            .parsedAmountEqualTo(row.parsedAmount)
            .findFirst();
        if (existingTriple != null) continue;

        await isar.smsTransactions.put(row);
        inserted++;
      }
      return inserted;
    });
  }

  /// Sets [accountId] on every *unreviewed* staged row from [senderId] that
  /// does not already point at it, so once the user picks an account for one
  /// message from a sender, the rest from that sender are pre-filled. Runs in a
  /// single write transaction and only writes the rows that actually change.
  Future<void> applyAccountToUnreviewedSender(
    String senderId,
    String accountId,
  ) async {
    await isar.writeTxn(() async {
      final rows = await isar.smsTransactions
          .filter()
          .reviewStatusEqualTo(SmsReviewStatus.unreviewed)
          .senderIdEqualTo(senderId)
          .findAll();
      final changed = <SmsTransaction>[];
      for (final r in rows) {
        if (r.suggestedAccountId != accountId) {
          r.suggestedAccountId = accountId;
          changed.add(r);
        }
      }
      if (changed.isNotEmpty) await isar.smsTransactions.putAll(changed);
    });
  }

  Future<int> countUnreviewed() {
    return isar.smsTransactions
        .filter()
        .reviewStatusEqualTo(SmsReviewStatus.unreviewed)
        .count();
  }

  Future<void> markImported(
    int id,
    String transactionId, {
    String? accountId,
    String? categoryId,
  }) async {
    await isar.writeTxn(() async {
      final row = await isar.smsTransactions.get(id);
      if (row == null) return;
      row.reviewStatus = SmsReviewStatus.imported;
      row.importedAt = DateTime.now();
      row.importedTransactionId = transactionId;
      // Persist the user's final choices so the reviewed card reflects what was
      // actually imported (not the original, possibly-empty suggestion).
      if (accountId != null) row.suggestedAccountId = accountId;
      if (categoryId != null) row.suggestedCategoryId = categoryId;
      await isar.smsTransactions.put(row);
    });
  }

  Future<void> markDismissed(int id) async {
    await isar.writeTxn(() async {
      final row = await isar.smsTransactions.get(id);
      if (row == null) return;
      row.reviewStatus = SmsReviewStatus.dismissed;
      await isar.smsTransactions.put(row);
    });
  }

  Future<void> markDismissedBatch(List<int> ids) async {
    if (ids.isEmpty) return;
    await isar.writeTxn(() async {
      for (final id in ids) {
        final row = await isar.smsTransactions.get(id);
        if (row == null) continue;
        row.reviewStatus = SmsReviewStatus.dismissed;
        await isar.smsTransactions.put(row);
      }
    });
  }

  Future<void> markUnreviewedBatch(List<int> ids) async {
    if (ids.isEmpty) return;
    await isar.writeTxn(() async {
      for (final id in ids) {
        final row = await isar.smsTransactions.get(id);
        if (row == null) continue;
        row.reviewStatus = SmsReviewStatus.unreviewed;
        await isar.smsTransactions.put(row);
      }
    });
  }

  /// Deletes reviewed (imported / dismissed) rows older than [cutoff].
  /// Unreviewed rows are kept regardless of age.
  Future<void> cleanupOlderThan(DateTime cutoff) async {
    await isar.writeTxn(() async {
      await isar.smsTransactions
          .filter()
          .smsDateLessThan(cutoff)
          .and()
          .group(
            (q) => q
                .reviewStatusEqualTo(SmsReviewStatus.imported)
                .or()
                .reviewStatusEqualTo(SmsReviewStatus.dismissed),
          )
          .deleteAll();
    });
  }

  /// Clears all SMS import transaction entries.
  Future<void> clearAll() async {
    await isar.writeTxn(() => isar.smsTransactions.clear());
  }
}
