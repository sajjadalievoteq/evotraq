import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/operation_palette.dart';
import 'package:traqtrace_app/core/widgets/traq_app_bar_flexible_background.dart';

import 'package:traqtrace_app/core/theme/traq_theme_colors.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/theme/traq_theme_typography.dart';
import 'package:traqtrace_app/core/theme/traq_theme_app_bar.dart';
import 'package:traqtrace_app/core/theme/traq_theme_buttons.dart';
import 'package:traqtrace_app/core/theme/traq_theme_cards.dart';
import 'package:traqtrace_app/core/theme/traq_theme_inputs.dart';
import 'package:traqtrace_app/core/theme/traq_theme_menus.dart';
import 'package:traqtrace_app/core/theme/traq_theme_chips.dart';

class TraqTheme {
  static String get appBarBackgroundAsset => TraqThemeAppBar.backgroundAsset;

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
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: c.textMuted.withValues(alpha: 0.30),
        cursorColor: c.primary,
        selectionHandleColor: c.primary,
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
      chipTheme: TraqThemeChips.chip(c, text, onPrimaryInk),
      tabBarTheme: TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.6),
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: Colors.white, width: 2),
          insets: EdgeInsets.zero,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: text.bodySm.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: text.bodySm,
        dividerColor: Colors.transparent,
      ),
      textTheme: TraqText.materialTextTheme(text),
      extensions: <ThemeExtension<dynamic>>[c, TraqTextExt(text)],
    );
  }
}

extension TraqContextX on BuildContext {
  TraqColors get colors => TraqColors.of(this);
  TraqText get text => TraqText.of(this);
  OperationPalette get operationPalette => OperationPalette.of(this);

  Widget get appBarFlexibleBackground =>
      TraqAppBarFlexibleBackground(color: colors.primary);
}

extension TraqSemanticColors on TraqColors {
  Color get statTileIcon => textMuted;
}
