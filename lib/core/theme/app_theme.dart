import 'package:flutter/material.dart';

import '../motion/motion_level.dart';
import '../motion/spring_curve.dart';
import '../utils/locale_font.dart';
import 'theme_families.dart';

export 'kuber_tokens.dart' show ThemeVariant, KuberTokens;
export 'theme_families.dart' show themeFamilyName, themeFamilyBlurb;

/// Kuber M3 spacing (specs/design/kuber-m3-round-1-design-system tokens.md §1).
/// 4/8 scale plus the layout metrics that are defined once.
abstract final class KuberSpace {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Horizontal edge of every screen (Perch Space.screen).
  static const double screenMargin = 20;

  /// Between sections (Perch Space.section).
  static const double sectionGap = 28;

  /// Section header to its content.
  static const double sectionHeaderGap = 8;

  /// Between stacked cards / tiles.
  static const double cardGap = 12;
  static const double cardPadding = 16;

  /// The one hero card per screen.
  static const double cardPaddingHero = 20;

  static const double listItem1 = 56;
  static const double listItem2 = 72;
  static const double listItem3 = 88;
  static const double listRowPadH = 16;
  static const double listRowPadV = 8;
  static const double tapTarget = 48;

  /// Bottom padding of every scroll view that sits under the floating nav.
  static const double navClearance = 108;
}

/// Kuber M3 shape scale (tokens.md §2). Rounded, never squircle.
abstract final class KuberShape {
  static const double none = 0;

  /// Bar tops.
  static const double extraSmall = 4;

  /// Chips, tooltips, heatmap cells, inline badges.
  static const double small = 8;

  /// Category tiles, menu rows, inner tiles in cards.
  static const double medium = 12;

  /// Text fields, snackbar, nested containers.
  static const double large = 16;

  /// Cards, grouped lists, menus.
  static const double largeIncreased = 20;

  /// Sheets (top), dialogs.
  static const double extraLarge = 28;

  /// Buttons, icon buttons, nav pill, FAB, segmented, progress, badges.
  static const double full = 999;

  static const BorderRadius smallR = BorderRadius.all(Radius.circular(small));
  static const BorderRadius mediumR = BorderRadius.all(Radius.circular(medium));
  static const BorderRadius largeR = BorderRadius.all(Radius.circular(large));
  static const BorderRadius cardR =
      BorderRadius.all(Radius.circular(largeIncreased));
  static const BorderRadius sheetR =
      BorderRadius.vertical(top: Radius.circular(extraLarge));
  static const BorderRadius fullR = BorderRadius.all(Radius.circular(full));
}

/// Motion tokens (tokens.md §8, from Perch `Motion`). Only new components use
/// these; existing animations keep their own timings.
/// Elevation tokens. Kuber's depth is tonal (surface containers + borders);
/// the one exception is `shadow.float` (v7.0.0-c handoff, "New tokens"): a
/// surface that floats over content of the same colour (the floating header
/// pill and its docked islands, the reorder lift layer). Painted as a layer
/// whose opacity follows the morph, never animated as a shadow.
abstract final class KuberElevation {
  /// shadow.float: light 0 1 2 / 8 % + 0 4 12 / 10 %; dark 0 1 2 / 40 % +
  /// 0 4 16 / 50 %.
  static List<BoxShadow> float(ColorScheme cs) {
    final dark = cs.brightness == Brightness.dark;
    return [
      BoxShadow(
        color: cs.shadow.withValues(alpha: dark ? 0.40 : 0.08),
        offset: const Offset(0, 1),
        blurRadius: 2,
      ),
      BoxShadow(
        color: cs.shadow.withValues(alpha: dark ? 0.50 : 0.10),
        offset: const Offset(0, 4),
        blurRadius: dark ? 16 : 12,
      ),
    ];
  }
}

