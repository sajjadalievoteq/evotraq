part of 'traq_theme.dart';

abstract final class TraqThemeCards {
  static CardThemeData card(TraqColors c) => CardThemeData(
        color: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: c.border),
          borderRadius: const BorderRadius.all(TraqRadius.md),
        ),
      );

  static DialogThemeData dialog(TraqColors c, ShapeBorder shape) =>
      DialogThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: shape,
      );

  static BottomSheetThemeData bottomSheet(
    TraqColors c,
    Brightness b,
    ShapeBorder shape,
  ) =>
      BottomSheetThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: c.surface,
        modalBarrierColor:
            Colors.black.withOpacity(b == Brightness.dark ? 0.55 : 0.35),
        shape: shape,
      );

  static SnackBarThemeData snackBar(TraqColors c, TraqText text, ShapeBorder shape) =>
      SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.inverseSurface,
        contentTextStyle: text.bodySm.copyWith(color: c.textOnInverse),
        shape: shape,
      );
}
