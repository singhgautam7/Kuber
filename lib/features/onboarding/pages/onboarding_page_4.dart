import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_data.dart';
import '../../../core/utils/formatters.dart';
import '../../settings/widgets/currency_selector_sheet.dart';
import '../widgets/animated_tutorial_checkbox.dart';
import '../widgets/onboarding_dots_indicator.dart';

class OnboardingPage4 extends ConsumerStatefulWidget {
  final TextEditingController nameController;
  final String selectedCurrencyCode;
  final ValueChanged<String> onCurrencyChanged;
  final ThemeMode selectedTheme;
  final ValueChanged<ThemeMode> onThemeChanged;
  final bool showTutorial;
  final ValueChanged<bool> onShowTutorialChanged;
  final VoidCallback onBack;
  final VoidCallback onSubmit;

  const OnboardingPage4({
    super.key,
    required this.nameController,
    required this.selectedCurrencyCode,
    required this.onCurrencyChanged,
    required this.selectedTheme,
    required this.onThemeChanged,
    required this.showTutorial,
    required this.onShowTutorialChanged,
    required this.onBack,
    required this.onSubmit,
  });

  @override
  ConsumerState<OnboardingPage4> createState() => _OnboardingPage4State();
}

class _OnboardingPage4State extends ConsumerState<OnboardingPage4> {
  bool get _canSubmit => widget.nameController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final currency = currencyFromCode(widget.selectedCurrencyCode);

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: KuberSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: KuberSpacing.xxl),

                  Text(
                    'Make it yours.',
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                      letterSpacing: -0.8,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: KuberSpacing.sm),
                  Text(
                    "Three quick choices and you're in.",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: cs.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: KuberSpacing.xl),

                  // Name field
                  _SectionLabel('YOUR NAME'),
                  const SizedBox(height: KuberSpacing.sm),
                  TextField(
                    controller: widget.nameController,
                    onChanged: (_) => setState(() {}),
                    textCapitalization: TextCapitalization.words,
                    inputFormatters: [TitleCaseInputFormatter()],
                    style: GoogleFonts.inter(color: cs.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Enter your name',
                      hintStyle:
                          GoogleFonts.inter(color: cs.onSurfaceVariant),
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
                        borderSide:
                            BorderSide(color: cs.primary, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: KuberSpacing.lg,
                        vertical: KuberSpacing.md,
                      ),
                    ),
                  ),
                  const SizedBox(height: KuberSpacing.xl),

                  // Currency
                  _SectionLabel('CURRENCY'),
                  const SizedBox(height: KuberSpacing.sm),
                  GestureDetector(
                    onTap: () => showCurrencyPicker(
                      context: context,
                      ref: ref,
                      currentCode: widget.selectedCurrencyCode,
                      onSelected: widget.onCurrencyChanged,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: KuberSpacing.lg,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainer,
                        borderRadius:
                            BorderRadius.circular(KuberRadius.md),
                        border: Border.all(color: cs.outline),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: cs.primary.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                currency.symbol,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: cs.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: KuberSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currency.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: cs.onSurface,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  widget.selectedCurrencyCode,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.search_rounded,
                            color: cs.onSurfaceVariant,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: KuberSpacing.xl),

                  // Theme
                  _SectionLabel('THEME'),
                  const SizedBox(height: KuberSpacing.sm),
                  _ThemeTilePicker(
                    selected: widget.selectedTheme,
                    onSelected: widget.onThemeChanged,
                  ),
                  const SizedBox(height: KuberSpacing.xl),

                  // Tutorial checkbox
                  AnimatedTutorialCheckbox(
                    checked: widget.showTutorial,
                    onChanged: widget.onShowTutorialChanged,
                  ),
                  const SizedBox(height: KuberSpacing.xl),
                ],
              ),
            ),
          ),

          // Bottom nav
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: KuberSpacing.xl,
              vertical: KuberSpacing.lg,
            ),
            child: Column(
              children: [
                Center(
                  child: OnboardingDotsIndicator(
                    totalPages: 4,
                    currentPage: 3,
                  ),
                ),
                const SizedBox(height: KuberSpacing.md),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: widget.onBack,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: cs.onSurface,
                        side: BorderSide(color: cs.outline),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(KuberRadius.md),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: KuberSpacing.lg,
                          vertical: KuberSpacing.md,
                        ),
                      ),
                      child: Text(
                        '← Back',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: KuberSpacing.md),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: FilledButton(
                          onPressed: _canSubmit ? widget.onSubmit : null,
                          style: FilledButton.styleFrom(
                            backgroundColor: cs.primary,
                            disabledBackgroundColor:
                                cs.primary.withValues(alpha: 0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(KuberRadius.md),
                            ),
                          ),
                          child: Text(
                            'Start my journey →',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _canSubmit
                                  ? Colors.white
                                  : Colors.white
                                      .withValues(alpha: 0.5),
                            ),
                          ),
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
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: cs.onSurfaceVariant,
        letterSpacing: 1.1,
      ),
    );
  }
}

class _ThemeTilePicker extends StatelessWidget {
  final ThemeMode selected;
  final ValueChanged<ThemeMode> onSelected;

  const _ThemeTilePicker({
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final opts = [
      _ThemeOpt(ThemeMode.light, 'LIGHT', Icons.light_mode_outlined),
      _ThemeOpt(ThemeMode.dark, 'DARK', Icons.dark_mode_outlined),
      _ThemeOpt(ThemeMode.system, 'SYSTEM', Icons.phone_android_rounded),
    ];

    return Row(
      children: opts.asMap().entries.map((e) {
        final isSelected = e.value.mode == selected;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: e.key > 0 ? KuberSpacing.sm : 0),
            child: GestureDetector(
              onTap: () => onSelected(e.value.mode),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: KuberSpacing.lg),
                decoration: BoxDecoration(
                  color: isSelected
                      ? cs.primary.withValues(alpha: 0.08)
                      : cs.surfaceContainer,
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                  border: Border.all(
                    color: isSelected ? cs.primary : cs.outline,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHigh,
                              borderRadius:
                                  BorderRadius.circular(KuberRadius.md),
                            ),
                            child: Icon(
                              e.value.icon,
                              color: isSelected
                                  ? cs.primary
                                  : cs.onSurfaceVariant,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(height: KuberSpacing.sm),
                        Text(
                          e.value.label,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: isSelected ? cs.primary : cs.onSurface,
                          ),
                        ),
                      ],
                    ),
                    if (isSelected)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Icon(
                          Icons.check_circle_rounded,
                          color: cs.primary,
                          size: 16,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ThemeOpt {
  final ThemeMode mode;
  final String label;
  final IconData icon;
  const _ThemeOpt(this.mode, this.label, this.icon);
}