abstract final class KuberMotion {
  // ---- Effects (opacity, colour: never springs). v7.0.0 motion.md. ----
  static const Duration instant = Duration(milliseconds: 90);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration navIndicator = Duration(milliseconds: 220);
  static const Duration navHide = Duration(milliseconds: 160);
  static const Duration reducedFade = Duration(milliseconds: 90);
  static const Duration fxInstant = instant;
  static const Duration fxFast = fast;
  static const Duration fxDefault = Duration(milliseconds: 200);

  /// Every opacity and colour change.
  static const Curve curveEffects = Cubic(0.33, 1, 0.68, 1);

  /// Anything the finger caused.
  static const Curve spring = Curves.easeOutBack;

  /// Anything the system caused.
  static const Curve decelerate = curveEffects;

  // ---- Springs (mass 1). Interruptible: retarget with [SpringTo]. ----
  /// Small things: press, chips, radios, switch thumb, chevrons, menus.
  static final SpringDescription springFast =
      SpringDescription.withDampingRatio(mass: 1, stiffness: 800, ratio: 0.6);

  /// Medium things: enter, expand, list insert, dialogs, release of cards.
  static final SpringDescription springDefault =
      SpringDescription.withDampingRatio(mass: 1, stiffness: 380, ratio: 0.8);

  /// Large surfaces: sheets opening, container transform.
  static final SpringDescription springSlow =
      SpringDescription.withDampingRatio(mass: 1, stiffness: 200, ratio: 0.8);

  /// Reflow with no visible bounce: heights, widths, closing.
  static final SpringDescription springStandard =
      SpringDescription.withDampingRatio(mass: 1, stiffness: 700, ratio: 0.9);

  /// Every spatial motion at the Subtle level (critically damped).
  static final SpringDescription springSubtle =
      SpringDescription.withDampingRatio(mass: 1, stiffness: 600, ratio: 1.0);

  /// Cached spring curves for implicit animations (use `.settle` as duration,
  /// `.clamped` for sizes).
  static final SpringCurve fastCurve = SpringCurve(springFast);
  static final SpringCurve defaultCurve = SpringCurve(springDefault);
  static final SpringCurve slowCurve = SpringCurve(springSlow);
  static final SpringCurve standardCurve = SpringCurve(springStandard);
  static final SpringCurve subtleCurve = SpringCurve(springSubtle);

  /// [expressive] at Expressive, [springSubtle] at Subtle. (Off: callers skip.)
  static SpringDescription spatial(MotionLevel l, SpringDescription expressive) =>
      l == MotionLevel.subtle ? springSubtle : expressive;

  /// Curve counterpart of [spatial].
  static SpringCurve spatialCurve(MotionLevel l, SpringCurve expressive) =>
      l == MotionLevel.subtle ? subtleCurve : expressive;

  // ---- Stagger ----
  static const Duration staggerStep = Duration(milliseconds: 30);
  static const int staggerLimit = 6;

  /// Delay of item [index]: 30 ms steps, items past the 6th share the 6th's.
  static Duration staggerDelay(int index) =>
      staggerStep * (index < 0 ? 0 : (index < staggerLimit ? index : staggerLimit - 1));

  // ---- Caps ----
  static const Duration reflow = Duration(milliseconds: 230);
  static const Duration containerTransform = Duration(milliseconds: 240);
  static const Duration sheet = Duration(milliseconds: 260);
  static const Duration snackEnter = Duration(milliseconds: 180);
  static const Duration snackExit = Duration(milliseconds: 140);
  static const Duration digitRoll = Duration(milliseconds: 300);

  /// Theme change ripple (decision 15, slowed after device review): a timed
  /// reveal on an even ease-in-out so the circle visibly sweeps across the
  /// screen (a spring or the emphasized curve covered most of it in ~100 ms
  /// and read as a flash). Subtle is shorter.
  static const Duration themeReveal = Duration(milliseconds: 800);
  static const Duration themeRevealSubtle = Duration(milliseconds: 500);
  static const Curve themeRevealCurve = Curves.easeInOutSine;
  static const Curve themeRevealSubtleCurve = Curves.easeInOutSine;

