// Polished "What is Kuber" and "What does 'Kuber' mean?" sections for AboutScreen.
//
// Drop-in replacements for the two `_AboutCard(...)` blocks in
// `lib/features/more/screens/about_screen.dart`. Visual language inherited
// from `_DeveloperLetter` and `_WhyKuberSection` (Inter + Playfair italics,
// primary-tint eyebrow, no shadows, borders for depth, KuberRadius.*).
//
// State: stateless — no provider wiring needed.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';

/// Section 1: "What is Kuber?"
/// Editorial card with a display headline (italic Playfair pull on
/// "stay aware"), supporting paragraph, and a tag rail.
class AboutWhatIsKuberSection extends StatelessWidget {
  const AboutWhatIsKuberSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
                  'WHAT IS KUBER',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                    color: cs.primary,
                  ),
                ),
                const Spacer(),
                Text(
                  '/02',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurfaceVariant,
                    letterSpacing: 0.5,
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
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                      letterSpacing: -0.4,
                      color: cs.onSurface,
                    ),
                    children: [
                      const TextSpan(text: 'A simple way to '),
                      TextSpan(
                        text: 'stay aware',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 24,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w700,
                          color: cs.primary,
                          height: 1.2,
                        ),
                      ),
                      const TextSpan(text: ' of where your money goes.'),
                    ],
                  ),
                ),
                const SizedBox(height: KuberSpacing.md),
                Text(
                  "Kuber is a fast, no-fuss expense tracker. Built for consistency, "
                  "not complexity — open it, log what you spent, move on.",
                  style: GoogleFonts.inter(
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
                  children: const [
                    _AboutTag('Fast'),
                    _AboutTag('Offline'),
                    _AboutTag('Private'),
                    _AboutTag('Habit-friendly'),
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
                    "WHAT DOES 'KUBER' MEAN?",
                    style: GoogleFonts.inter(
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
                    'SANSKRIT',
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
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  height: 1.55,
                  color: cs.onSurface,
                ),
                children: [
                  const TextSpan(text: 'In Indian mythology, '),
                  TextSpan(
                    text: 'Kuber',
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  const TextSpan(
                    text: ' is the guardian of wealth and prosperity.',
                  ),
                ],
              ),
            ),
          ),
          Container(height: 1, color: cs.outline),
          _MeaningVerse(
            numeral: 'II',
            child: Text(
              'He represents not just riches, but the responsibility of managing wealth wisely.',
              style: GoogleFonts.inter(
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
              "Kuber is not about having more.\nIt's about being aware of what you have.",
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
          // Roman numeral
          SizedBox(
            width: 32,
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
        style: GoogleFonts.inter(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: cs.onSurfaceVariant,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
