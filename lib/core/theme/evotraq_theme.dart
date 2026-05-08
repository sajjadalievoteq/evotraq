/// Evotraq design tokens and [ThemeData] for TraqTrace (evotraq.io).
///
/// This is the canonical app theme; use [EvotraqTheme.light]/[EvotraqTheme.dark]
/// in [MaterialApp] and [EvotraqColors]/[EvotraqText] from [BuildContext] in widgets.

import 'package:flutter/material.dart';

@immutable
class EvotraqColors extends ThemeExtension<EvotraqColors> {
  // Surfaces
  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color surfaceElevated;
  final Color inverseSurface;

  // Borders
  final Color border;
  final Color borderVariant;
  final Color borderStrong;

  // Text
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textFaint;
  final Color textOnInverse;

  // Brand
  final Color primary;
  /// High-contrast ink on primary fills (handoff “sig ink”).
  final Color onPrimary;
  final Color primaryMuted;
  final Color primaryGlow;

  /// Second accent (informational blue; links, info UI, GTIN chip base).
  final Color secondary;

  // Status
  final Color success;
  final Color warning;
  final Color error;

  // Identifier coding
  final Color identifierGtin;
  final Color identifierGln;
  final Color identifierSgtin;
  final Color identifierSscc;
  final Color identifierEvent;

  const EvotraqColors({
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.surfaceElevated,
    required this.inverseSurface,
    required this.border,
    required this.borderVariant,
    required this.borderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textFaint,
    required this.textOnInverse,
    required this.primary,
    required this.onPrimary,
    required this.primaryMuted,
    required this.primaryGlow,
    required this.secondary,
    required this.success,
    required this.warning,
    required this.error,
    required this.identifierGtin,
    required this.identifierGln,
    required this.identifierSgtin,
    required this.identifierSscc,
    required this.identifierEvent,
  });

  static Color _autoOn(Color color) =>
      color.computeLuminance() > 0.55 ? const Color(0xFF111318) : Colors.white;

  static Color _withOpacity(Color color, double opacity) =>
      color.withAlpha((opacity.clamp(0, 1) * 255).round());

  static final dark = EvotraqColors(
    background: const Color(0xFF0D0E11),
    surface: const Color(0xFF181A1E),
    surfaceMuted: const Color(0xFF22252A),
    surfaceElevated: const Color(0xFF2C3036),
    inverseSurface: Color(0xFFF7F7F5),
    border: Color(0xFF3D4047),
    borderVariant: Color(0xFF4C5058),
    borderStrong: Color(0xFF6A6F78),
    textPrimary: Color(0xFFF7F7F5),
    textSecondary: Color(0xFFCFCFCC),
    textMuted: Color(0xFF8E939B),
    textFaint: Color(0xFF666B73),
    textOnInverse: Color(0xFF1A1B1E),
    primary: Color(0xFF1e675d),
    onPrimary: _autoOn(const Color(0xFF5F0F26)),
    primaryMuted: _withOpacity(const Color(0xFF5F0F26), 0.18),
    primaryGlow: _withOpacity(const Color(0xFF5F0F26), 0.35),
    secondary: Color(0xFF6FB7DC),
    success: Color(0xFF7BD389),
    warning: Color(0xFFE6B454),
    error: Color(0xFFE85C4A),
    identifierGtin: Color(0xFF6FB7DC),
    identifierGln: Color(0xFFA89DDC),
    identifierSgtin: Color(0xFF5BC2B5),
    identifierSscc: Color(0xFFE0B070),
    identifierEvent: Color(0xFFD080CB),
  );

  static final light = EvotraqColors(
    background: const Color(0xFFF2F2EF),

    surface: const Color(0xFFFFFFFF),
    surfaceMuted: const Color(0xFFE3E3DE),
    surfaceElevated: const Color(0xFFD8D8D2),
    inverseSurface: Color(0xFF222428),
    border: Color(0xFFE2E2DF),
    borderVariant: Color(0xFFD3D3D0),
    borderStrong: Color(0xFFA6A8AC),
    textPrimary: Color(0xFF252830),
    textSecondary: Color(0xFF464A52),
    textMuted: Color(0xFF6A6F78),
    textFaint: Color(0xFF8E939B),
    textOnInverse: Color(0xFFF7F7F5),
    primary: Color(0xFF33ad9e ),
    onPrimary: _autoOn(const Color(0xFF3A0F19)),
    primaryMuted: _withOpacity(const Color(0xFF3A0F19), 0.14),
    primaryGlow: _withOpacity(const Color(0xFF3A0F19), 0.28),
    secondary: Color(0xFF3071A8),
    success: Color(0xFF4F8B3E),
    warning: Color(0xFFB07A1C),
    error: Color(0xFFB6362B),
    identifierGtin: Color(0xFF3071A8),
    identifierGln: Color(0xFF6A4FA0),
    identifierSgtin: Color(0xFF2E7B70),
    identifierSscc: Color(0xFFA06028),
    identifierEvent: Color(0xFF99457E),
  );

