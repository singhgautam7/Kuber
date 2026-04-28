import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../settings/providers/settings_provider.dart';
import '../../dev/widgets/version_tap_detector.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final settings = ref.watch(settingsProvider).valueOrNull;
    final userName = settings?.userName ?? '';

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: KuberAppBar(showBack: true, showHome: true, title: ''),
          ),
          // Header section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About\nKuber',
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
                    'Learn more about the vision, the origin, and the person behind the app.',
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
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Meaning Section
                _AboutCard(
                  title: "What does 'Kuber' mean?",
                  child: Text(
                    "Kuber (or Kubera) is known in Indian mythology as the guardian of wealth and prosperity.\n\n"
                    "He represents not just riches, but the responsibility of managing wealth wisely.\n\n"
                    "Kuber is not about having more. It's about being aware of what you have.",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: cs.onSurface,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: KuberSpacing.xl),

                // What is Kuber
                _AboutCard(
                  title: "What is Kuber?",
                  child: Text(
                    "Kuber is a simple and fast expense tracking app designed to help you stay consistent with your finances without unnecessary complexity.",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: cs.onSurface,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: KuberSpacing.xl),

                // Why Kuber
                _AboutCard(
                  title: "Why Kuber?",
                  child: Column(
                    children: [
                      _BulletPoint(
                        icon: Icons.bolt_rounded,
                        title: "Fast transaction entry",
                        subtitle: "Log expenses in under 3 seconds.",
                      ),
                      const SizedBox(height: KuberSpacing.lg),
                      _BulletPoint(
                        icon: Icons.auto_awesome_mosaic_rounded,
                        title: "Minimal design",
                        subtitle: "Focus on your data, not the interface.",
                      ),
                      const SizedBox(height: KuberSpacing.lg),
                      _BulletPoint(
                        icon: Icons.cloud_off_rounded,
                        title: "Works offline",
                        subtitle: "Full functionality without an active connection.",
                      ),
                      const SizedBox(height: KuberSpacing.lg),
                      _BulletPoint(
                        icon: Icons.repeat_rounded,
                        title: "Built for consistency",
                        subtitle: "Reliable tools for long-term habits.",
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: KuberSpacing.xxl),

                // Letter from Developer
                _DeveloperLetter(userName: userName),
                const SizedBox(height: KuberSpacing.xxl),

                // App Info Section
                VersionTapDetector(
                  child: _AboutCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "App Version",
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: cs.onSurface,
                              ),
                            ),
                            Consumer(
                              builder: (context, ref, _) {
                                final version = ref.watch(appVersionProvider).valueOrNull ?? '1.1.0';
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: cs.surfaceContainerHigh,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: cs.outlineVariant),
                                  ),
                                  child: Text(
                                    "v$version",
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: KuberSpacing.lg),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerLow.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(KuberRadius.sm),
                            border: Border.all(color: cs.outline.withValues(alpha: 0.1)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.lock_outline_rounded,
                                  size: 14, color: cs.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Privacy Note: Your data stays on your device",
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: KuberSpacing.xxl),

                // Footer
                Column(
                  children: [
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: cs.onSurfaceVariant,
                        ),
                        children: [
                          const TextSpan(text: "Made with "),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Icon(
                              Icons.favorite_rounded,
                              color: Colors.redAccent,
                              size: 14,
                            ),
                          ),
                          const TextSpan(text: " in India"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     _FooterLink(label: "Privacy", onTap: () {}),
                    //     _FooterDot(),
                    //     _FooterLink(label: "Terms", onTap: () {}),
                    //     _FooterDot(),
                    //     _FooterLink(label: "Security", onTap: () {}),
                    //   ],
                    // ),
                  ],
                ),
                const SizedBox(height: KuberSpacing.xxl),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  final Widget child;
  final String? title;
  const _AboutCard({required this.child, this.title});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KuberSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: KuberSpacing.lg),
          ],
          child,
        ],
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _BulletPoint({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: cs.primary),
        const SizedBox(width: KuberSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: cs.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DeveloperLetter extends StatelessWidget {
  final String userName;
  const _DeveloperLetter({required this.userName});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final name = userName.isNotEmpty ? userName : "there";

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: KuberSpacing.md),
      padding: const EdgeInsets.fromLTRB(20, 24, 24, 24),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(KuberRadius.md),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 3,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                    children: [
                      const TextSpan(text: "A Letter from the\n"),
                      TextSpan(
                        text: "Developer",
                        style: GoogleFonts.playfairDisplay(
                          fontStyle: FontStyle.italic,
                          color: cs.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  "Hey $name,\n\n"
                  "First of all, thank you for installing Kuber.\n\n"
                  "Finance is one of the hardest things to stay consistent with.\n"
                  "I realized this quite late myself how important it is to simply track where your money goes.\n"
                  "Honestly, just building the habit already puts you ahead of most people.\n\n"
                  "I tried many apps, but none of them truly fit my needs.\n"
                  "Some were too complex, some too slow, some were too fancy to be an expense manager, and some just didn't feel right for everyday use.\n\n"
                  "So I decided to build one.\n\n"
                  "Kuber is designed to be simple, fast, and focused - something you can open, log a transaction in seconds, and move on with your day.\n"
                  "No clutter, no friction. Just clarity.\n\n"
                  "This is my small attempt to make personal finance easier for you.\n\n"
                  "Use it consistently, track every little transaction, and over time, you'll see the difference it makes.\n\n"
                  "Thank you for trusting on something I built with a lot of thoughts and care.",
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: cs.onSurface,
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 16),
                Text.rich(
                  TextSpan(
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                    children: [
                      const TextSpan(text: "- "),
                      TextSpan(
                        text: "Gautam",
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            final uri = Uri.parse("https://singhgautam.com");
                            launchUrl(uri);
                          },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