  // ---- Press amounts ----
  static const double pressScaleCard = 0.98; // cards and list rows
  static const double pressScaleSubtle = 0.99;
  static const double pressScaleFab = 0.96;
  static const double pressScaleChip = 0.96;
  static const double buttonGroupWiden = 0.15;

  /// Android's animator duration scale reaches Flutter only as
  /// disableAnimations (scale 0); 0.5x / 2x are not exposed by the engine, so
  /// this stays 1.0. Multiply durations by it where one is built by hand.
  static const double durationScale = 1.0;

  /// Effective level here: preference + device, and the phone's Remove
  /// animations wins (Off). Cheap: reads one InheritedWidget. Without a
  /// [MotionScope] (tests, startup error app) it is Expressive unless the
  /// phone asks for no animations.
  static MotionLevel levelOf(BuildContext context) {
    final s = MotionScope.maybeOf(context);
    if (s != null) return s.level;
    return (MediaQuery.maybeDisableAnimationsOf(context) ?? false)
        ? MotionLevel.off
        : MotionLevel.expressive;
  }

  /// Not Expressive: callers that only know "reduced" keep working.
  static bool reduced(BuildContext context) =>
      levelOf(context) != MotionLevel.expressive;

  static Duration of(BuildContext context, Duration full) =>
      reduced(context) ? reducedFade : full;

  static Curve curveOf(BuildContext context, Curve full) =>
      reduced(context) ? Curves.linear : full;

  /// [base] at variable weight [wght] (FontVariation 'wght'; harmless on a
  /// static font, which then snaps to the nearest [FontWeight]).
  static TextStyle weightStyle(TextStyle base, double wght) => base.copyWith(
        fontWeight: FontWeight.lerp(FontWeight.w100, FontWeight.w900,
            ((wght - 100) / 800).clamp(0.0, 1.0)),
        fontVariations: [FontVariation('wght', wght)],
      );
}

/// Income / expense / warning colours (tokens.md §4). Money never uses the
/// ColorScheme's tertiary or error roles.
@immutable
class KuberMoneyColors extends ThemeExtension<KuberMoneyColors> {
  final Color income;
  final Color onIncome;
  final Color incomeContainer;
  final Color onIncomeContainer;
  final Color expense;
  final Color onExpense;
  final Color expenseContainer;
  final Color onExpenseContainer;
  final Color warning;
  final Color onWarning;
  final Color warningContainer;
  final Color onWarningContainer;

  /// Income / expense legible on inverseSurface (chart tooltips, the
  /// selection totals pill): the opposite brightness's money tones.
  final Color inverseIncome;
  final Color inverseExpense;

  const KuberMoneyColors({
    required this.income,
    required this.onIncome,
    required this.incomeContainer,
    required this.onIncomeContainer,
    required this.expense,
    required this.onExpense,
    required this.expenseContainer,
    required this.onExpenseContainer,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.inverseIncome,
    required this.inverseExpense,
  });

  /// [m] = this brightness's 12 money colours, [inv] = the opposite
  /// brightness's (only income [0] and expense [4] are read).
  factory KuberMoneyColors.fromList(List<Color> m, [List<Color>? inv]) =>
      KuberMoneyColors(
        income: m[0],
        onIncome: m[1],
        incomeContainer: m[2],
        onIncomeContainer: m[3],
        expense: m[4],
        onExpense: m[5],
        expenseContainer: m[6],
        onExpenseContainer: m[7],
        warning: m[8],
        onWarning: m[9],
        warningContainer: m[10],
        onWarningContainer: m[11],
        inverseIncome: (inv ?? m)[0],
        inverseExpense: (inv ?? m)[4],
      );

  List<Color> get _all => [
        income, onIncome, incomeContainer, onIncomeContainer, //
        expense, onExpense, expenseContainer, onExpenseContainer,
        warning, onWarning, warningContainer, onWarningContainer,
        inverseIncome, inverseIncome, inverseIncome, inverseIncome,
        inverseExpense,
      ];

  @override
  KuberMoneyColors copyWith() => this;

