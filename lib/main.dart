import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/database/isar_service.dart';
import 'features/recurring/data/recurring_processor.dart';

final recurringProcessResultProvider = Provider<int>((ref) {
  throw UnimplementedError('Must be overridden in ProviderScope');
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final isar = await IsarService.open();
  final missedCount = await RecurringProcessor(isar).processAll();

  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(isar),
        recurringProcessResultProvider.overrideWithValue(missedCount),
      ],
      child: const KuberApp(),
    ),
  );
}
