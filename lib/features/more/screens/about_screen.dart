import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
          // SliverToBoxAdapter(
          //   child: Padding(
          //     padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          //     child: Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         Text(
          //           'About Kuber',
          //           style: GoogleFonts.inter(
          //             fontSize: 32,
          //             fontWeight: FontWeight.w800,
          //             color: cs.onSurface,
          //             height: 1.15,
          //             letterSpacing: -0.5,
          //           ),
          //         ),
          //         const SizedBox(height: 6),
          //         Text(
          //           'Learn more about the vision, the origin, and the person behind the app.',
          //           style: GoogleFonts.inter(
          //             fontSize: 13,
          //             color: cs.onSurfaceVariant,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: KuberSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _DeveloperLetter(userName: userName),
                const SizedBox(height: KuberSpacing.xxl),

                // Why Kuber — visual feature grid (no _AboutCard wrapper)
                const _WhyKuberSection(),
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
                const SizedBox(height: KuberSpacing.lg),

                // Send feedback / Rate Kuber
                const _FeedbackCard(),
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

class _WhyKuberSection extends StatelessWidget {
  const _WhyKuberSection();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 14),
          child: Text(
            'WHY KUBER?',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: cs.primary,
            ),
          ),
        ),
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 0.95,
          children: const [
            _WhyKuberFeatureTile(
              icon: Icons.bolt_rounded,
              title: "Fast transaction entry",
              subtitle: "Log expenses in under 3 seconds.",
            ),
            _WhyKuberFeatureTile(
              icon: Icons.auto_awesome_mosaic_rounded,
              title: "Minimal design",
              subtitle: "Focus on your data, not the interface.",
            ),
            _WhyKuberFeatureTile(
              icon: Icons.cloud_off_rounded,
              title: "Works offline",
              subtitle: "Full functionality without an active connection.",
            ),
            _WhyKuberFeatureTile(
              icon: Icons.repeat_rounded,
              title: "Built for consistency",
              subtitle: "Reliable tools for long-term habits.",
            ),
          ],
        ),
      ],
    );
  }
}

class _WhyKuberFeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _WhyKuberFeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Top-aligned gradient overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 64,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      cs.primary.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Disc
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: cs.primary.withValues(alpha: 0.20),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    icon,
                    size: 20,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                    height: 1.25,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: cs.onSurfaceVariant,
                      height: 1.45,
                    ),
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

class _DeveloperLetter extends StatelessWidget {
  final String userName;
  const _DeveloperLetter({required this.userName});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final name = userName.isNotEmpty ? userName : "there";

    final textStyleRegular = GoogleFonts.inter(
      fontSize: 15,
      height: 1.75,
      color: cs.onSurface,
      letterSpacing: -0.1,
    );
    final textStyleSemiBold = textStyleRegular.copyWith(
      fontWeight: FontWeight.w600,
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.primary.withValues(alpha: 0.20)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            cs.primary.withValues(alpha: 0.10),
            cs.primary.withValues(alpha: 0.03),
            cs.surfaceContainer,
            cs.surfaceContainer,
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Watermark quote glyph
          Positioned(
            top: 14,
            right: 22,
            child: IgnorePointer(
              child: Text(
                "\u201C",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 92,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w700,
                  color: cs.primary.withValues(alpha: 0.18),
                  height: 1.0,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Eyebrow
                Text(
                  "A NOTE FROM THE MAKER",
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                // Title
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                      letterSpacing: -0.7,
                      height: 1.1,
                    ),
                    children: [
                      const TextSpan(text: "A Letter from the\n"),
                      TextSpan(
                        text: "Developer",
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 38,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w700,
                          color: cs.primary,
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                // Body text
                Text.rich(
                  TextSpan(
                    style: textStyleRegular,
                    children: [
                      TextSpan(text: "Hey $name,\n\n", style: textStyleSemiBold),
                      const TextSpan(
                        text: "First of all, thank you for installing Kuber.\n\n"
                              "Finance is one of the hardest things to stay consistent with.\n"
                              "I realized this quite late myself how important it is to simply track where your money goes.\n"
                              "Honestly, just building the habit already puts you ahead of most people.\n\n"
                              "I tried many apps, but none of them truly fit my needs.\n"
                              "Some were too complex, some too slow, some were too fancy to be an expense manager, and some just didn't feel right for everyday use.\n\n",
                      ),
                      TextSpan(text: "So I decided to build one.\n\n", style: textStyleSemiBold),
                      const TextSpan(
                        text: "Kuber is designed to be simple, fast, and focused - something you can open, log a transaction in seconds, and move on with your day.\n"
                              "No clutter, no friction. Just clarity.\n\n"
                              "This is my small attempt to make personal finance easier for you.\n\n"
                              "Use it consistently, track every little transaction, and over time, you'll see the difference it makes.\n\n"
                              "Thank you for trusting on something I built with a lot of thoughts and care.",
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                // Signature Card
                Material(
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: cs.outline),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        final uri = Uri.parse("https://singhgautam.com");
                        launchUrl(uri);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Top Row
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                // Avatar Disc
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        cs.primary,
                                        cs.primary.withValues(alpha: 0.67),
                                      ],
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    "GS",
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Signature Column
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "SIGNED",
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: cs.onSurfaceVariant,
                                          letterSpacing: 0.4,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              "Gautam",
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.playfairDisplay(
                                                fontStyle: FontStyle.italic,
                                                fontSize: 22,
                                                fontWeight: FontWeight.w700,
                                                color: cs.onSurface,
                                                letterSpacing: -0.3,
                                                decoration: TextDecoration.underline,
                                                decorationColor: cs.primary.withValues(alpha: 0.44),
                                                decorationStyle: TextDecorationStyle.solid,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          // Icon(
                                          //   Icons.arrow_outward_rounded,
                                          //   size: 14,
                                          //   color: cs.primary,
                                          // ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Separator Border
                          Container(
                            height: 1,
                            color: cs.outline,
                          ),
                          // URL Footer Row
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            color: cs.surfaceContainerHigh,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "singhgautam.com",
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: cs.onSurfaceVariant,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "VISIT",
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: cs.primary,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_outward_rounded,
                                      size: 12,
                                      color: cs.primary,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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

class _FeedbackTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _FeedbackTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          children: [
            // Squircle Icon
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: cs.outline),
              ),
              child: Icon(
                icon,
                size: 18,
                color: cs.primary,
              ),
            ),
            const SizedBox(width: 12),
            // Text Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w400,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Chevron
            Opacity(
              opacity: 0.6,
              child: Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        children: [
          _FeedbackTile(
            icon: Icons.mode_comment_outlined,
            label: "Send feedback",
            subtitle: "Suggestions, bugs, or just to say hi",
            onTap: () => context.push('/more/feedback'),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: cs.outline,
            indent: 16,
            endIndent: 16,
          ),
          _FeedbackTile(
            icon: Icons.star_outline_rounded,
            label: "Rate Kuber",
            subtitle: "Help others discover the app",
            onTap: () {
              launchUrl(
                Uri.parse('https://play.google.com/store/apps/details?id=com.grs.kuber'),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
        ],
      ),
    );
  }
}
