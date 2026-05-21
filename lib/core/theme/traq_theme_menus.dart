part of 'traq_theme.dart';

/// Popup menu, menu, and dropdown menu themes for Traq.
abstract final class TraqThemeMenus {
  static PopupMenuThemeData popupMenu(TraqColors c, ShapeBorder shape) =>
      PopupMenuThemeData(
        color: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: shape,
      );

  static MenuThemeData menu(TraqColors c, OutlinedBorder shape) => MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(c.surface),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(shape),
        ),
      );

  static DropdownMenuThemeData dropdown(TraqColors c, OutlinedBorder shape) =>
      DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(c.surface),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(shape),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          labelStyle: TextStyle(
              fontSize: 10,
                  fontWeight: FontWeight.w400
          ),
          hintStyle: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w400
          ),
          fillColor: c.background,
          border: OutlineInputBorder(
            borderRadius: TraqRadius.input,
            borderSide: BorderSide(color: c.border),
          ),
        ),
      );
}
