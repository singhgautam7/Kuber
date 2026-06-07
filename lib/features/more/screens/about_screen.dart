import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../core/constants/about_l10n.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../settings/providers/settings_provider.dart';
import '../../dev/widgets/version_tap_detector.dart';
import '../widgets/about_sections.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final settings = ref.watch(settingsProvider).valueOrNull;
    final userName = settings?.userName ?? '';
    final lang = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: KuberAppBar(showBack: true, showHome: true, title: ''),
          ),

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
                const AboutWhatIsKuberSection(),
                const SizedBox(height: KuberSpacing.xl),

                // Meaning Section
                const AboutKuberMeaningSection(),
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
                              abL10n("App Version", lang),
                              style: localeFont(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: cs.onSurface,
                              ),
                            ),
                            Consumer(
                              builder: (context, ref, _) {
                                final version =
                                    ref.watch(appVersionProvider).valueOrNull ??
                                    '1.1.0';
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: cs.surfaceContainerHigh,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: cs.outlineVariant,
                                    ),
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
                            color: cs.surfaceContainerLow.withValues(
                              alpha: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(KuberRadius.sm),
                            border: Border.all(
                              color: cs.outline.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                  Icons.lock_outline_rounded,
                                  size: 14,
                                  color: cs.primary,
                                ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  abL10n("Privacy Note: Your data stays on your device", lang),
                                  style: localeFont(
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
                const Column(
                  children: [
                    _MadeInIndiaFooter(),
                  ],
                ),
                SizedBox(height: KuberSpacing.xxl + systemNavBarInset(context)),
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
  const _AboutCard({required this.child});

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
        children: [child],
      ),
    );
  }
}

class _WhyKuberSection extends StatelessWidget {
  const _WhyKuberSection();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final lang = Localizations.localeOf(context).languageCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 14),
          child: Text(
            abL10n('WHY KUBER?', lang).toUpperCase(),
            style: localeFont(
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
          children: [
            _WhyKuberFeatureTile(
              icon: Icons.bolt_rounded,
              title: abL10n("Fast transaction entry", lang),
              subtitle: abL10n("Log expenses in under 3 seconds.", lang),
            ),
            _WhyKuberFeatureTile(
              icon: Icons.auto_awesome_mosaic_rounded,
              title: abL10n("Minimal design", lang),
              subtitle: abL10n("Focus on your data, not the interface.", lang),
            ),
            _WhyKuberFeatureTile(
              icon: Icons.cloud_off_rounded,
              title: abL10n("Works offline", lang),
              subtitle: abL10n("Full functionality without an active connection.", lang),
            ),
            _WhyKuberFeatureTile(
              icon: Icons.repeat_rounded,
              title: abL10n("Built for consistency", lang),
              subtitle: abL10n("Reliable tools for long-term habits.", lang),
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
                  child: Icon(icon, size: 20, color: cs.primary),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: localeFont(
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
                    style: localeFont(
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
    final lang = Localizations.localeOf(context).languageCode;
    final name = userName.isNotEmpty ? userName : "";

    final textStyleRegular = localeFont(
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
                  abL10n("A NOTE FROM THE MAKER", lang),
                  style: localeFont(
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
                    style: localeFont(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                      letterSpacing: -0.7,
                      height: 1.1,
                    ),
                    children: [
                      TextSpan(text: "${abL10n('A Letter from the', lang)}\n"),
                      TextSpan(
                        text: abL10n('Developer', lang),
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
                      TextSpan(
                        text: name.isNotEmpty
                            ? abL10n("Hey {name},", lang).replaceAll("{name}", name) + "\n\n"
                            : abL10n("Hey there,", lang) + "\n\n",
                        style: textStyleSemiBold,
                      ),
                      TextSpan(
                        text: abL10n('dev_letter_p1', lang) + "\n\n",
                      ),
                      TextSpan(
                        text: abL10n('dev_letter_p2', lang) + "\n\n",
                      ),
                      TextSpan(
                        text: abL10n('dev_letter_p3', lang) + "\n\n",
                        style: textStyleSemiBold,
                      ),
                      TextSpan(
                        text: abL10n('dev_letter_p4', lang),
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
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
                                    style: localeFont(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        abL10n("SIGNED", lang),
                                        style: localeFont(
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
                                              style:
                                                  GoogleFonts.playfairDisplay(
                                                    fontStyle: FontStyle.italic,
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.w700,
                                                    color: cs.onSurface,
                                                    letterSpacing: -0.3,
                                                    decoration: TextDecoration
                                                        .underline,
                                                    decorationColor: cs.primary
                                                        .withValues(
                                                          alpha: 0.44,
                                                        ),
                                                    decorationStyle:
                                                        TextDecorationStyle
                                                            .solid,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Separator Border
                          Container(height: 1, color: cs.outline),
                          // URL Footer Row
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
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
                                      abL10n("VISIT", lang),
                                      style: localeFont(
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
              child: Icon(icon, size: 18, color: cs.primary),
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
                    style: localeFont(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: localeFont(
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
    final lang = Localizations.localeOf(context).languageCode;

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
            label: abL10n("Send feedback", lang),
            subtitle: abL10n("Suggestions, bugs, or just to say hi", lang),
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
            label: abL10n("Rate Kuber", lang),
            subtitle: abL10n("Help others discover the app", lang),
            onTap: () {
              launchUrl(
                Uri.parse(
                  'https://play.google.com/store/apps/details?id=com.grs.kuber',
                ),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MadeInIndiaFooter extends ConsumerWidget {
  const _MadeInIndiaFooter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final version = ref.watch(appVersionProvider).valueOrNull;

    final String fullText;
    if (version != null) {
      fullText = context.l10n.madeInIndiaVersion('{heart}', version);
    } else {
      fullText = context.l10n.madeInIndia('{heart}');
    }

    final parts = fullText.split('{heart}');
    final beforeText = parts.first;
    final afterText = parts.length > 1 ? parts.last : '';

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: localeFont(
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
          color: cs.onSurfaceVariant,
        ),
        children: [
          TextSpan(text: beforeText),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Icon(
              Icons.favorite_rounded,
              color: Colors.redAccent,
              size: 13,
            ),
          ),
          TextSpan(text: afterText),
        ],
      ),
    );
  }
}