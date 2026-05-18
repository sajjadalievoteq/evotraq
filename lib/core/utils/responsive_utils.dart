import 'package:flutter/material.dart';

/// Screen-width–based spacing. Use [gutter] as the single numeric token anywhere
/// you need a consistent inset: `EdgeInsets.only(left: context.gutter)`, etc.
class ResponsiveUtils {
  /// Responsive page gutter / inset unit for a specific width.
  static double gutterForWidth(double width) {
    // Completely fluid: 5% of screen width, clamped between 16 and 100.
    return (width * 0.03).clamp(24.0, 100.0);
  }

  /// Responsive page gutter / inset unit for the current context.
  static double gutter(BuildContext context) {
    return gutterForWidth(MediaQuery.sizeOf(context).width);
  }

  /// Symmetric horizontal inset: left & right = [gutter].
  static EdgeInsets horizontalPadding(BuildContext context) {
    return EdgeInsets.symmetric(horizontal: gutter(context));
  }

  /// Symmetric vertical inset: top & bottom = [gutter].
  static EdgeInsets verticalPadding(BuildContext context) {
    return EdgeInsets.symmetric(vertical: gutter(context));
  }

  /// Same inset on all sides = [gutter].
  static EdgeInsets paddingAll(BuildContext context) {
    return EdgeInsets.all(gutter(context));
  }

  /// Per-edge inset using only [gutter] where a flag is true; others are 0.
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

  /// Symmetric inset as multiples of [gutter].
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
  /// Single value: use with `EdgeInsets.only(left: gutter, ...)`, `SizedBox(height: gutter)`, etc.
  double get gutter => ResponsiveUtils.gutter(this);

  EdgeInsets get horizontalPadding => ResponsiveUtils.horizontalPadding(this);
  EdgeInsets get verticalPadding => ResponsiveUtils.verticalPadding(this);

  /// All sides use [gutter].
  EdgeInsets get padding => ResponsiveUtils.paddingAll(this);

  /// Per-side; only selected edges use [gutter].
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

  /// [horizontal] / [vertical] are multiples of [gutter].
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
