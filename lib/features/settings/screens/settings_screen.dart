import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:kuber/core/utils/locale_font.dart';

import '../../../core/services/shortcut_pin_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/supported_locales.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../backups/providers/backup_provider.dart';
import '../../kuber_cards/providers/kuber_cards_provider.dart';
import '../../pro/settings/kuber_pro_settings_section.dart';
import '../providers/settings_provider.dart';
import 'settings_pages.dart';
import '../settings_index.dart';
import '../widgets/settings_anchor.dart';
import '../widgets/settings_section.dart';
import '../widgets/text_size_sheet.dart';

/// Settings: a short list of pages. Each row shows what's inside; the rows
/// themselves live on their page (settings_pages.dart). Subtitles read values
/// already in memory, so this page does no work of its own.
class SettingsScreen extends ConsumerStatefulWidget {
  final String? highlight;
  const SettingsScreen({super.key, this.highlight});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _userNameController;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider).valueOrNull;
    _userNameController = TextEditingController(text: settings?.userName ?? '');
  }

  @override
  void dispose() {
    _userNameController.dispose();
    super.dispose();
  }

  Future<void> _updateName(String name) async {
    await ref.read(settingsProvider.notifier).setUserName(name);
    if (mounted) {
      showKuberSnackBar(context, context.l10n.userNameUpdated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final variant = ref.watch(themeVariantProvider);
    final textLevel = ref.watch(textSizeLevelProvider);
    final locale = ref.watch(localeProvider);
    final language = kSupportedLanguages
        .firstWhere((x) => x.locale.languageCode == locale.languageCode,
            orElse: () => kSupportedLanguages.first)
        .nativeName;
    final currency = ref.watch(currencyProvider);
    final number = ref.watch(settingsProvider.select((s) => s.valueOrNull?.numberSystem ?? NumberSystem.automatic));

    // The rows fed by async values are Consumers: as each value lands only its
    // row rebuilds, not the page.
    Widget group(IconData icon, String title, String subtitle, SettingsArea area, {bool warn = false}) => KuberGroupRow(
          icon: icon,
          title: title,
          subtitle: subtitle,
          warn: warn,
          warnIcon: Icons.notifications_off_outlined,
          onTap: () => context.push(area.route),
        );

    return SettingsOnResume(
      onResume: () => ref.invalidate(notificationsAllowedProvider),
      child: SettingsPageFrame(
      title: l.settingsTitle,
      highlight: widget.highlight,
      children: [
        const SettingsAnchor('pro', child: KuberProSettingsSection()),
        const SizedBox(height: KuberSpace.md),
        SettingsBlock(
          children: [
            SettingsAnchor('name', child: SettingsTile(
              icon: Icons.person_outline_rounded,
              label: l.setYourNameRow,
              onTap: () => _showNameBottomSheet(context),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      _userNameController.text.isEmpty ? l.setYourName : _userNameController.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ),
                  const SizedBox(width: KuberSpace.lg),
                  const KuberChevron(),
                ],
              ),
            )),
          ],
        ),
        SettingsBlock(
          title: l.setSecYours,
          children: [
            group(Icons.palette_outlined, l.setGroupLook,
                l.setLookSub(themeFamilyName(variant), textSizeLabel(context, textLevel)), SettingsArea.look),
            group(Icons.tune_rounded, l.setGroupPrefs,
                l.setPrefsSub(language, '${currency.symbol} ${currency.code}', numberSystemName(l, number)),
                SettingsArea.prefs),
            if (AppDrawerEntries.supported)
              Consumer(
                builder: (_, ref, _) {
                  final drawer = ref.watch(appDrawerEntriesProvider).valueOrNull ?? const <AppDrawerEntry>{};
                  return group(
                    Icons.apps_rounded,
                    l.appDrawerSection,
                    drawer.isEmpty
                        ? l.setDrawerNone
                        : [
                            if (drawer.contains(AppDrawerEntry.cards)) l.appDrawerCards,
                            if (drawer.contains(AppDrawerEntry.notes)) l.appDrawerNotes,
                            if (drawer.contains(AppDrawerEntry.reminders)) l.appDrawerReminders,
                          ].join(', '),
                    SettingsArea.drawer,
                  );
                },
              ),
          ],
        ),
        SettingsBlock(
          title: l.setSecSafe,
          children: [
            Consumer(
              builder: (_, ref, _) {
                final appLock = ref.watch(settingsProvider.select((s) => s.valueOrNull?.biometricsEnabled ?? false));
                final hasPin = ref.watch(hasVaultProvider);
                return group(
                  Icons.shield_outlined,
                  l.setGroupPrivacy,
                  [appLock ? l.setPrivacyLockOn : l.setPrivacyLockOff, if (hasPin) l.setPrivacyPinOn].join(' · '),
                  SettingsArea.privacy,
                );
              },
            ),
            Consumer(
              builder: (_, ref, _) {
                final backup = ref.watch(backupSettingsProvider.select((s) => s.valueOrNull?.lastBackupAt));
                return group(Icons.cloud_sync_rounded, l.setGroupData,
                    backup == null ? l.setNoBackupYet : l.setLastBackupAgo(backupAgo(l, backup)), SettingsArea.data);
              },
            ),
            Consumer(
              builder: (_, ref, _) {
                final off = ref.watch(notificationsAllowedProvider).valueOrNull == false;
                return group(Icons.notifications_outlined, l.menuNotifications, off ? l.setOff : l.setOn,
                    SettingsArea.notifications, warn: off);
              },
            ),
          ],
        ),
        SettingsBlock(
          title: l.setSecHelp,
          children: [
            group(Icons.help_outline_rounded, l.setHelpTitle, l.setHelpSub, SettingsArea.help),
            group(Icons.event_note_outlined, l.setGroupActivity, l.setActivitySub, SettingsArea.activity),
          ],
        ),
        SettingsBlock(
          children: [
            SettingsAnchor('about', child: Consumer(
              builder: (_, ref, _) {
                final version = ref.watch(appVersionProvider).valueOrNull;
                return SettingsTile(
                  icon: Icons.info_outline_rounded,
                  label: l.aboutKuberLabel,
                  subtitle: version == null ? null : l.setVersion(version),
                  onTap: () => context.push('/more/about'),
                  trailing: const KuberChevron(),
                );
              },
            )),
          ],
        ),
      ],
      ),
    );
  }

  void _showNameBottomSheet(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final controller = TextEditingController(text: _userNameController.text);
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(KuberShape.extraLarge),
            ),
            border: Border.all(color: cs.outlineVariant),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: KuberSpace.md),
              Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(KuberShape.full),
                ),
              ),
              const SizedBox(height: KuberSpace.xl),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Text(
                      context.l10n.yourNameLabel,
                      style: localeFont(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: Icon(
                        Icons.close_rounded,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: KuberSpace.lg),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: formKey,
                  child: TextFormField(
                    controller: controller,
                    autofocus: true,
                    maxLength: 15,
                    textCapitalization: TextCapitalization.words,
                    inputFormatters: [TitleCaseInputFormatter()],
                    onChanged: (_) => setSheetState(() {}),
                    style: localeFont(fontSize: 16, color: cs.onSurface),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? context.l10n.nameRequired
                        : null,
                    decoration: InputDecoration(
                      hintText: context.l10n.nameSheetHint,
                      counterText: '${controller.text.length}/15',
                      counterStyle: localeFont(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                      filled: true,
                      fillColor: cs.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(KuberShape.large),
                        borderSide: BorderSide(color: cs.outlineVariant),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(KuberShape.large),
                        borderSide: BorderSide(
                          color: cs.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(KuberShape.large),
                        borderSide: BorderSide(color: cs.primary, width: 1.5),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: KuberSpace.xl),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        final newName = controller.text.trim().toTitleCase();
                        setState(() {
                          _userNameController.text = newName;
                        });
                        _updateName(newName);
                        Navigator.pop(ctx);
                      }
                    },
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(KuberShape.large),
                      ),
                    ),
                    child: Text(
                      context.l10n.doneLabel,
                      style: localeFont(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
