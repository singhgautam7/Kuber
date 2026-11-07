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
import '../../more/screens/more_screen.dart' show launchTutorialFromMore;
import '../../pro/settings/kuber_pro_settings_section.dart';
import '../providers/settings_provider.dart';
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
    final cs = Theme.of(context).colorScheme;
    final variant = ref.watch(themeVariantProvider);
    final textLevel = ref.watch(textSizeLevelProvider);
    final locale = ref.watch(localeProvider);
    final language = kSupportedLanguages
        .firstWhere((x) => x.locale.languageCode == locale.languageCode,
            orElse: () => kSupportedLanguages.first)
        .nativeName;
    final currency = ref.watch(currencyProvider);
    final appLock = ref.watch(settingsProvider.select((s) => s.valueOrNull?.biometricsEnabled ?? false));

    Widget row(IconData icon, String title, String subtitle, String route) => SettingsTile(
          icon: icon,
          label: title,
          subtitle: subtitle,
          onTap: () => context.push(route),
          trailing: Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant, size: 20),
        );
    Widget line() => Divider(height: 1, color: cs.outlineVariant);

    return SettingsPageFrame(
      title: l.settingsTitle,
      highlight: widget.highlight,
      children: [
        const SettingsAnchor('pro', child: KuberProSettingsSection()),
        const SizedBox(height: KuberSpace.lg),
        SettingsCard(
          children: [
            SettingsAnchor('name', child: SettingsTile(
              icon: Icons.person_outline_rounded,
              label: l.yourNameLabel,
              onTap: () => _showNameBottomSheet(context),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _userNameController.text.isEmpty ? l.setYourName : _userNameController.text,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(width: KuberSpace.sm),
                  Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant, size: 20),
                ],
              ),
            )),
          ],
        ),
        const SizedBox(height: KuberSpace.lg),
        SettingsCard(
          children: [
            row(Icons.palette_outlined, l.setGroupLook,
                '${themeFamilyName(variant)} · ${textSizeLabel(context, textLevel)}', SettingsArea.look.route),
            line(),
            row(Icons.tune_rounded, l.setGroupPrefs, '$language · ${currency.code}', SettingsArea.prefs.route),
            line(),
            row(Icons.shield_outlined, l.setGroupPrivacy,
                appLock ? l.setPrivacyLockOn : l.setPrivacyLockOff, SettingsArea.privacy.route),
            if (AppDrawerEntries.supported) ...[
              line(),
              row(Icons.apps_rounded, l.appDrawerSection, l.appDrawerDescription, SettingsArea.drawer.route),
            ],
          ],
        ),
        const SizedBox(height: KuberSpace.lg),
        SettingsCard(
          children: [
            row(Icons.storage_rounded, l.setGroupData, l.menuDataDesc, SettingsArea.data.route),
            line(),
            row(Icons.notifications_outlined, l.menuNotifications, l.menuNotificationsDesc,
                SettingsArea.notifications.route),
            line(),
            row(Icons.event_note_outlined, l.setGroupActivity, l.setGroupActivitySub, SettingsArea.activity.route),
          ],
        ),
        const SizedBox(height: KuberSpace.lg),
        SettingsCard(
          children: [
            SettingsAnchor('tutorial', child: SettingsTile(
              icon: Icons.school_rounded,
              label: l.menuTutorial,
              subtitle: l.menuTutorialDesc,
              onTap: () => launchTutorialFromMore(context, ref),
              trailing: Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant, size: 20),
            )),
            line(),
            SettingsAnchor('about', child: SettingsTile(
              icon: Icons.info_outline_rounded,
              label: l.aboutKuberLabel,
              subtitle: l.aboutKuberSubtitle,
              onTap: () => context.push('/more/about'),
              trailing: Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant, size: 20),
            )),
          ],
        ),
      ],
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
