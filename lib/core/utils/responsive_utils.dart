import 'package:flutter/material.dart';

class ResponsiveUtils {
  static double gutterForWidth(double width) {
    return (width * 0.03).clamp(24.0, 100.0);
  }

  static double gutter(BuildContext context) {
    return gutterForWidth(MediaQuery.sizeOf(context).width);
  }

  static EdgeInsets horizontalPadding(BuildContext context) {
    return EdgeInsets.symmetric(horizontal: gutter(context));
  }

  static EdgeInsets verticalPadding(BuildContext context) {
    return EdgeInsets.symmetric(vertical: gutter(context));
  }

  static EdgeInsets paddingAll(BuildContext context) {
    return EdgeInsets.all(gutter(context));
  }

  static EdgeInsets gutterOnly(
    BuildContext context, {
    bool left = false,
    bool top = false,
    bool right = false,
    bool bottom = false,
  }) {
    final g = gutter(context);
    return EdgeInsets.only(
      left: left ? g : 0,
      top: top ? g : 0,
      right: right ? g : 0,
      bottom: bottom ? g : 0,
    );
  }

  static EdgeInsets symmetricMultiples(
    BuildContext context, {
    double horizontal = 0,
    double vertical = 0,
  }) {
    final g = gutter(context);
    return EdgeInsets.symmetric(
      horizontal: g * horizontal,
      vertical: g * vertical,
    );
  }
}

extension ResponsiveContext on BuildContext {
  double get gutter => ResponsiveUtils.gutter(this);

  EdgeInsets get horizontalPadding => ResponsiveUtils.horizontalPadding(this);
  EdgeInsets get verticalPadding => ResponsiveUtils.verticalPadding(this);

  EdgeInsets get padding => ResponsiveUtils.paddingAll(this);

  EdgeInsets gutterOnly({
    bool left = false,
    bool top = false,
    bool right = false,
    bool bottom = false,
  }) =>
      ResponsiveUtils.gutterOnly(
        this,
        left: left,
        top: top,
        right: right,
        bottom: bottom,
      );

  EdgeInsets symmetricPaddingMultiples({
    double horizontal = 0,
    double vertical = 0,
  }) =>
      ResponsiveUtils.symmetricMultiples(
        this,
        horizontal: horizontal,
        vertical: vertical,
      );

  bool get isMobile => MediaQuery.sizeOf(this).width < 600;
  bool get isTablet =>
      MediaQuery.sizeOf(this).width >= 600 && MediaQuery.sizeOf(this).width < 1200;
  bool get isDesktop => MediaQuery.sizeOf(this).width >= 1200;
}
