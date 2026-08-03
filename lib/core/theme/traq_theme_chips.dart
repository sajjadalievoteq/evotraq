part of 'traq_theme.dart';

abstract final class TraqThemeChips {
  static ChipThemeData chip(TraqColors c, TraqText text, Color onPrimary) =>
      ChipThemeData(
        backgroundColor: c.surfaceMuted,
        selectedColor: c.primary,
        checkmarkColor: onPrimary,
        deleteIconColor: c.textMuted,
        secondarySelectedColor: c.primary,
        // FilterChip only resolves [TextStyle.color] as a WidgetStateProperty
        // (selected / disabled / …). WidgetStateTextStyle on the whole style
        // is ignored for selection, which left selected labels dark on primary.
        labelStyle: text.bodySm.copyWith(
          color: WidgetStateColor.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? onPrimary
                : c.textPrimary,
          ),
          height: 1.0,
        ),
        secondaryLabelStyle: text.bodySm.copyWith(
          color: WidgetStateColor.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? onPrimary
                : c.textPrimary,
          ),
          height: 1.0,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: TraqRadius.button,
          side: BorderSide(color: c.borderVariant),
        ),
        showCheckmark: true,
      );
}