  static EvotraqColors of(BuildContext context) =>
      Theme.of(context).extension<EvotraqColors>()!;

  @override
  EvotraqColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceMuted,
    Color? surfaceElevated,
    Color? inverseSurface,
    Color? border,
    Color? borderVariant,
    Color? borderStrong,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? textFaint,
    Color? textOnInverse,
    Color? primary,
    Color? onPrimary,
    Color? primaryMuted,
    Color? primaryGlow,
    Color? secondary,
    Color? success,
    Color? warning,
    Color? error,
    Color? identifierGtin,
    Color? identifierGln,
    Color? identifierSgtin,
    Color? identifierSscc,
    Color? identifierEvent,
  }) =>
      EvotraqColors(
        background: background ?? this.background,
        surface: surface ?? this.surface,
        surfaceMuted: surfaceMuted ?? this.surfaceMuted,
        surfaceElevated: surfaceElevated ?? this.surfaceElevated,
        inverseSurface: inverseSurface ?? this.inverseSurface,
        border: border ?? this.border,
        borderVariant: borderVariant ?? this.borderVariant,
        borderStrong: borderStrong ?? this.borderStrong,
        textPrimary: textPrimary ?? this.textPrimary,
        textSecondary: textSecondary ?? this.textSecondary,
        textMuted: textMuted ?? this.textMuted,
        textFaint: textFaint ?? this.textFaint,
        textOnInverse: textOnInverse ?? this.textOnInverse,
        primary: primary ?? this.primary,
        onPrimary: onPrimary ?? this.onPrimary,
        primaryMuted: primaryMuted ?? this.primaryMuted,
        primaryGlow: primaryGlow ?? this.primaryGlow,
        secondary: secondary ?? this.secondary,
        success: success ?? this.success,
        warning: warning ?? this.warning,
        error: error ?? this.error,
        identifierGtin: identifierGtin ?? this.identifierGtin,
        identifierGln: identifierGln ?? this.identifierGln,
        identifierSgtin: identifierSgtin ?? this.identifierSgtin,
        identifierSscc: identifierSscc ?? this.identifierSscc,
        identifierEvent: identifierEvent ?? this.identifierEvent,
      );

  @override
  EvotraqColors lerp(ThemeExtension<EvotraqColors>? other, double t) {
    if (other is! EvotraqColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return EvotraqColors(
      background: l(background, other.background),
      surface: l(surface, other.surface),
      surfaceMuted: l(surfaceMuted, other.surfaceMuted),
      surfaceElevated: l(surfaceElevated, other.surfaceElevated),
      inverseSurface: l(inverseSurface, other.inverseSurface),
      border: l(border, other.border),
      borderVariant: l(borderVariant, other.borderVariant),
      borderStrong: l(borderStrong, other.borderStrong),
      textPrimary: l(textPrimary, other.textPrimary),
      textSecondary: l(textSecondary, other.textSecondary),
      textMuted: l(textMuted, other.textMuted),
      textFaint: l(textFaint, other.textFaint),
      textOnInverse: l(textOnInverse, other.textOnInverse),
      primary: l(primary, other.primary),
      onPrimary: l(onPrimary, other.onPrimary),
      primaryMuted: l(primaryMuted, other.primaryMuted),
      primaryGlow: l(primaryGlow, other.primaryGlow),
      secondary: l(secondary, other.secondary),
      success: l(success, other.success),
      warning: l(warning, other.warning),
      error: l(error, other.error),
      identifierGtin: l(identifierGtin, other.identifierGtin),
      identifierGln: l(identifierGln, other.identifierGln),
      identifierSgtin: l(identifierSgtin, other.identifierSgtin),
      identifierSscc: l(identifierSscc, other.identifierSscc),
      identifierEvent: l(identifierEvent, other.identifierEvent),
    );
  }
}

class EvotraqText {
  static const String fontFamily = 'Nekst';

