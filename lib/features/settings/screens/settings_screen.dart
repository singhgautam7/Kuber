import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/isar_service.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return settingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (settings) => ListView(
        padding: const EdgeInsets.only(top: KuberSpacing.xl, bottom: 80),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: KuberSpacing.lg),
            child: Text('Settings', style: textTheme.headlineMedium),
          ),
          const SizedBox(height: KuberSpacing.lg),

          // Theme
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Theme'),
            subtitle: Text(_themeName(settings.themeMode)),
            onTap: () => _showThemePicker(context, ref, settings.themeMode),
          ),

          // Currency
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Currency'),
            subtitle: Text(settings.currency),
            onTap: () => _showCurrencyPicker(context, ref, settings.currency),
          ),

          // Date format
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Date Format'),
            subtitle: Text(settings.dateFormat),
            onTap: () =>
                _showDateFormatPicker(context, ref, settings.dateFormat),
          ),

          const Divider(),

          // Clear all data
          ListTile(
            leading: Icon(Icons.delete_forever, color: colorScheme.error),
            title: Text('Clear All Data',
                style: TextStyle(color: colorScheme.error)),
            subtitle: const Text('This cannot be undone'),
            onTap: () => _showClearDataDialog(context, ref),
          ),

          const Divider(),

          // About
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About Kuber'),
            subtitle: const Text('Version 1.0.0'),
          ),
        ],
      ),
    );
  }

  String _themeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  void _showThemePicker(
      BuildContext context, WidgetRef ref, ThemeMode current) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Theme'),
        children: ThemeMode.values
            .map((m) => SimpleDialogOption(
                  onPressed: () {
                    ref.read(settingsProvider.notifier).setThemeMode(m);
                    Navigator.pop(ctx);
                  },
                  child: Row(
                    children: [
                      Icon(
                        current == m
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: Theme.of(ctx).colorScheme.primary,
                      ),
                      const SizedBox(width: KuberSpacing.md),
                      Text(_themeName(m)),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  void _showCurrencyPicker(
      BuildContext context, WidgetRef ref, String current) {
    final currencies = ['INR', 'USD', 'EUR', 'GBP'];
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Currency'),
        children: currencies
            .map((c) => SimpleDialogOption(
                  onPressed: () {
                    ref.read(settingsProvider.notifier).setCurrency(c);
                    Navigator.pop(ctx);
                  },
                  child: Row(
                    children: [
                      Icon(
                        current == c
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: Theme.of(ctx).colorScheme.primary,
                      ),
                      const SizedBox(width: KuberSpacing.md),
                      Text(c),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  void _showDateFormatPicker(
      BuildContext context, WidgetRef ref, String current) {
    final formats = ['dd/MM/yyyy', 'MM/dd/yyyy'];
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Date Format'),
        children: formats
            .map((f) => SimpleDialogOption(
                  onPressed: () {
                    ref.read(settingsProvider.notifier).setDateFormat(f);
                    Navigator.pop(ctx);
                  },
                  child: Row(
                    children: [
                      Icon(
                        current == f
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: Theme.of(ctx).colorScheme.primary,
                      ),
                      const SizedBox(width: KuberSpacing.md),
                      Text(f),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  void _showClearDataDialog(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all transactions, categories, and accounts. This action cannot be undone.',
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.errorContainer,
              foregroundColor: colorScheme.onErrorContainer,
            ),
            onPressed: () async {
              final isar = ref.read(isarProvider);
              await isar.writeTxn(() => isar.clear());
              await ref.read(settingsProvider.notifier).clearAllData();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );
  }
}
