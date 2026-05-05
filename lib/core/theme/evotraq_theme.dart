// Temporary Evotraq UI theme (developer handoff)
// Source: /handoff/flutter/app_theme.dart
//
// NOTE: This file is intentionally kept standalone so it can be
// swapped in/out without touching app logic (routing/blocs/services).

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

@immutable
class EvotraqColors extends ThemeExtension<EvotraqColors> {
  // Surfaces
  final Color bg0;
  final Color bg1;
  final Color bg2;
  final Color bg3;
  final Color bgInv;

  // Lines
  final Color line1;
  final Color line2;
  final Color lineStrong;

  // Text
  final Color fg0;
  final Color fg1;
  final Color fg2;
  final Color fg3;
  final Color fgInv;

  // Signal
  final Color sig;
  final Color sigInk;
  final Color sigSoft;
  final Color sigGlow;

  // Status
  final Color ok;
  final Color warn;
  final Color err;
  final Color info;

  // Identifier coding
  final Color idGtin;
  final Color idGln;
  final Color idSgtin;
  final Color idSscc;
  final Color idEvent;

  const EvotraqColors({
    required this.bg0,
    required this.bg1,
    required this.bg2,
    required this.bg3,
    required this.bgInv,
    required this.line1,
    required this.line2,
    required this.lineStrong,
    required this.fg0,
    required this.fg1,
    required this.fg2,
    required this.fg3,
    required this.fgInv,
    required this.sig,
    required this.sigInk,
    required this.sigSoft,
    required this.sigGlow,
    required this.ok,
    required this.warn,
    required this.err,
    required this.info,
    required this.idGtin,
    required this.idGln,
    required this.idSgtin,
    required this.idSscc,
    required this.idEvent,
  });

  static const dark = EvotraqColors(
    bg0: Color(0xFF1A1B1E),
    bg1: Color(0xFF222428),
    bg2: Color(0xFF2C2E33),
    bg3: Color(0xFF383B41),
    bgInv: Color(0xFFF7F7F5),
    line1: Color(0xFF3D4047),
    line2: Color(0xFF4C5058),
    lineStrong: Color(0xFF6A6F78),
    fg0: Color(0xFFF7F7F5),
    fg1: Color(0xFFCFCFCC),
    fg2: Color(0xFF8E939B),
    fg3: Color(0xFF666B73),
    fgInv: Color(0xFF1A1B1E),
    sig: Color(0xFFC4F03B),
    sigInk: Color(0xFF26321A),
    sigSoft: Color(0x1FC4F03B),
    sigGlow: Color(0x59C4F03B),
    ok: Color(0xFF7BD389),
    warn: Color(0xFFE6B454),
    err: Color(0xFFE85C4A),
    info: Color(0xFF6FB7DC),
    idGtin: Color(0xFF6FB7DC),
    idGln: Color(0xFFA89DDC),
    idSgtin: Color(0xFF5BC2B5),
    idSscc: Color(0xFFE0B070),
    idEvent: Color(0xFFD080CB),
  );

  static const light = EvotraqColors(
    bg0: Color(0xFFFAFAF7),
    bg1: Color(0xFFFFFFFF),
    bg2: Color(0xFFF3F3F0),
    bg3: Color(0xFFEAEAE7),
    bgInv: Color(0xFF222428),
    line1: Color(0xFFE2E2DF),
    line2: Color(0xFFD3D3D0),
    lineStrong: Color(0xFFA6A8AC),
    fg0: Color(0xFF252830),
    fg1: Color(0xFF464A52),
    fg2: Color(0xFF6A6F78),
    fg3: Color(0xFF8E939B),
    fgInv: Color(0xFFF7F7F5),
    sig: Color(0xFF7AAB14),
    sigInk: Color(0xFF26321A),
    sigSoft: Color(0x2EC4D844),
    sigGlow: Color(0x4D7AAB14),
    ok: Color(0xFF4F8B3E),
    warn: Color(0xFFB07A1C),
    err: Color(0xFFB6362B),
    info: Color(0xFF3071A8),
    idGtin: Color(0xFF3071A8),
    idGln: Color(0xFF6A4FA0),
    idSgtin: Color(0xFF2E7B70),
    idSscc: Color(0xFFA06028),
    idEvent: Color(0xFF99457E),
  );

  static EvotraqColors of(BuildContext context) =>
      Theme.of(context).extension<EvotraqColors>()!;

