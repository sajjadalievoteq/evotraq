import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';

abstract final class AppDrawerMetrics {
  AppDrawerMetrics._();

  static const ShapeBorder shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.only(
      topRight: Radius.zero,
      bottomRight: Radius.zero,
    ),
  );

  static double widthFor(AppLayoutData layout) {
    return layout.resolve<double>(
      compact: (layout.width * 0.88).clamp(240.0, 280.0),
      medium: 300,
      expanded: 300,
      large: (layout.width * 0.20).clamp(300.0, 340.0),
    );
  }
}