  final TextStyle display;
  final TextStyle h1;
  final TextStyle h2;
  final TextStyle h3;
  final TextStyle body;
  final TextStyle bodySm;
  final TextStyle cap;
  final TextStyle mono;
  final TextStyle monoNum;

  const EvotraqText._({
    required this.display,
    required this.h1,
    required this.h2,
    required this.h3,
    required this.body,
    required this.bodySm,
    required this.cap,
    required this.mono,
    required this.monoNum,
  });

  factory EvotraqText.build(EvotraqColors c) {
    // Use ONLY local bundled font (see pubspec.yaml). Do not fall back to network fonts.
    TextStyle base([double? size, FontWeight? weight, double? height]) =>
        TextStyle(
          fontFamily: fontFamily,
          fontSize: size,
          fontWeight: weight,
          height: height,
          color: c.textPrimary,
        );

    final display = base(56, FontWeight.w600, 1.0).copyWith(
      fontSize: 56,
      height: 1.0,
      letterSpacing: -1.68,
      fontWeight: FontWeight.w600,
    );
    final h1 = base(32, FontWeight.w600, 1.1).copyWith(
      fontSize: 32,
      height: 1.1,
      letterSpacing: -0.64,
      fontWeight: FontWeight.w600,
    );
    final h2 = base(22, FontWeight.w600, 1.2).copyWith(
      fontSize: 22,
      height: 1.2,
      letterSpacing: -0.33,
      fontWeight: FontWeight.w600,
    );
    final h3 = base(16, FontWeight.w600, 1.3).copyWith(
      fontSize: 16,
      height: 1.3,
      letterSpacing: -0.08,
      fontWeight: FontWeight.w600,
    );
    final body = base(14, FontWeight.w400, 1.5).copyWith(
      fontSize: 14,
      height: 1.5,
      fontWeight: FontWeight.w400,
    );
    final bodySm = base(13, FontWeight.w400, 1.45).copyWith(
      fontSize: 13,
      height: 1.45,
      fontWeight: FontWeight.w400,
    );
    final cap = base(14, FontWeight.w500, 1.3).copyWith(
      fontSize: 14,
      height: 1.3,
      letterSpacing: 0.88,
      fontWeight: FontWeight.w500,
      color: c.textMuted,
    );
    final monoBase = base(13, FontWeight.w400, 1.4).copyWith(
      fontSize: 13,
      height: 1.4,
      fontWeight: FontWeight.w400,
    );

    return EvotraqText._(
      display: display,
      h1: h1,
      h2: h2,
      h3: h3,
      body: body,
      bodySm: bodySm,
      cap: cap,
      mono: monoBase,
      monoNum: monoBase.copyWith(
        fontWeight: FontWeight.w500,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }

  /// Pull from context — we stash it on the theme via an extension.
  static EvotraqText of(BuildContext context) =>
      Theme.of(context).extension<_EvotraqTextExt>()!.text;
}

class _EvotraqTextExt extends ThemeExtension<_EvotraqTextExt> {
  final EvotraqText text;
  const _EvotraqTextExt(this.text);

  @override
  _EvotraqTextExt copyWith({EvotraqText? text}) => _EvotraqTextExt(text ?? this.text);

  @override
  _EvotraqTextExt lerp(ThemeExtension<_EvotraqTextExt>? other, double t) => this;
}

class EvotraqSpacing {
  // 4-pt scale used throughout the designs
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  // Common paddings
  static const EdgeInsets cardPad = EdgeInsets.all(20);
  static const EdgeInsets surfacePad = EdgeInsets.all(16);
  static const EdgeInsets pagePad =
      EdgeInsets.symmetric(horizontal: 24, vertical: 24);

  // Component heights
  static const double buttonH = 36;
  static const double buttonHLarge = 44;
  static const double inputH = 44;
  static const double topbarH = 64;
  static const double sidebarW = 240;
  static const double sidebarWClose = 64;
}

class EvotraqRadius {
  // Tight corners: 4px default
  static const Radius xs = Radius.circular(2);
  static const Radius sm = Radius.circular(3);
  static const Radius md = Radius.circular(4);
  static const Radius lg = Radius.circular(8);
  static const Radius pill = Radius.circular(999);

  static const BorderRadius card = BorderRadius.all(md);
  static const BorderRadius input = BorderRadius.all(md);
  static const BorderRadius button = BorderRadius.all(md);
  static const BorderRadius chip = BorderRadius.all(sm);
}

class EvotraqDuration {
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 400);
  static const Cubic ease = Cubic(0.4, 0.0, 0.2, 1.0);
}

class EvotraqShadows {
  static List<BoxShadow> sm({required Brightness brightness}) => [
        BoxShadow(
          color: brightness == Brightness.dark
              ? const Color(0x66000000)
              : const Color(0x0F000000),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> md({required Brightness brightness}) => [
        BoxShadow(
          color: brightness == Brightness.dark
              ? const Color(0x99000000)
              : const Color(0x1F000000),
          blurRadius: 24,
          spreadRadius: -8,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> lg({required Brightness brightness}) => [
        BoxShadow(
          color: brightness == Brightness.dark
              ? const Color(0xB3000000)
              : const Color(0x2E000000),
          blurRadius: 48,
          spreadRadius: -12,
          offset: const Offset(0, 24),
        ),
      ];

  static List<BoxShadow> primaryGlow(EvotraqColors c) => [
        BoxShadow(color: c.primaryGlow, blurRadius: 16, spreadRadius: -2),
      ];
}

class EvotraqTheme {
  static ThemeData dark() => _build(EvotraqColors.dark, Brightness.dark);
  static ThemeData light() => _build(EvotraqColors.light, Brightness.light);

  static ThemeData _build(EvotraqColors c, Brightness b) {
    final text = EvotraqText.build(c);
    // Ink on primary surfaces (buttons, app bars). Matches legacy filled-button styling.
    final onPrimaryInk = b == Brightness.dark ? c.textSecondary : Colors.white;

    final roundedMd = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(EvotraqRadius.md),
    );

    final roundedLg = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(EvotraqRadius.lg),
    );

    return ThemeData(
      brightness: b,
      useMaterial3: true,
      fontFamily: EvotraqText.fontFamily,
      scaffoldBackgroundColor: c.background,
      canvasColor: c.background,
      dividerColor: c.border,
      hintColor: c.textFaint,
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return c.textFaint.withOpacity(0.6);
          }
          if (states.contains(WidgetState.selected)) {
            return c.primary;
          }

          return  c.surfaceElevated;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return c.border.withOpacity(0.5);
          }

          return b == Brightness.light ? Colors.white : c.surfaceMuted;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return c.border.withOpacity(0.5);
          }
          return c.borderVariant;
        }),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          // Prevent hover overlay from visually washing out the thumb on web.
          if (states.contains(WidgetState.hovered)) {
            return Colors.transparent;
          }
          if (states.contains(WidgetState.focused) ||
              states.contains(WidgetState.pressed)) {
            return c.primary.withOpacity(0.12);
          }
          return null;
        }),
      ),
      colorScheme: ColorScheme(
        brightness: b,
        primary: c.primary,
        // For Evotraq filled buttons we want:
        // - light mode: white text/icons on green
        // - dark mode: slightly gray text/icons on lime
        onPrimary: onPrimaryInk,
        secondary: c.secondary,
        onSecondary: Colors.white,
        error: c.error,
        onError: c.textOnInverse,
        surface: c.surface,
        onSurface: c.textPrimary,
        surfaceContainerHighest: c.surfaceMuted,
        outline: c.borderVariant,
        outlineVariant: c.border,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: c.primary,
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
        actionsIconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: text.body.copyWith(color: Colors.white,fontWeight: FontWeight.w500,fontSize: 16),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: text.body.copyWith(color: c.textFaint),
        labelStyle: text.cap.copyWith(color: c.textMuted),
        border: OutlineInputBorder(
          borderRadius: EvotraqRadius.input,
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: EvotraqRadius.input,
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: EvotraqRadius.input,
          borderSide: BorderSide(color: c.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: EvotraqRadius.input,
          borderSide: BorderSide(color: c.error),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.primary,
          // `onPrimary` token is for ink on brand fills; buttons use white / muted text.
          foregroundColor: onPrimaryInk,
          textStyle: text.bodySm.copyWith(fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: const RoundedRectangleBorder(borderRadius: EvotraqRadius.button),
          minimumSize: const Size(0, EvotraqSpacing.buttonH),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: onPrimaryInk,
          textStyle: text.bodySm.copyWith(fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: const RoundedRectangleBorder(borderRadius: EvotraqRadius.button),
          minimumSize: const Size(0, EvotraqSpacing.buttonH),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: c.surfaceMuted,
          foregroundColor: c.textPrimary,
          side: BorderSide(color: c.borderVariant),
          textStyle: text.bodySm.copyWith(fontWeight: FontWeight.w500),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: const RoundedRectangleBorder(borderRadius: EvotraqRadius.button),
          minimumSize: const Size(0, EvotraqSpacing.buttonH),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.textPrimary,
          textStyle: text.bodySm,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: const RoundedRectangleBorder(borderRadius: EvotraqRadius.button),
        ),
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: c.border),
          borderRadius: const BorderRadius.all(EvotraqRadius.md),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: roundedLg,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: c.surface,
        modalBarrierColor: Colors.black.withOpacity(b == Brightness.dark ? 0.55 : 0.35),
        shape: roundedLg,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.inverseSurface,
        contentTextStyle: text.bodySm.copyWith(color: c.textOnInverse),
        shape: roundedMd,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: roundedMd,
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(c.surface),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(roundedMd),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(c.surface),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(roundedMd),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: c.background,
          border: OutlineInputBorder(
            borderRadius: EvotraqRadius.input,
            borderSide: BorderSide(color: c.border),
          ),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: text.display,
        headlineLarge: text.h1,
        headlineMedium: text.h2,
        titleMedium: text.h3,
        bodyMedium: text.body,
        bodySmall: text.bodySm,
        labelSmall: text.cap,
      ),
      extensions: <ThemeExtension<dynamic>>[
        c,
        _EvotraqTextExt(text),
      ],
    );
  }
}

