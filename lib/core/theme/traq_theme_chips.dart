import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme_colors.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/theme/traq_theme_typography.dart';

abstract final class TraqThemeChips {
  static ChipThemeData chip(
    TraqColors c,
    TraqText text,
    Color onPrimary,
  ) => ChipThemeData(
    backgroundColor: c.surfaceMuted,
    selectedColor: c.primary,
    checkmarkColor: onPrimary,
    deleteIconColor: c.textMuted,
    secondarySelectedColor: c.primary,

    labelStyle: text.bodySm.copyWith(
      color: WidgetStateColor.resolveWith(
        (states) =>
            states.contains(WidgetState.selected) ? onPrimary : c.textPrimary,
      ),
      height: 1.2,
    ),
    secondaryLabelStyle: text.bodySm.copyWith(
      color: WidgetStateColor.resolveWith(
        (states) =>
            states.contains(WidgetState.selected) ? onPrimary : c.textPrimary,
      ),
      height: 1.2,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    shape: RoundedRectangleBorder(
      borderRadius: TraqRadius.button,
      side: BorderSide(color: c.borderVariant),
    ),
    showCheckmark: true,
  );
}
