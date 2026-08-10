import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/services/biometric_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_info_bottom_sheet.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../settings/widgets/settings_section.dart';
import '../card_info_configs.dart';
import '../data/card_keystore.dart';
import '../providers/kuber_cards_provider.dart';
import '../widgets/cards_secure_scaffold.dart';

class CardsSettingsScreen extends ConsumerStatefulWidget {
  const CardsSettingsScreen({super.key});

  @override
  ConsumerState<CardsSettingsScreen> createState() =>
      _CardsSettingsScreenState();
}

class _CardsSettingsScreenState extends ConsumerState<CardsSettingsScreen> {
  final _biometric = BiometricService();
  bool _biometricAvailable = true;

  @override
  void initState() {
    super.initState();
    _biometric
        .canAuthenticate()
        .then((v) => mounted ? setState(() => _biometricAvailable = v) : null);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final meta = ref.watch(cardVaultMetaProvider).valueOrNull;
    final biometricOn = meta?.biometricEnabled ?? false;

    return CardsSecureScaffold(
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: KuberAppBar(showBack: true, title: 'Kuber Cards settings'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(KuberSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SettingsSectionLabel(label: 'SECURITY'),
              const SettingsSectionDescription(
                  'Control how your cards stay locked.'),
              SettingsCard(
                children: [
                  SettingsTile(
                    icon: Icons.password_rounded,
                    label: 'Change PIN',
                    trailing: Icon(Icons.chevron_right_rounded,
                        size: 20, color: cs.onSurfaceVariant),
                    onTap: () => context.push('/cards/change-pin'),
                  ),
                  Divider(height: 1, color: cs.outline),
                  Opacity(
                    opacity: _biometricAvailable ? 1 : 0.45,
                    child: SettingsTile(
                      icon: Icons.fingerprint_rounded,
                      label: 'Biometric unlock',
                      subtitle: _biometricAvailable
                          ? 'Use your fingerprint or face to unlock'
                          : 'Not available on this device',
                      trailing: Switch(
                        value: biometricOn,
                        onChanged: _biometricAvailable
                            ? (v) => _toggleBiometric(v)
                            : null,
                        activeTrackColor: cs.primary,
                      ),
                    ),
                  ),
                  Divider(height: 1, color: cs.outline),
                  const SettingsTile(
                    icon: Icons.lock_clock_rounded,
                    label: 'Auto-lock',
                    subtitle:
                        'Locks after 60 seconds in the background and on cold start',
                  ),
                ],
              ),
              const SizedBox(height: KuberSpacing.xl),
              const SettingsSectionLabel(label: 'DATA'),
              const SettingsSectionDescription(
                  'Move just your cards, separately from the main backup.'),
              SettingsCard(
                children: [
                  SettingsTile(
                    icon: Icons.ios_share_rounded,
                    label: 'Export cards only',
                    subtitle: 'An encrypted file, separate from your main backup',
                    trailing: Icon(Icons.chevron_right_rounded,
                        size: 20, color: cs.onSurfaceVariant),
                    onTap: _exportCardsOnly,
                  ),
                ],
              ),
              const SizedBox(height: KuberSpacing.xl),
              const SettingsSectionLabel(label: 'ABOUT'),
              const SettingsSectionDescription(
                  'How Kuber Cards protects what you store.'),
              SettingsCard(
                children: [
                  SettingsTile(
                    icon: Icons.lock_rounded,
                    label: 'How encryption works',
                    trailing: Icon(Icons.chevron_right_rounded,
                        size: 20, color: cs.onSurfaceVariant),
                    onTap: () => KuberInfoBottomSheet.show(
                        context, howEncryptionWorksInfo),
                  ),
                  Divider(height: 1, color: cs.outline),
                  SettingsTile(
                    icon: Icons.block_rounded,
                    label: 'What we do not store',
                    trailing: Icon(Icons.chevron_right_rounded,
                        size: 20, color: cs.onSurfaceVariant),
                    onTap: () =>
                        KuberInfoBottomSheet.show(context, whatWeDontStoreInfo),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleBiometric(bool enable) async {
    final service = ref.read(cardVaultServiceProvider);
    if (enable) {
      // The vault is unlocked here, so the session holds the derived key: a
      // biometric check then stores that key (never the PIN). See plan §2.5.
      final key = ref.read(cardSessionProvider).key;
      if (key == null) return;
      final ok = await _biometric.authenticate();
      if (!ok || !mounted) return;
      final stored = await CardKeystore.storeKey(key);
      if (!stored) {
        if (mounted) {
          showKuberSnackBar(context, 'Could not enable biometrics.',
              isError: true);
        }
        return;
      }
      await service.setBiometricEnabled(true);
      ref.invalidate(cardVaultMetaProvider);
      if (mounted) showKuberSnackBar(context, 'Biometric unlock enabled.');
    } else {
      final ok = await _biometric.authenticate();
      if (!ok || !mounted) return;
      await CardKeystore.clear();
      await service.setBiometricEnabled(false);
      ref.invalidate(cardVaultMetaProvider);
      if (mounted) showKuberSnackBar(context, 'Biometric unlock disabled.');
    }
  }

  Future<void> _exportCardsOnly() async {
    final json = await ref.read(cardVaultServiceProvider).exportCardsBundle();
    final bytes = utf8.encode(json);
    final name =
        'kuber_cards_${DateTime.now().toIso8601String().split('T').first}.kcards';
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(bytes, name: name, mimeType: 'application/json'),
        ],
        fileNameOverrides: [name],
      ),
    );
    if (mounted) showKuberSnackBar(context, 'Encrypted card file created.');
  }
}
