// Polished "What is Kuber" and "What does 'Kuber' mean?" sections for AboutScreen.
//
// Drop-in replacements for the two `_AboutCard(...)` blocks in
// `lib/features/more/screens/about_screen.dart`. Visual language inherited
// from `_DeveloperLetter` and `_WhyKuberSection` (Inter + Playfair italics,
// primary-tint eyebrow, no shadows, borders for depth, KuberRadius.*).
//
// State: stateless — no provider wiring needed.

import 'package:kuber/core/utils/locale_font.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/constants/about_l10n.dart';

/// Section 1: "What is Kuber?"
/// Editorial card with a display headline (italic Playfair pull on
/// "stay aware"), supporting paragraph, and a tag rail.
class AboutWhatIsKuberSection extends StatelessWidget {
  const AboutWhatIsKuberSection({super.key});

  List<InlineSpan> _buildWhatIsHeadline(BuildContext context, String lang) {
    final cs = Theme.of(context).colorScheme;
    final fullText = abL10n('A simple way to {stay_aware} of where your money goes.', lang);
    final stayAwareText = abL10n('stay aware', lang);
    final parts = fullText.split('{stay_aware}');
    final before = parts.first;
    final after = parts.length > 1 ? parts.last : '';

    return [
      TextSpan(text: before),
      TextSpan(
        text: stayAwareText,
        style: GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w700,
          color: cs.primary,
          height: 1.2,
        ),
      ),
      TextSpan(text: after),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final lang = Localizations.localeOf(context).languageCode;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(
          KuberRadius.xl,
        ), // 24 — matches Letter card
        border: Border.all(color: cs.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Eyebrow row ----------------------------------------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: cs.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: KuberSpacing.sm),
                Text(
                  abL10n('WHAT IS KUBER', lang),
                  style: localeFont(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                    color: cs.primary,
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: cs.outline),

          // --- Body -----------------------------------------------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display headline — Inter w/ Playfair italic pull on "stay aware"
                Text.rich(
                  TextSpan(
                    style: localeFont(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                      letterSpacing: -0.4,
                      color: cs.onSurface,
                    ),
                    children: _buildWhatIsHeadline(context, lang),
                  ),
                ),
                const SizedBox(height: KuberSpacing.md),
                Text(
                  abL10n('Kuber is a fast, no-fuss expense tracker. Built for consistency, not complexity. Open it, log what you spent, move on.', lang),
                  style: localeFont(
                    fontSize: 13.5,
                    color: cs.onSurfaceVariant,
                    height: 1.6,
                  ),
                ),

                // Tag rail
                const SizedBox(height: KuberSpacing.md),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _AboutTag(abL10n('Fast', lang)),
                    _AboutTag(abL10n('Offline', lang)),
                    _AboutTag(abL10n('Private', lang)),
                    _AboutTag(abL10n('Habit-friendly', lang)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Section 2: "What does 'Kuber' mean?"
/// Three numbered verses with a Sanskrit stamp and a Devanagari glyph in the
/// header. The third verse is set in italic Playfair to land the philosophical line.
class AboutKuberMeaningSection extends StatelessWidget {
  const AboutKuberMeaningSection({super.key});

  List<InlineSpan> _buildVerse1Text(BuildContext context, String lang) {
    final cs = Theme.of(context).colorScheme;
    final fullText = abL10n('In Indian mythology, {kuber} is the guardian of wealth and prosperity.', lang);
    final parts = fullText.split('{kuber}');
    final before = parts.first;
    final after = parts.length > 1 ? parts.last : '';

    return [
      TextSpan(text: before),
      TextSpan(
        text: 'Kuber',
        style: localeFont(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: cs.onSurface,
        ),
      ),
      TextSpan(text: after),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final lang = Localizations.localeOf(context).languageCode;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.xl),
        border: Border.all(color: cs.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header ---------------------------------------------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Row(
              children: [
                // Devanagari glyph for "क" (ka) — first syllable of Kubera.
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    'क',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 26,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w700,
                      color: cs.primary,
                      height: 1.0,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    abL10n("WHAT DOES 'KUBER' MEAN?", lang),
                    style: localeFont(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.6,
                      color: cs.primary,
                    ),
                  ),
                ),
                // Provenance stamp
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHigh,
                    border: Border.all(color: cs.outline),
                    borderRadius: BorderRadius.circular(KuberRadius.sm),
                  ),
                  child: Text(
                    abL10n('SANSKRIT', lang).toUpperCase(),
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: cs.outline),

          // --- Verses ---------------------------------------------------------
          _MeaningVerse(
            numeral: 'I',
            child: Text.rich(
              TextSpan(
                style: localeFont(
                  fontSize: 13.5,
                  height: 1.55,
                  color: cs.onSurface,
                ),
                children: _buildVerse1Text(context, lang),
              ),
            ),
          ),
          Container(height: 1, color: cs.outline),
          _MeaningVerse(
            numeral: 'II',
            child: Text(
              abL10n('He represents not just riches, but the responsibility of managing wealth wisely.', lang),
              style: localeFont(
                fontSize: 13.5,
                height: 1.55,
                color: cs.onSurface,
              ),
            ),
          ),
          Container(height: 1, color: cs.outline),
          _MeaningVerse(
            numeral: 'III',
            child: Text(
              abL10n("Kuber is not about having more.\nIt's about being aware of what you have.", lang),
              style: GoogleFonts.playfairDisplay(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w700,
                height: 1.5,
                color: cs.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MeaningVerse extends StatelessWidget {
  final String numeral;
  final Widget child;
  const _MeaningVerse({required this.numeral, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Roman numeral — FittedBox so "III" doesn't wrap to a second line.
          SizedBox(
            width: 44,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.topLeft,
              child: Text(
                numeral,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w700,
                  color: cs.primary.withValues(alpha: 0.6),
                  height: 1.0,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _AboutTag extends StatelessWidget {
  final String label;
  const _AboutTag(this.label);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        border: Border.all(color: cs.outline),
        borderRadius: BorderRadius.circular(KuberRadius.full),
      ),
      child: Text(
        label,
        style: localeFont(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: cs.onSurfaceVariant,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}