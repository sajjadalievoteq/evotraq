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
          textStyle: text.bodySm.copyWith(fontWeight: FontWeight.w600, height: 1.0),
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
          textStyle: text.bodySm.copyWith(fontWeight: FontWeight.w600, height: 1.0),
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
          textStyle: text.bodySm.copyWith(fontWeight: FontWeight.w500, height: 1.0),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: const RoundedRectangleBorder(borderRadius: TraqRadius.button),
          minimumSize: const Size(0, TraqSpacing.buttonH),
        ),
      );

  static TextButtonThemeData text(TraqColors c, TraqText text) =>
      TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.textPrimary,
          textStyle: text.bodySm.copyWith(height: 1.0),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: const RoundedRectangleBorder(borderRadius: TraqRadius.button),
        ),
      );

  static SegmentedButtonThemeData segmented(TraqColors c, TraqText text) =>
      SegmentedButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStatePropertyAll(
            text.bodySm.copyWith(fontWeight: FontWeight.w500, height: 1.0),
          ),
          // Selected segment
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return c.primary;
            return c.surfaceMuted;
          }),

          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return c.onPrimary;
            return c.textSecondary;
          }),
          side: WidgetStatePropertyAll(BorderSide(color: c.borderVariant)),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: TraqRadius.button),
          ),
          minimumSize: const WidgetStatePropertyAll(Size(0, TraqSpacing.buttonH)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 14, vertical: 0),
          ),
        ),
      );
}
