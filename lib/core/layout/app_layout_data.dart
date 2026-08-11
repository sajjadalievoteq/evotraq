import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';

enum AppLayoutBreakpoint { compact, medium, expanded, large }

@immutable
class AppLayoutData {
  const AppLayoutData({
    required this.width,
    required this.height,
    required this.breakpoint,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.maxContentWidth,
    required this.columns,
  });

  factory AppLayoutData.fromSize(Size size) {
    final width = size.width;
    final breakpoint = switch (width) {
      < 600 => AppLayoutBreakpoint.compact,
      < 840 => AppLayoutBreakpoint.medium,
      < 1200 => AppLayoutBreakpoint.expanded,
      _ => AppLayoutBreakpoint.large,
    };
    return AppLayoutData(
      width: width,
      height: size.height,
      breakpoint: breakpoint,
      horizontalPadding: ResponsiveUtils.gutterForWidth(width),
      verticalPadding: ResponsiveUtils.gutterForWidth(width) * 0.8,
      maxContentWidth: switch (breakpoint) {
        AppLayoutBreakpoint.compact => 600,
        AppLayoutBreakpoint.medium => 760,
        AppLayoutBreakpoint.expanded => 1040,
        AppLayoutBreakpoint.large => 1280,
      },
      columns: switch (breakpoint) {
        AppLayoutBreakpoint.compact => 4,
        AppLayoutBreakpoint.medium => 8,
        AppLayoutBreakpoint.expanded || AppLayoutBreakpoint.large => 12,
      },
    );
  }

  final double width;
  final double height;
  final AppLayoutBreakpoint breakpoint;
  final double horizontalPadding;
  final double verticalPadding;
  final double maxContentWidth;
  final int columns;

  bool get isCompact => breakpoint == AppLayoutBreakpoint.compact;
  bool get isMedium => breakpoint == AppLayoutBreakpoint.medium;
  bool get isExpanded => breakpoint == AppLayoutBreakpoint.expanded;
  bool get isLarge => breakpoint == AppLayoutBreakpoint.large;
  bool get isTabletUp => isMedium || isExpanded || isLarge;
  bool get isDesktopUp => isExpanded || isLarge;
  String get breakpointName => breakpoint.name;

  T resolve<T>({required T compact, T? medium, T? expanded, T? large}) {
    return switch (breakpoint) {
      AppLayoutBreakpoint.compact => compact,
      AppLayoutBreakpoint.medium => medium ?? compact,
      AppLayoutBreakpoint.expanded => expanded ?? medium ?? compact,
      AppLayoutBreakpoint.large => large ?? expanded ?? medium ?? compact,
    };
  }
}

extension AppLayoutContextExtension on BuildContext {
  AppLayoutData get layout => AppLayoutData.fromSize(MediaQuery.sizeOf(this));
}
