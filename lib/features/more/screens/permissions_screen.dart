import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../providers/permission_provider.dart';

class PermissionsScreen extends ConsumerWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final permissionState = ref.watch(permissionProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: const KuberAppBar(showBack: true, title: 'Permissions'),
      body: CustomScrollView(
        slivers: [
          // Page header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Security &\nPermissions',
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                      height: 1.15,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Control how Kuber accesses device features to deliver reminders, exports, and secure access.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: KuberSpacing.lg),
            sliver: permissionState.when(
              data: (state) => SliverList(
                delegate: SliverChildListDelegate([
                  _PermissionCard(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications',
                    description:
                        'Used for reminders, recurring transactions, and export completion updates.',
                    status: state.notifications,
                    onTap: () => ref
                        .read(permissionProvider.notifier)
                        .requestNotification(),
                  ),
                  const SizedBox(height: KuberSpacing.lg),
                  _PermissionCard(
                    icon: Icons.folder_open_rounded,
                    title: 'Storage',
                    description:
                        'Exports (CSV and PDF) are saved to your device under Android/data/com.kuber/files/Kuber/. No storage permission is requested on Android 10 and above. Older devices may see a one-time prompt.',
                    status: state.storage,
                    onTap: () => ref
                        .read(permissionProvider.notifier)
                        .requestStorage(),
                  ),
                  const SizedBox(height: KuberSpacing.lg),
                  _PermissionCard(
                    icon: Icons.fingerprint_rounded,
                    title: 'Biometric Authentication',
                    description: 'Used to secure access to your financial data.',
                    status: state.isBiometricAvailable
                        ? (state.isBiometricEnabled
                            ? AppPermissionStatus.granted
                            : AppPermissionStatus.denied)
                        : AppPermissionStatus.notRequired,
                    statusTextOverride: !state.isBiometricAvailable ? 'NOT AVAILABLE' : null,
                  ),
                  const SizedBox(height: KuberSpacing.xxl),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () => openAppSettings(),
                      icon: const Icon(Icons.settings_outlined, size: 20),
                      label: Text(
                        'Open System Settings',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: cs.outline),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(KuberRadius.md),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: KuberSpacing.xxl),
                ]),
              ),
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => SliverFillRemaining(
                child: Center(child: Text('Error: $err')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final AppPermissionStatus status;
  final String? statusTextOverride;
  final VoidCallback? onTap;

  const _PermissionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.status,
    this.statusTextOverride,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Color badgeColor;
    String badgeText;
    Color onBadgeColor = Colors.white;

    switch (status) {
      case AppPermissionStatus.granted:
        badgeColor = Colors.green.shade600;
        badgeText = statusTextOverride ?? 'GRANTED';
      case AppPermissionStatus.denied:
        badgeColor = cs.surfaceContainerHigh;
        badgeText = statusTextOverride ?? 'NOT GRANTED';
        onBadgeColor = cs.onSurfaceVariant;
      case AppPermissionStatus.notRequired:
        badgeColor = Colors.amber.shade600;
        badgeText = statusTextOverride ?? 'NOT REQUIRED';
    }

    return GestureDetector(
      onTap: status == AppPermissionStatus.denied ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(KuberSpacing.lg),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.lg),
          border: Border.all(color: cs.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(KuberSpacing.sm),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                  ),
                  child: Icon(icon, color: cs.primary, size: 20),
                ),
                const SizedBox(width: KuberSpacing.md),
                Expanded(
                  child: Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(KuberRadius.sm),
                  ),
                  child: Text(
                    badgeText,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: onBadgeColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: KuberSpacing.md),
            Text(
              description,
              style: textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
