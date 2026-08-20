import 'dart:math' as math;

import 'package:flutter/material.dart';

abstract final class AnchoredSnackBarLayout {
  static const double edgePadding = 16;
  static const double anchorGap = 8;
  static const double maxWidth = 420;
  static const double estimatedHeight = 80;

  static ({double top, double left, double width}) calculate({
    required Rect anchorRect,
    required Size screenSize,
    required EdgeInsets viewPadding,
    double snackbarHeight = estimatedHeight,
  }) {
    final width = math.min(maxWidth, screenSize.width - (edgePadding * 2));

    var left = anchorRect.left;
    if (left + width > screenSize.width - edgePadding) {
      left = screenSize.width - edgePadding - width;
    }
    left = left.clamp(edgePadding, screenSize.width - edgePadding - width);

    final minTop = viewPadding.top + edgePadding;
    final maxBottom = screenSize.height - viewPadding.bottom - edgePadding;
    final maxTop = math.max(minTop, maxBottom - snackbarHeight);
    final belowTop = anchorRect.bottom + anchorGap;
    final placeAbove = snackbarHeight > maxBottom - belowTop;
    final top = placeAbove
        ? anchorRect.top - anchorGap - snackbarHeight
        : belowTop;

    return (top: top.clamp(minTop, maxTop), left: left, width: width);
  }
}
