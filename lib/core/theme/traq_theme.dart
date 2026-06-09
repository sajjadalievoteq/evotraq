import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/shared/utils/app_screen_util.dart';

part 'traq_theme_colors.dart';
part 'traq_theme_tokens.dart';
part 'traq_theme_typography.dart';
part 'traq_theme_app_bar.dart';
part 'traq_theme_buttons.dart';
part 'traq_theme_cards.dart';
part 'traq_theme_inputs.dart';
part 'traq_theme_menus.dart';
part 'traq_theme_widgets.dart';

class TraqTheme {
  static String get appBarBackgroundAsset => TraqThemeAppBar.backgroundAsset;

  static Widget appBarFlexibleBackground(TraqColors c) =>
      TraqThemeAppBar.flexibleBackground(c);

  static ThemeData dark() => _build(TraqColors.dark, Brightness.dark);
  static ThemeData light() => _build(TraqColors.light, Brightness.light);

  static ThemeData _build(TraqColors c, Brightness b) {
    final text = TraqText.build(c);
    final onPrimaryInk = b == Brightness.dark ? c.textSecondary : Colors.white;

    final roundedMd = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(TraqRadius.md),
    );

    final roundedLg = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(TraqRadius.lg),
    );

    return ThemeData(
      brightness: b,
      useMaterial3: true,
      fontFamily: TraqText.fontFamily,
      scaffoldBackgroundColor: c.background,
      canvasColor: c.background,
      dividerColor: c.border,
      hintColor: c.textFaint,
      switchTheme: TraqThemeInputs.switchTheme(c, b),
      colorScheme: ColorScheme(
        brightness: b,
        primary: c.primary,
        onPrimary: onPrimaryInk,
        secondary: c.secondary,
        onSecondary: Colors.white,
        error: c.error,
        onError: c.textOnInverse,
        surface: c.surface,
        onSurface: c.textPrimary,
        surfaceContainerHighest: c.surfaceMuted,
        outline: c.borderVariant,
        outlineVariant: c.border,
      ),
      appBarTheme: TraqThemeAppBar.appBarTheme(c, text),
      inputDecorationTheme: TraqThemeInputs.inputDecoration(c, text),
      filledButtonTheme: TraqThemeButtons.filled(c, text, onPrimaryInk),
      elevatedButtonTheme: TraqThemeButtons.elevated(c, text, onPrimaryInk),
      outlinedButtonTheme: TraqThemeButtons.outlined(c, text),
      textButtonTheme: TraqThemeButtons.text(c, text),
      segmentedButtonTheme: TraqThemeButtons.segmented(c, text),
      cardTheme: TraqThemeCards.card(c),
      dialogTheme: TraqThemeCards.dialog(c, roundedLg),
      bottomSheetTheme: TraqThemeCards.bottomSheet(c, b, roundedLg),
      snackBarTheme: TraqThemeCards.snackBar(c, text, roundedMd),
      popupMenuTheme: TraqThemeMenus.popupMenu(c, roundedMd),
      menuTheme: TraqThemeMenus.menu(c, roundedMd),
      dropdownMenuTheme: TraqThemeMenus.dropdown(c, roundedMd),
      textTheme: TraqText.materialTextTheme(text),
      extensions: <ThemeExtension<dynamic>>[
        c,
        _TraqTextExt(text),
      ],
    );
  }
}

extension TraqContextX on BuildContext {
  TraqColors get colors => TraqColors.of(this);
  TraqText get text => TraqText.of(this);

  Widget get appBarFlexibleBackground =>
      TraqTheme.appBarFlexibleBackground(colors);
}

extension TraqSemanticColors on TraqColors {
  Color get statTileIcon => textMuted;
}