  @override
  KuberMoneyColors lerp(ThemeExtension<KuberMoneyColors>? other, double t) {
    if (other is! KuberMoneyColors) return this;
    final a = _all, b = other._all;
    final l = [for (var i = 0; i < a.length; i++) Color.lerp(a[i], b[i], t)!];
    return KuberMoneyColors.fromList(l.sublist(0, 12), [
      l[12], l[0], l[0], l[0], l[16], //
    ]);
  }
}

/// Data-viz tokens (tokens.md §6).
@immutable
class KuberChartTheme extends ThemeExtension<KuberChartTheme> {
  /// 5 tonal steps of the seed, weakest to strongest on this surface.
  final List<Color> ramp;

  /// 8 categorical hues (262 75 190 345 140 45 300 20) for things without a
  /// user colour: category groups, tags, "Other", event sources.
  final List<Color> categorical;

  final Color gridline;

  /// Opacity of unselected series while one is selected.
  static const double unselectedAlpha = 0.38;

  const KuberChartTheme({
    required this.ramp,
    required this.categorical,
    required this.gridline,
  });

  static const _catLight = [
    Color(0xFF427CCF), Color(0xFFA97100), Color(0xFF008B83), Color(0xFFB85C99), //
    Color(0xFF4D8A37), Color(0xFFC2612A), Color(0xFF886BCC), Color(0xFFC65A5A),
  ];
  static const _catDark = [
    Color(0xFF96BDFF), Color(0xFFF7AD34), Color(0xFF17D1C6), Color(0xFFFF9BD9), //
    Color(0xFF8ACC70), Color(0xFFFFA679), Color(0xFFC6AFFF), Color(0xFFFFA3A0),
  ];

  /// EMI source accent (was Vault eventEmi purple).
  Color get eventEmi => categorical[6];

  /// Ledger source accent (was Vault eventLedger amber).
  Color get eventLedger => categorical[1];

  @override
  KuberChartTheme copyWith() => this;

  @override
  KuberChartTheme lerp(ThemeExtension<KuberChartTheme>? other, double t) {
    if (other is! KuberChartTheme) return this;
    return KuberChartTheme(
      ramp: [
        for (var i = 0; i < ramp.length; i++)
          Color.lerp(ramp[i], other.ramp[i], t)!
      ],
      categorical: [
        for (var i = 0; i < categorical.length; i++)
          Color.lerp(categorical[i], other.categorical[i], t)!
      ],
      gridline: Color.lerp(gridline, other.gridline, t)!,
    );
  }
}

extension KuberThemeX on BuildContext {
  KuberMoneyColors get kuberMoney =>
      Theme.of(this).extension<KuberMoneyColors>() ??
      KuberMoneyColors.fromList(
          kuberPalette(ThemeVariant.signature, Theme.of(this).brightness).money);

  KuberChartTheme get kuberChart =>
      Theme.of(this).extension<KuberChartTheme>() ??
      AppTheme._chart(
          kuberPalette(ThemeVariant.signature, Theme.of(this).brightness));
}

class AppTheme {
  /// [pureBlack] = the page is #000000 in dark; [seed] = Android wallpaper
  /// colour ("From your wallpaper"); [expressive] = tinted backgrounds (off:
  /// neutral greys). One surface rule for every family (theme-surfaces-v1).
  static ThemeData dark(
    Locale locale, [
    ThemeVariant variant = ThemeVariant.signature,
    bool pureBlack = false,
    Color? seed,
    bool expressive = true,
  ]) =>
      _build(
          kuberPalette(variant, Brightness.dark,
              expressive: expressive, pureBlack: pureBlack, seed: seed),
          kuberPalette(variant, Brightness.light, expressive: expressive, seed: seed),
          locale);

  static ThemeData light(
    Locale locale, [
    ThemeVariant variant = ThemeVariant.signature,
    Color? seed,
    bool expressive = true,
    bool pureBlack = false,
  ]) =>
      _build(
          kuberPalette(variant, Brightness.light, expressive: expressive, seed: seed),
          kuberPalette(variant, Brightness.dark,
              expressive: expressive, pureBlack: pureBlack, seed: seed),
          locale);

