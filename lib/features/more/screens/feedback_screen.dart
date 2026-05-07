import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_page_header.dart';
import '../../settings/providers/settings_provider.dart';

const _feedbackTypes = ['Bug', 'New Feature Request', 'General Feedback'];

class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  String _selectedType = _feedbackTypes.first;
  final _feedbackCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _feedbackCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final feedbackText = _feedbackCtrl.text.trim();
    if (feedbackText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your feedback before submitting.')),
      );
      return;
    }

    // Capture context-dependent values before async gaps
    final size = MediaQuery.of(context).size;
    final screenSize = '${size.width.toInt()} x ${size.height.toInt()}';
    final settings = ref.read(settingsProvider).valueOrNull;
    final currency = ref.read(currencyProvider);

    setState(() => _isSubmitting = true);

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final deviceInfo = DeviceInfoPlugin();

      String deviceModel = 'Unknown';
      String osVersion = 'Unknown';

      if (Platform.isAndroid) {
        final android = await deviceInfo.androidInfo;
        deviceModel = '${android.manufacturer} ${android.model}';
        osVersion = 'Android ${android.version.release} (SDK ${android.version.sdkInt})';
      } else if (Platform.isIOS) {
        final ios = await deviceInfo.iosInfo;
        deviceModel = ios.model;
        osVersion = 'iOS ${ios.systemVersion}';
      }

      final subject = '[Kuber Feedback] $_selectedType';
      final body = '''
Type: $_selectedType

Feedback:
$feedbackText

---
Device Info
-----------
App Version : ${packageInfo.version} (${packageInfo.buildNumber})
Device      : $deviceModel
OS          : $osVersion
Screen Size : $screenSize
User Name   : ${settings?.userName.isNotEmpty == true ? settings!.userName : 'Not set'}
Currency    : ${currency.name} (${currency.code})
''';

      // Build mailto URI manually — Uri(queryParameters:) encodes spaces as +
      // which mail clients render literally. Uri.encodeComponent uses %20 instead.
      final uri = Uri.parse(
        'mailto:singhgautam.dev@gmail.com'
        '?subject=${Uri.encodeComponent(subject)}'
        '&body=${Uri.encodeComponent(body)}',
      );

      if (!await launchUrl(uri)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open mail app. Please try again.')),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: KuberAppBar(showBack: true, showHome: true, title: ''),
          ),
          const SliverToBoxAdapter(
            child: KuberPageHeader(
              title: 'Feedback',
              description: 'Help us make Kuber better for you',
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              KuberSpacing.lg,
              0,
              KuberSpacing.lg,
              KuberSpacing.xl,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Type label
                Text(
                  'TYPE',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurfaceVariant,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: KuberSpacing.sm),

                // Type dropdown
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: KuberSpacing.lg,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainer,
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                    border: Border.all(color: cs.outline),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedType,
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    dropdownColor: cs.surfaceContainerHigh,
                    style: tt.bodyLarge?.copyWith(color: cs.onSurface),
                    items: _feedbackTypes
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedType = v);
                    },
                  ),
                ),

                const SizedBox(height: KuberSpacing.xl),

                // Feedback label
                Text(
                  'YOUR FEEDBACK',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurfaceVariant,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: KuberSpacing.sm),

                // Feedback text area
                TextField(
                  controller: _feedbackCtrl,
                  minLines: 4,
                  maxLines: 8,
                  style: tt.bodyLarge?.copyWith(color: cs.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Describe your feedback here...',
                    hintStyle: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
                    filled: true,
                    fillColor: cs.surfaceContainer,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(KuberRadius.md),
                      borderSide: BorderSide(color: cs.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(KuberRadius.md),
                      borderSide: BorderSide(color: cs.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(KuberRadius.md),
                      borderSide: BorderSide(color: cs.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.all(KuberSpacing.lg),
                  ),
                ),

                const SizedBox(height: KuberSpacing.xl),

                // Privacy note
                Container(
                  padding: const EdgeInsets.all(KuberSpacing.md),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: KuberSpacing.sm),
                      Expanded(
                        child: Text(
                          'When you submit, a few basic device details (like model, OS version, app version, and your in-app name) will be included to help us better understand and resolve your feedback.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: cs.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: KuberSpacing.lg),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(KuberRadius.md),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            'SUBMIT',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
