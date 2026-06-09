part of 'traq_theme.dart';

@immutable
class TraqColors extends ThemeExtension<TraqColors> {
  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color surfaceElevated;
  final Color inverseSurface;

  final Color border;
  final Color borderVariant;
  final Color borderStrong;

  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textFaint;
  final Color textOnInverse;

  final Color primary;
  final Color onPrimary;
  final Color primaryMuted;
  final Color primaryGlow;

  final Color secondary;

  final Color success;
  final Color warning;
  final Color error;

  final Color identifierGtin;
  final Color identifierGln;
  final Color identifierSgtin;
  final Color identifierSscc;
  final Color identifierEvent;

  const TraqColors({
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

  static final dark = TraqColors(
    background: const Color(0xFF1c1c1b),
    surface: const Color(0xFF181A1E),
    surfaceMuted: const Color(0xFF22252A),
    surfaceElevated: const Color(0xFF2C3036),
    inverseSurface: Color(0xFFF7F7F5),
    border: Color(0xFF3D4047),
    borderVariant: Color(0xFF4C5058),
    borderStrong: Color(0xFF6A6F78),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFCFCFCC),
    textMuted: Color(0xFF8E939B),
    textFaint: Color(0xFF666B73),
    textOnInverse: Color(0xFF1A1B1E),
    primary: Color(0xFF5f0f26),
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

  static final light = TraqColors(
    background: const Color(0xFFF2F2EF),

    surface: const Color(0xFFFFFFFF),
    surfaceMuted: const Color(0xFFE3E3DE),
    surfaceElevated: const Color(0xFFD8D8D2),
    inverseSurface: Color(0xFF222428),
    border: Color(0xFFE2E2DF),
    borderVariant: Color(0xFFD3D3D0),
    borderStrong: Color(0xFFA6A8AC),
    textPrimary: Color(0xFF000000),
    textSecondary: Color(0xFF464A52),
    textMuted: Color(0xFF6A6F78),
    textFaint: Color(0xFF8E939B),
    textOnInverse: Color(0xFFF7F7F5),
    primary: Color(0xFF5f0f26),
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

  static TraqColors of(BuildContext context) =>
      Theme.of(context).extension<TraqColors>()!;

  @override
  TraqColors copyWith({
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
      TraqColors(
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
  TraqColors lerp(ThemeExtension<TraqColors>? other, double t) {
    if (other is! TraqColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return TraqColors(
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
