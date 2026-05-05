import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/constants.dart';

/// Screen-width–based spacing. Use [gutter] as the single numeric token anywhere
/// you need a consistent inset: `EdgeInsets.only(left: context.gutter)`, etc.
///
/// Banding matches [ResponsiveContext.isMobile] / [isTablet] / [isDesktop]:
/// - **Mobile** (< 600): [Constants.mobilePadding]
/// - **Tablet** (600–1199): [Constants.tabletPadding] (40)
/// - **Desktop / web** (≥ 1200): [Constants.webPadding]
class ResponsiveUtils {
  /// Responsive page gutter / inset unit for the current width.
  static double gutter(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 600) {
      return Constants.mobilePadding;
    }
    if (width < 1200) {
      return Constants.tabletPadding;
    }
    return Constants.webPadding;
  }

  /// Symmetric horizontal inset: left & right = [gutter].
  static EdgeInsets horizontalPadding(BuildContext context) {
    final g = gutter(context);
    return EdgeInsets.symmetric(horizontal: g);
  }

  /// Symmetric vertical inset: top & bottom = [gutter].
  static EdgeInsets verticalPadding(BuildContext context) {
    final g = gutter(context);
    return EdgeInsets.symmetric(vertical: g);
  }

  /// Same inset on all sides = [gutter].
  static EdgeInsets paddingAll(BuildContext context) {
    final g = gutter(context);
    return EdgeInsets.all(g);
  }

  /// Per-edge inset using only [gutter] where a flag is true; others are 0.
  /// Example: `gutterOnly(context, left: true, top: true)`
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

  /// Symmetric inset as multiples of [gutter], e.g. `horizontal: 2` → `2 * gutter` on left/right.
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

  /// [horizontal] / [vertical] are multiples of [gutter] (e.g. `2` → double inset).
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
