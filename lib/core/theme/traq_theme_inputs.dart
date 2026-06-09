part of 'traq_theme.dart';

abstract final class TraqThemeInputs {
  static SwitchThemeData switchTheme(TraqColors c, Brightness b) =>
      SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return c.textFaint.withOpacity(0.6);
          }
          if (states.contains(WidgetState.selected)) {
            return c.primary;
          }

          return c.surfaceElevated;
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
          if (states.contains(WidgetState.hovered)) {
            return Colors.transparent;
          }
          if (states.contains(WidgetState.focused) ||
              states.contains(WidgetState.pressed)) {
            return c.primary.withOpacity(0.12);
          }
          return null;
        }),
      );

  static InputDecorationTheme inputDecoration(TraqColors c, TraqText text) =>
      InputDecorationTheme(
        filled: true,
        fillColor: c.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: text.body.copyWith(color: c.textFaint),
        labelStyle: text.cap.copyWith(color: c.textMuted),
        border: OutlineInputBorder(
          borderRadius: TraqRadius.input,
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: TraqRadius.input,
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: TraqRadius.input,
          borderSide: BorderSide(color: c.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: TraqRadius.input,
          borderSide: BorderSide(color: c.error),
        ),
      );
}