  @override
  EvotraqColors copyWith({
    Color? bg0,
    Color? bg1,
    Color? bg2,
    Color? bg3,
    Color? bgInv,
    Color? line1,
    Color? line2,
    Color? lineStrong,
    Color? fg0,
    Color? fg1,
    Color? fg2,
    Color? fg3,
    Color? fgInv,
    Color? sig,
    Color? sigInk,
    Color? sigSoft,
    Color? sigGlow,
    Color? ok,
    Color? warn,
    Color? err,
    Color? info,
    Color? idGtin,
    Color? idGln,
    Color? idSgtin,
    Color? idSscc,
    Color? idEvent,
  }) =>
      EvotraqColors(
        bg0: bg0 ?? this.bg0,
        bg1: bg1 ?? this.bg1,
        bg2: bg2 ?? this.bg2,
        bg3: bg3 ?? this.bg3,
        bgInv: bgInv ?? this.bgInv,
        line1: line1 ?? this.line1,
        line2: line2 ?? this.line2,
        lineStrong: lineStrong ?? this.lineStrong,
        fg0: fg0 ?? this.fg0,
        fg1: fg1 ?? this.fg1,
        fg2: fg2 ?? this.fg2,
        fg3: fg3 ?? this.fg3,
        fgInv: fgInv ?? this.fgInv,
        sig: sig ?? this.sig,
        sigInk: sigInk ?? this.sigInk,
        sigSoft: sigSoft ?? this.sigSoft,
        sigGlow: sigGlow ?? this.sigGlow,
        ok: ok ?? this.ok,
        warn: warn ?? this.warn,
        err: err ?? this.err,
        info: info ?? this.info,
        idGtin: idGtin ?? this.idGtin,
        idGln: idGln ?? this.idGln,
        idSgtin: idSgtin ?? this.idSgtin,
        idSscc: idSscc ?? this.idSscc,
        idEvent: idEvent ?? this.idEvent,
      );

  @override
  EvotraqColors lerp(ThemeExtension<EvotraqColors>? other, double t) {
    if (other is! EvotraqColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return EvotraqColors(
      bg0: l(bg0, other.bg0),
      bg1: l(bg1, other.bg1),
      bg2: l(bg2, other.bg2),
      bg3: l(bg3, other.bg3),
      bgInv: l(bgInv, other.bgInv),
      line1: l(line1, other.line1),
      line2: l(line2, other.line2),
      lineStrong: l(lineStrong, other.lineStrong),
      fg0: l(fg0, other.fg0),
      fg1: l(fg1, other.fg1),
      fg2: l(fg2, other.fg2),
      fg3: l(fg3, other.fg3),
      fgInv: l(fgInv, other.fgInv),
      sig: l(sig, other.sig),
      sigInk: l(sigInk, other.sigInk),
      sigSoft: l(sigSoft, other.sigSoft),
      sigGlow: l(sigGlow, other.sigGlow),
      ok: l(ok, other.ok),
      warn: l(warn, other.warn),
      err: l(err, other.err),
      info: l(info, other.info),
      idGtin: l(idGtin, other.idGtin),
      idGln: l(idGln, other.idGln),
      idSgtin: l(idSgtin, other.idSgtin),
      idSscc: l(idSscc, other.idSscc),
      idEvent: l(idEvent, other.idEvent),
    );
  }
}

class EvotraqText {
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
    // `geistTextTheme` is not available in all google_fonts versions.
    // Use the stable runtime API so this file works across versions.
    final geist = GoogleFonts.getTextTheme('Geist');
    final mono = GoogleFonts.getTextTheme('JetBrains Mono');

    TextStyle g(TextStyle? base) =>
        (base ?? const TextStyle()).copyWith(color: c.fg0);
    TextStyle m(TextStyle? base) =>
        (base ?? const TextStyle()).copyWith(color: c.fg0);

    final display = g(geist.displayLarge).copyWith(
      fontSize: 56,
      height: 1.0,
      letterSpacing: -1.68,
      fontWeight: FontWeight.w600,
    );
    final h1 = g(geist.headlineLarge).copyWith(
      fontSize: 32,
      height: 1.1,
      letterSpacing: -0.64,
      fontWeight: FontWeight.w600,
    );
    final h2 = g(geist.headlineMedium).copyWith(
      fontSize: 22,
      height: 1.2,
      letterSpacing: -0.33,
      fontWeight: FontWeight.w600,
    );
    final h3 = g(geist.titleMedium).copyWith(
      fontSize: 16,
      height: 1.3,
      letterSpacing: -0.08,
      fontWeight: FontWeight.w600,
    );
    final body = g(geist.bodyMedium).copyWith(
      fontSize: 14,
      height: 1.5,
      fontWeight: FontWeight.w400,
    );
    final bodySm = g(geist.bodySmall).copyWith(
      fontSize: 13,
      height: 1.45,
      fontWeight: FontWeight.w400,
    );
    final cap = g(geist.labelSmall).copyWith(
      fontSize: 11,
      height: 1.3,
      letterSpacing: 0.88,
      fontWeight: FontWeight.w500,
      color: c.fg2,
    );
    final monoBase = m(mono.bodyMedium).copyWith(
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

  static List<BoxShadow> sigGlow(EvotraqColors c) => [
        BoxShadow(color: c.sigGlow, blurRadius: 16, spreadRadius: -2),
      ];
}

class EvotraqTheme {
  static ThemeData dark() => _build(EvotraqColors.dark, Brightness.dark);
  static ThemeData light() => _build(EvotraqColors.light, Brightness.light);

