import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../../tutorial/providers/tutorial_sandbox_provider.dart';
import '../data/sms_account_mapping.dart';

final smsAccountMappingRepositoryProvider =
    Provider<SmsAccountMappingRepository>((ref) {
      return SmsAccountMappingRepository(ref.watch(tutorialAwareIsarProvider));
    });

/// CRUD for the learned sender -> account mappings.
class SmsAccountMappingRepository {
  final Isar isar;
  SmsAccountMappingRepository(this.isar);

  Future<List<SmsAccountMapping>> getAll() {
    return isar.smsAccountMappings.where().findAll();
  }

  Future<SmsAccountMapping?> getForSender(String senderId) {
    return isar.smsAccountMappings
        .filter()
        .senderIdEqualTo(senderId)
        .findFirst();
  }

  /// Increments (or creates) the mapping for [senderId] -> [accountId].
  Future<void> recordMapping(String senderId, String accountId) async {
    await isar.writeTxn(() async {
      final existing = await isar.smsAccountMappings
          .filter()
          .senderIdEqualTo(senderId)
          .findFirst();
      if (existing != null && existing.accountId == accountId) {
        existing.usageCount += 1;
        existing.lastUsed = DateTime.now();
        await isar.smsAccountMappings.put(existing);
      } else {
        // New sender, or the sender now maps to a different account: reset the
        // count so confidence rebuilds against the latest account.
        final mapping = SmsAccountMapping()
          ..senderId = senderId
          ..accountId = accountId
          ..usageCount = (existing != null && existing.accountId == accountId)
              ? existing.usageCount + 1
              : 1
          ..lastUsed = DateTime.now();
        await isar.smsAccountMappings.put(mapping);
      }
    });
  }
}

final smsAccountMappingProvider =
    AsyncNotifierProvider<SmsAccountMappingNotifier, List<SmsAccountMapping>>(
      SmsAccountMappingNotifier.new,
    );

class SmsAccountMappingNotifier extends AsyncNotifier<List<SmsAccountMapping>> {
  @override
  FutureOr<List<SmsAccountMapping>> build() {
    ref.keepAlive();
    return ref.watch(smsAccountMappingRepositoryProvider).getAll();
  }

  /// Best account match learned for [senderId], or null.
  Future<SmsAccountMapping?> getSuggestedAccount(String senderId) {
    return ref
        .read(smsAccountMappingRepositoryProvider)
        .getForSender(senderId);
  }

  Future<void> recordMapping(String senderId, String accountId) async {
    await ref
        .read(smsAccountMappingRepositoryProvider)
        .recordMapping(senderId, accountId);
    ref.invalidateSelf();
  }
}
