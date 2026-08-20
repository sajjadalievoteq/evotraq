import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';

enum CustomSnackBarVariant {
  success(AppAssets.iconCheck),
  error(AppAssets.iconAlert),
  warning(AppAssets.iconAlert),
  info(AppAssets.iconInfo);

  const CustomSnackBarVariant(this.iconAsset);

  final String iconAsset;

  Color color(BuildContext context) {
    final colors = context.colors;
    return switch (this) {
      success => colors.success,
      error => colors.error,
      warning => colors.warning,
      info => colors.secondary,
    };
  }
}
