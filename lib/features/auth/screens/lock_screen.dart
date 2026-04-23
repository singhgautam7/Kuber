import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../settings/providers/settings_provider.dart';

class LockScreen extends ConsumerStatefulWidget {
  final Widget child;
  const LockScreen({super.key, required this.child});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  bool _hasAutoTriggered = false;

  @override
  void initState() {
    super.initState();
    // Cover the case where authProvider is already true on first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(authProvider) && !_hasAutoTriggered) {
        _hasAutoTriggered = true;
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted && ref.read(authProvider)) {
            ref.read(authProvider.notifier).authenticate();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = ref.watch(authProvider);

    // Fires when _initialize() in AuthNotifier completes async and sets state = true
    ref.listen<bool>(authProvider, (prev, next) {
      if (prev == false && next == true && !_hasAutoTriggered) {
        _hasAutoTriggered = true;
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted && ref.read(authProvider)) {
            ref.read(authProvider.notifier).authenticate();
          }
        });
      }
    });
    final cs = Theme.of(context).colorScheme;
    final currency = ref.watch(currencyProvider);

    if (!isLocked) return widget.child;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // App Logo
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(KuberRadius.md),
              ),
              child: Icon(
                IconMapper.fromCurrencyCode(currency.code),
                color: cs.primary,
                size: 44,
              ),
            ),
            const SizedBox(height: KuberSpacing.lg),
            Text(
              'Kuber',
              style: GoogleFonts.inter(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: KuberSpacing.sm),
            Text(
              'your personal financial log',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: cs.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: () => ref.read(authProvider.notifier).authenticate(),
                icon: const Icon(Icons.lock_open_rounded),
                label: Text(
                  'Unlock to continue',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