extension EvotraqContextX on BuildContext {
  EvotraqColors get colors => EvotraqColors.of(this);
  EvotraqText get text => EvotraqText.of(this);
}

extension EvotraqSemanticColors on EvotraqColors {
  /// Muted icon on dashboard stat tiles (replaces legacy `AppTheme.statsTiles`).
  Color get statTileIcon => textMuted;
}

class EvotraqCard extends StatelessWidget {
  const EvotraqCard({
    super.key,
    required this.child,
    this.padding = EvotraqSpacing.cardPad,
    this.brackets = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool brackets;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.border),
        borderRadius: EvotraqRadius.card,
      ),
      child: child,
    );
  }
}

/// Status / identifier chip — accepts a tone via [EvotraqChipTone].
enum EvotraqChipTone { gtin, gln, sgtin, sscc, event, ok, warn, err, muted, live }

class EvotraqChip extends StatelessWidget {
  final String label;
  final EvotraqChipTone tone;
  const EvotraqChip(this.label, {super.key, this.tone = EvotraqChipTone.muted});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Color fg;
    Color bd;
    Color bg;
    switch (tone) {
      case EvotraqChipTone.gtin:
        fg = c.identifierGtin;
        bd = c.identifierGtin.withOpacity(.4);
        bg = c.identifierGtin.withOpacity(.1);
        break;
      case EvotraqChipTone.gln:
        fg = c.identifierGln;
        bd = c.identifierGln.withOpacity(.4);
        bg = c.identifierGln.withOpacity(.1);
        break;
      case EvotraqChipTone.sgtin:
        fg = c.identifierSgtin;
        bd = c.identifierSgtin.withOpacity(.4);
        bg = c.identifierSgtin.withOpacity(.1);
        break;
      case EvotraqChipTone.sscc:
        fg = c.identifierSscc;
        bd = c.identifierSscc.withOpacity(.4);
        bg = c.identifierSscc.withOpacity(.1);
        break;
      case EvotraqChipTone.event:
        fg = c.identifierEvent;
        bd = c.identifierEvent.withOpacity(.4);
        bg = c.identifierEvent.withOpacity(.1);
        break;
      case EvotraqChipTone.ok:
        fg = c.success;
        bd = c.success.withOpacity(.4);
        bg = c.success.withOpacity(.1);
        break;
      case EvotraqChipTone.warn:
        fg = c.warning;
        bd = c.warning.withOpacity(.4);
        bg = c.warning.withOpacity(.1);
        break;
      case EvotraqChipTone.err:
        fg = c.error;
        bd = c.error.withOpacity(.4);
        bg = c.error.withOpacity(.1);
        break;
      case EvotraqChipTone.live:
        fg = c.primary;
        bd = c.primary.withOpacity(.4);
        bg = c.primaryMuted;
        break;
      case EvotraqChipTone.muted:
        fg = c.textMuted;
        bd = c.border;
        bg = c.surfaceMuted;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: EvotraqRadius.chip,
        border: Border.all(color: bd),
      ),
      child: Text(
        label.toUpperCase(),
        style: context.text.mono.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: fg,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

