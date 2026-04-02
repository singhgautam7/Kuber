import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/database/isar_service.dart';
import 'core/database/seed_service.dart';
import 'core/services/notification_service.dart';
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
  await NotificationService().init();
  final missedCount = await RecurringProcessor(isar).processAll();

  runApp(
    RestartWidget(
      child: ProviderScope(
        overrides: [
          isarProvider.overrideWithValue(isar),
          recurringProcessResultProvider.overrideWith((ref) => missedCount),
        ],
        child: const KuberApp(),
      ),
    ),
  );
}
