import 'package:flutter/material.dart';

import '../utils/locale_font.dart';
import 'theme_families.dart';

export 'kuber_tokens.dart' show ThemeVariant, KuberTokens;
export 'theme_families.dart' show themeFamilyName, themeFamilyBlurb, themeFamilyHasAmoled;

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
abstract final class KuberMotion {
  static const Duration instant = Duration(milliseconds: 90);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration navIndicator = Duration(milliseconds: 220);
  static const Duration navHide = Duration(milliseconds: 160);
  static const Duration reducedFade = Duration(milliseconds: 90);

  /// Anything the finger caused.
  static const Curve spring = Curves.easeOutBack;

  /// Anything the system caused.
  static const Curve decelerate = Curves.easeOutCubic;

  static bool reduced(BuildContext context) {
    final mq = MediaQuery.of(context);
    return mq.disableAnimations || mq.accessibleNavigation;
  }

  static Duration of(BuildContext context, Duration full) =>
      reduced(context) ? reducedFade : full;

  static Curve curveOf(BuildContext context, Curve full) =>
      reduced(context) ? Curves.linear : full;
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
  /// [amoled] = true-black dark surfaces (families that support it);
  /// [seed] = Android wallpaper colour ("From your wallpaper").
  static ThemeData dark(
    Locale locale, [
    ThemeVariant variant = ThemeVariant.signature,
    bool amoled = false,
    Color? seed,
  ]) =>
      _build(
          kuberPalette(variant, Brightness.dark, amoled: amoled, seed: seed),
          kuberPalette(variant, Brightness.light, seed: seed),
          locale);

  static ThemeData light(
    Locale locale, [
    ThemeVariant variant = ThemeVariant.signature,
    Color? seed,
  ]) =>
      _build(
          kuberPalette(variant, Brightness.light, seed: seed),
          kuberPalette(variant, Brightness.dark, seed: seed),
          locale);

  /// A family's scheme without building a ThemeData (theme previews).
  static ColorScheme schemeOf(ThemeVariant variant, Brightness b,
          {bool amoled = false, Color? seed}) =>
      kuberPalette(variant, b, amoled: amoled, seed: seed).scheme;

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
