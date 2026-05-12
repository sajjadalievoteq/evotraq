part of 'traq_theme.dart';

/// Filled, elevated, outlined, and text button themes for Traq.
abstract final class TraqThemeButtons {
  static FilledButtonThemeData filled(
    TraqColors c,
    TraqText text,
    Color onPrimaryInk,
  ) =>
      FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.primary,
          // `onPrimary` token is for ink on brand fills; buttons use white / muted text.
          foregroundColor: onPrimaryInk,
          textStyle: text.bodySm.copyWith(fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: const RoundedRectangleBorder(borderRadius: TraqRadius.button),
          minimumSize: const Size(0, TraqSpacing.buttonH),
        ),
      );

  static ElevatedButtonThemeData elevated(
    TraqColors c,
    TraqText text,
    Color onPrimaryInk,
  ) =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: onPrimaryInk,
          textStyle: text.bodySm.copyWith(fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: const RoundedRectangleBorder(borderRadius: TraqRadius.button),
          minimumSize: const Size(0, TraqSpacing.buttonH),
        ),
      );

  static OutlinedButtonThemeData outlined(TraqColors c, TraqText text) =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: c.surfaceMuted,
          foregroundColor: c.textPrimary,
          side: BorderSide(color: c.borderVariant),
          textStyle: text.bodySm.copyWith(fontWeight: FontWeight.w500),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: const RoundedRectangleBorder(borderRadius: TraqRadius.button),
          minimumSize: const Size(0, TraqSpacing.buttonH),
        ),
      );

  static TextButtonThemeData text(TraqColors c, TraqText text) =>
      TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.textPrimary,
          textStyle: text.bodySm,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: const RoundedRectangleBorder(borderRadius: TraqRadius.button),
        ),
      );
}
