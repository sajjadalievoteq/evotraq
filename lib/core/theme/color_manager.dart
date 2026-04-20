import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/app_theme.dart';

class ColorManager {
  const ColorManager._();

  static Brightness systemBrightness(BuildContext context) =>
      MediaQuery.platformBrightnessOf(context);

  static bool isDark(BuildContext context) =>
      systemBrightness(context) == Brightness.dark;

  static Color primary(BuildContext context) =>
      isDark(context) ? AppTheme.primaryColorDark : AppTheme.primaryColor;

  static Color accent(BuildContext context) =>
      isDark(context) ? AppTheme.accentColorDark : AppTheme.accentColor;

  static Color background(BuildContext context) => isDark(context)
      ? AppTheme.backgroundColorDark
      : AppTheme.backgroundColor;

  static Color surface(BuildContext context) =>
      isDark(context) ? AppTheme.surfaceColorDark : AppTheme.surfaceColor;

  static Color card(BuildContext context) =>
      isDark(context) ? AppTheme.cardColorDark : AppTheme.cardColor;

  static Color textPrimary(BuildContext context) =>
      isDark(context) ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;

  static Color textSecondary(BuildContext context) => isDark(context)
      ? AppTheme.textSecondaryDark
      : AppTheme.textSecondaryLight;

  static Color highlight(BuildContext context) => isDark(context)
      ? AppTheme.highlightColorDark
      : AppTheme.highlightColor;

  static Color success(BuildContext context) => AppTheme.successColor;
  static Color error(BuildContext context) => AppTheme.errorColor;
  static Color warning(BuildContext context) => AppTheme.warningColor;
  static Color info(BuildContext context) => AppTheme.infoColor;

  static Color primaryContainer(BuildContext context) =>
      primary(context).withOpacity(isDark(context) ? 0.22 : 0.12);

  static Color primaryBorder(BuildContext context) =>
      primary(context).withOpacity(isDark(context) ? 0.35 : 0.25);

  static Color primaryTrack(BuildContext context) =>
      primary(context).withOpacity(isDark(context) ? 0.18 : 0.12);
}

