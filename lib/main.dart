import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/database/isar_service.dart';
import 'core/database/migrations.dart';
import 'core/database/seed_service.dart';
import 'core/services/notification_service.dart';
import 'features/ledger/data/ledger_reminder_processor.dart';
import 'features/notifications/data/notification_repository.dart';
import 'features/notifications/providers/notification_provider.dart';
import 'features/recurring/data/recurring_processor.dart';

final recurringProcessResultProvider = StateProvider<int>((ref) {
  return 0;
});

class RestartWidget extends StatefulWidget {
  const RestartWidget({super.key, required this.child});

  final Widget child;

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restartApp();
  }

  @override
  State<RestartWidget> createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final isar = await IsarService.open();
  await SeedService().seedInitialData(isar);
  await MigrationService.runAll(isar);

  // NotificationService captures a cold-start payload internally; the
  // foreground-tap callback is wired below. Both eventually land in
  // `pendingDeeplinkProvider` which the dashboard consumes after first frame.
  String? capturedPayload;
  await NotificationService().init(
    onTap: (payload) => capturedPayload = payload,
  );
  // Prefer cold-start payload (set during init) over any captured later.
  final coldStartPayload =
      NotificationService().consumeColdStartPayload() ?? capturedPayload;

  final notificationRepo = NotificationRepository(isar);
  final missedCount = await RecurringProcessor(isar).processAll();

  // On-open ledger reminder pass (in-app + dedupe-gated OS notifications).
  await LedgerReminderProcessor(
    isar: isar,
    notificationRepo: notificationRepo,
    showOs: NotificationService().showAppNotification,
  ).checkAll();

  runApp(
    RestartWidget(
      child: ProviderScope(
        overrides: [
          isarProvider.overrideWithValue(isar),
          recurringProcessResultProvider.overrideWith((ref) => missedCount),
          if (coldStartPayload != null)
            pendingDeeplinkProvider.overrideWith((ref) => coldStartPayload),
        ],
        child: const KuberApp(),
      ),
    ),
  );
}
