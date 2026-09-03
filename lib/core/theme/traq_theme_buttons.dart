import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme_colors.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/theme/traq_theme_typography.dart';

abstract final class TraqThemeButtons {
  static TextStyle _label(TraqText text, {FontWeight? weight}) =>
      text.bodySm.copyWith(
        fontWeight: weight ?? FontWeight.w600,
        height: 1.2,
        leadingDistribution: TextLeadingDistribution.even,
      );

  /// Full-width CTAs that already have a fixed [height] should not also eat
  /// vertical padding from the theme — that combination clips label glyphs.
  static ButtonStyle fixedHeight(double height) => ButtonStyle(
    visualDensity: VisualDensity.standard,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 14)),
    minimumSize: WidgetStatePropertyAll(Size(0, height)),
  );

  static FilledButtonThemeData filled(
    TraqColors c,
    TraqText text,
    Color onPrimaryInk,
  ) => FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: c.primary,
      foregroundColor: onPrimaryInk,
      textStyle: _label(text),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      visualDensity: VisualDensity.standard,
      shape: const RoundedRectangleBorder(borderRadius: TraqRadius.button),
      minimumSize: const Size(0, TraqSpacing.buttonH),
    ),
  );

  static ElevatedButtonThemeData elevated(
    TraqColors c,
    TraqText text,
    Color onPrimaryInk,
  ) => ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: c.primary,
      foregroundColor: onPrimaryInk,
      textStyle: _label(text),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      visualDensity: VisualDensity.standard,
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
          textStyle: _label(text, weight: FontWeight.w500),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          visualDensity: VisualDensity.standard,
          shape: const RoundedRectangleBorder(borderRadius: TraqRadius.button),
          minimumSize: const Size(0, TraqSpacing.buttonH),
        ),
      );

  static TextButtonThemeData text(TraqColors c, TraqText text) =>
      TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.textPrimary,
          textStyle: _label(text, weight: FontWeight.w400),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          visualDensity: VisualDensity.standard,
          shape: const RoundedRectangleBorder(borderRadius: TraqRadius.button),
        ),
      );

  static SegmentedButtonThemeData segmented(
    TraqColors c,
    TraqText text,
  ) => SegmentedButtonThemeData(
    style: ButtonStyle(
      visualDensity: VisualDensity.standard,
      textStyle: WidgetStatePropertyAll(_label(text, weight: FontWeight.w500)),
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
