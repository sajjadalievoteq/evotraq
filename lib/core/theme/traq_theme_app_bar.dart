import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme_colors.dart';
import 'package:traqtrace_app/core/theme/traq_theme_typography.dart';

abstract final class TraqThemeAppBar {
  static const String backgroundAsset = AppAssets.traqBackgroundSvg;

  static const String logoutActionIconAsset = AppAssets.iconLogout;
  static const String logoutActionTooltip = 'Log out';

  static AppBarThemeData appBarTheme(TraqColors c, TraqText text) =>
      AppBarThemeData(
        backgroundColor: c.primary,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: c.primary,
        foregroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: text.body.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      );
}