  static ThemeData _build(EvotraqColors c, Brightness b) {
    final text = EvotraqText.build(c);

    return ThemeData(
      brightness: b,
      useMaterial3: true,
      scaffoldBackgroundColor: c.bg0,
      canvasColor: c.bg0,
      dividerColor: c.line1,
      hintColor: c.fg3,
      colorScheme: ColorScheme(
        brightness: b,
        primary: c.sig,
        // For Evotraq filled buttons we want:
        // - light mode: white text/icons on green
        // - dark mode: slightly gray text/icons on lime
        onPrimary: b == Brightness.dark ? c.fg1 : Colors.white,
        secondary: c.fg1,
        onSecondary: c.bg0,
        error: c.err,
        onError: c.fgInv,
        surface: c.bg1,
        onSurface: c.fg0,
        surfaceContainerHighest: c.bg2,
        outline: c.line2,
        outlineVariant: c.line1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.bg0,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: text.body.copyWith(color: c.fg3),
        labelStyle: text.cap.copyWith(color: c.fg2),
        border: OutlineInputBorder(
          borderRadius: EvotraqRadius.input,
          borderSide: BorderSide(color: c.line1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: EvotraqRadius.input,
          borderSide: BorderSide(color: c.line1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: EvotraqRadius.input,
          borderSide: BorderSide(color: c.sig, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: EvotraqRadius.input,
          borderSide: BorderSide(color: c.err),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.sig,
          // Handoff token `sigInk` is great for dark text, but for buttons we want:
          // - light mode: white text on green
          // - dark mode: slightly gray text on lime
          foregroundColor: b == Brightness.dark ? c.fg1 : Colors.white,
          textStyle: text.bodySm.copyWith(fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: const RoundedRectangleBorder(borderRadius: EvotraqRadius.button),
          minimumSize: const Size(0, EvotraqSpacing.buttonH),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.sig,
          foregroundColor: b == Brightness.dark ? c.fg1 : Colors.white,
          textStyle: text.bodySm.copyWith(fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: const RoundedRectangleBorder(borderRadius: EvotraqRadius.button),
          minimumSize: const Size(0, EvotraqSpacing.buttonH),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: c.bg2,
          foregroundColor: c.fg0,
          side: BorderSide(color: c.line2),
          textStyle: text.bodySm.copyWith(fontWeight: FontWeight.w500),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: const RoundedRectangleBorder(borderRadius: EvotraqRadius.button),
          minimumSize: const Size(0, EvotraqSpacing.buttonH),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.fg0,
          textStyle: text.bodySm,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: const RoundedRectangleBorder(borderRadius: EvotraqRadius.button),
        ),
      ),
      cardTheme: CardThemeData(
        color: c.bg1,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: c.line1),
          borderRadius: const BorderRadius.all(EvotraqRadius.md),
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

/// Convenience semantic aliases for handoff tokens.
///
/// This does **not** change any handoff constants; it only provides readable
/// names (primary/secondary/background/etc.) that map onto Evotraq tokens.
extension EvotraqSemanticColors on EvotraqColors {
  Color get primary => sig;
  Color get onPrimary => sigInk;
  Color get primarySoft => sigSoft;
  Color get primaryGlow => sigGlow;

  Color get background => bg0;
  Color get surface => bg1;
  Color get surfaceAlt => bg2;
  Color get border => line1;
  Color get borderStrong => lineStrong;

  Color get textPrimary => fg0;
  Color get textSecondary => fg1;
  Color get textMuted => fg2;
  Color get textFaint => fg3;
  Color get textOnInverse => fgInv;

  Color get success => ok;
  Color get warning => warn;
  Color get danger => err;
  Color get infoBlue => info;
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
        color: c.bg1,
        border: Border.all(color: c.line1),
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
        fg = c.idGtin;
        bd = c.idGtin.withOpacity(.4);
        bg = c.idGtin.withOpacity(.1);
        break;
      case EvotraqChipTone.gln:
        fg = c.idGln;
        bd = c.idGln.withOpacity(.4);
        bg = c.idGln.withOpacity(.1);
        break;
      case EvotraqChipTone.sgtin:
        fg = c.idSgtin;
        bd = c.idSgtin.withOpacity(.4);
        bg = c.idSgtin.withOpacity(.1);
        break;
      case EvotraqChipTone.sscc:
        fg = c.idSscc;
        bd = c.idSscc.withOpacity(.4);
        bg = c.idSscc.withOpacity(.1);
        break;
      case EvotraqChipTone.event:
        fg = c.idEvent;
        bd = c.idEvent.withOpacity(.4);
        bg = c.idEvent.withOpacity(.1);
        break;
      case EvotraqChipTone.ok:
        fg = c.ok;
        bd = c.ok.withOpacity(.4);
        bg = c.ok.withOpacity(.1);
        break;
      case EvotraqChipTone.warn:
        fg = c.warn;
        bd = c.warn.withOpacity(.4);
        bg = c.warn.withOpacity(.1);
        break;
      case EvotraqChipTone.err:
        fg = c.err;
        bd = c.err.withOpacity(.4);
        bg = c.err.withOpacity(.1);
        break;
      case EvotraqChipTone.live:
        fg = c.sig;
        bd = c.sig.withOpacity(.4);
        bg = c.sigSoft;
        break;
      case EvotraqChipTone.muted:
        fg = c.fg2;
        bd = c.line1;
        bg = c.bg2;
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

