part of 'traq_theme.dart';

class TraqText {
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

  const TraqText._({
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

  factory TraqText.build(TraqColors c) {
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

    return TraqText._(
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

  static TraqText of(BuildContext context) =>
      Theme.of(context).extension<_TraqTextExt>()!.text;

  static TextTheme materialTextTheme(TraqText text) => TextTheme(
        displayLarge: text.display,
        headlineLarge: text.h1,
        headlineMedium: text.h2,
        titleMedium: text.h3,
        bodyMedium: text.body,
        bodySmall: text.bodySm,
        labelSmall: text.cap,
      );
}

class _TraqTextExt extends ThemeExtension<_TraqTextExt> {
  final TraqText text;
  const _TraqTextExt(this.text);

  @override
  _TraqTextExt copyWith({TraqText? text}) => _TraqTextExt(text ?? this.text);

  @override
  _TraqTextExt lerp(ThemeExtension<_TraqTextExt>? other, double t) => this;
}