  /// A family's scheme without building a ThemeData (theme previews).
  static ColorScheme schemeOf(ThemeVariant variant, Brightness b,
          {bool expressive = true, bool pureBlack = false, Color? seed}) =>
      kuberPalette(variant, b, expressive: expressive, pureBlack: pureBlack, seed: seed).scheme;

  static KuberChartTheme _chart(KuberPalette p) {
    final dark = p.scheme.brightness == Brightness.dark;
    return KuberChartTheme(
      ramp: p.ramp,
      categorical:
          dark ? KuberChartTheme._catDark : KuberChartTheme._catLight,
      gridline: p.scheme.outlineVariant,
    );
  }

  static ThemeData _build(KuberPalette p, KuberPalette inverse, Locale locale) {
    final cs = p.scheme;
    final text = buildKuberTextTheme(locale, cs);
    const stadium = StadiumBorder();
    final labelLarge = text.labelLarge!;

    return ThemeData(
      useMaterial3: true,
      brightness: cs.brightness,
      colorScheme: cs,
      extensions: [
        KuberMoneyColors.fromList(p.money, inverse.money),
        _chart(p),
      ],
      textTheme: text,
      splashFactory: InkSparkle.splashFactory,
      scaffoldBackgroundColor: cs.surface,
      canvasColor: cs.surface,
      cardTheme: CardThemeData(
        color: cs.surfaceContainer,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: KuberShape.cardR,
          side: BorderSide(color: cs.outlineVariant),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cs.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: cs.secondaryContainer,
        indicatorShape: stadium,
        iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
              color: s.contains(WidgetState.selected)
                  ? cs.onSecondaryContainer
                  : cs.onSurfaceVariant,
              size: 24,
            )),
        labelTextStyle: WidgetStateProperty.resolveWith((s) =>
            text.labelMedium!.copyWith(
                color: s.contains(WidgetState.selected)
                    ? cs.onSurface
                    : cs.onSurfaceVariant)),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: cs.surface,
        indicatorColor: cs.secondaryContainer,
        indicatorShape: stadium,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cs.surfaceContainerHigh,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: const OutlineInputBorder(
          borderRadius: KuberShape.largeR,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: KuberShape.largeR,
          borderSide: BorderSide.none,
        ),
        disabledBorder: const OutlineInputBorder(
          borderRadius: KuberShape.largeR,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: KuberShape.largeR,
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: KuberShape.largeR,
          borderSide: BorderSide(color: cs.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: KuberShape.largeR,
          borderSide: BorderSide(color: cs.error, width: 2),
        ),
        hintStyle: text.bodyLarge!.copyWith(color: cs.onSurfaceVariant),
        labelStyle: text.bodyLarge!.copyWith(color: cs.onSurfaceVariant),
        floatingLabelStyle: text.bodySmall!.copyWith(color: cs.primary),
        helperStyle: text.bodySmall!.copyWith(color: cs.onSurfaceVariant),
        counterStyle: text.bodySmall!.copyWith(color: cs.onSurfaceVariant),
        errorStyle: text.bodySmall!.copyWith(color: cs.error),
        prefixIconColor: cs.onSurfaceVariant,
        suffixIconColor: cs.onSurfaceVariant,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: cs.primary,
        selectionColor: cs.primary.withValues(alpha: 0.3),
        selectionHandleColor: cs.primary,
      ),
      dividerTheme: DividerThemeData(
        color: cs.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cs.inverseSurface,
        contentTextStyle: text.bodyMedium!.copyWith(color: cs.onInverseSurface),
        actionTextColor: cs.inversePrimary,
        shape: const RoundedRectangleBorder(borderRadius: KuberShape.largeR),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.transparent,
        selectedColor: cs.secondaryContainer,
        disabledColor: cs.onSurface.withValues(alpha: 0.12),
        side: WidgetStateBorderSide.resolveWith((s) => s
                .contains(WidgetState.selected)
            ? BorderSide.none
            : BorderSide(color: cs.outlineVariant)),
        checkmarkColor: cs.onSecondaryContainer,
        showCheckmark: true,
        labelStyle: labelLarge.copyWith(color: cs.onSurfaceVariant),
        secondaryLabelStyle:
            labelLarge.copyWith(color: cs.onSecondaryContainer),
        iconTheme: IconThemeData(color: cs.primary, size: 18),
        shape: const RoundedRectangleBorder(borderRadius: KuberShape.smallR),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
        elevation: 0,
        pressElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cs.surfaceContainerLow,
        modalBackgroundColor: cs.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        modalBarrierColor: Colors.black.withValues(alpha: 0.32),
        shape: const RoundedRectangleBorder(borderRadius: KuberShape.sheetR),
        showDragHandle: false,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cs.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        barrierColor: Colors.black.withValues(alpha: 0.32),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(KuberShape.extraLarge)),
        ),
        titleTextStyle: text.headlineSmall!.copyWith(color: cs.onSurface),
        contentTextStyle:
            text.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: stadium,
          minimumSize: const Size(64, 40),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          textStyle: labelLarge,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          backgroundColor: cs.secondaryContainer,
          foregroundColor: cs.onSecondaryContainer,
          shape: stadium,
          minimumSize: const Size(64, 40),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          textStyle: labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.onSurface,
          side: BorderSide(color: cs.outlineVariant),
          shape: stadium,
          minimumSize: const Size(64, 40),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          textStyle: labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cs.primary,
          shape: stadium,
          minimumSize: const Size(48, 40),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          textStyle: labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(shape: const CircleBorder()),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: const CircleBorder(),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(48, 40)),
          shape: const WidgetStatePropertyAll(stadium),
          side: WidgetStatePropertyAll(BorderSide(color: cs.outline)),
          textStyle: WidgetStatePropertyAll(labelLarge),
          backgroundColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected)
                  ? cs.secondaryContainer
                  : Colors.transparent),
          foregroundColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected)
                  ? cs.onSecondaryContainer
                  : cs.onSurface),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbIcon: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? Icon(Icons.check_rounded, size: 16, color: cs.primary)
                : null),
      ),
      checkboxTheme: const CheckboxThemeData(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(2))),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: cs.primary,
        linearTrackColor: cs.secondaryContainer,
        circularTrackColor: Colors.transparent,
        // ignore: deprecated_member_use
        year2023: false,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: cs.primary,
        inactiveTrackColor: cs.secondaryContainer,
        thumbColor: cs.primary,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: cs.onSurfaceVariant,
        minVerticalPadding: KuberSpace.listRowPadV,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: KuberSpace.listRowPadH),
        horizontalTitleGap: 16,
        titleTextStyle: text.titleMedium!.copyWith(color: cs.onSurface),
        subtitleTextStyle:
            text.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
        shape: const RoundedRectangleBorder(borderRadius: KuberShape.mediumR),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: cs.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        menuPadding: const EdgeInsets.all(KuberSpace.sm),
        textStyle: labelLarge.copyWith(color: cs.onSurface),
        shape: RoundedRectangleBorder(
          borderRadius: KuberShape.cardR,
          side: BorderSide(color: cs.outlineVariant),
        ),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(cs.surfaceContainer),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          elevation: const WidgetStatePropertyAll(0),
          padding: const WidgetStatePropertyAll(EdgeInsets.all(KuberSpace.sm)),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
            borderRadius: KuberShape.cardR,
            side: BorderSide(color: cs.outlineVariant),
          )),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: cs.inverseSurface,
          borderRadius: const BorderRadius.all(Radius.circular(KuberShape.extraSmall)),
        ),
        textStyle: text.bodySmall!.copyWith(color: cs.onInverseSurface),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: cs.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(KuberShape.extraLarge)),
        ),
        rangeSelectionBackgroundColor: cs.secondaryContainer,
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: cs.surfaceContainerHigh,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(KuberShape.extraLarge)),
        ),
      ),
    );
  }
}
