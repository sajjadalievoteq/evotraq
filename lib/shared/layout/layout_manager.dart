import 'package:flutter/material.dart';

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
      horizontalPadding: switch (breakpoint) {
        AppLayoutBreakpoint.compact => 16,
        AppLayoutBreakpoint.medium => 24,
        AppLayoutBreakpoint.expanded => 32,
        AppLayoutBreakpoint.large => 40,
      },
      verticalPadding: switch (breakpoint) {
        AppLayoutBreakpoint.compact => 16,
        AppLayoutBreakpoint.medium => 24,
        AppLayoutBreakpoint.expanded => 28,
        AppLayoutBreakpoint.large => 32,
      },
      maxContentWidth: switch (breakpoint) {
        AppLayoutBreakpoint.compact => 600,
        AppLayoutBreakpoint.medium => 760,
        AppLayoutBreakpoint.expanded => 1040,
        AppLayoutBreakpoint.large => 1280,
      },
      columns: switch (breakpoint) {
        AppLayoutBreakpoint.compact => 4,
        AppLayoutBreakpoint.medium => 8,
        AppLayoutBreakpoint.expanded => 12,
        AppLayoutBreakpoint.large => 12,
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
  String get breakpointName => switch (breakpoint) {
    AppLayoutBreakpoint.compact => 'compact',
    AppLayoutBreakpoint.medium => 'medium',
    AppLayoutBreakpoint.expanded => 'expanded',
    AppLayoutBreakpoint.large => 'large',
  };

  T resolve<T>({
    required T compact,
    T? medium,
    T? expanded,
    T? large,
  }) {
    switch (breakpoint) {
      case AppLayoutBreakpoint.compact:
        return compact;
      case AppLayoutBreakpoint.medium:
        return medium ?? compact;
      case AppLayoutBreakpoint.expanded:
        return expanded ?? medium ?? compact;
      case AppLayoutBreakpoint.large:
        return large ?? expanded ?? medium ?? compact;
    }
  }
}

extension AppLayoutContextExtension on BuildContext {
  AppLayoutData get layout => AppLayoutData.fromSize(MediaQuery.sizeOf(this));
}

class AppLayoutBuilder extends StatelessWidget {
  const AppLayoutBuilder({super.key, required this.builder});

  final Widget Function(BuildContext context, AppLayoutData layout) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaSize = MediaQuery.sizeOf(context);
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : mediaSize.width;
        final height = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : mediaSize.height;

        return builder(context, AppLayoutData.fromSize(Size(width, height)));
      },
    );
  }
}

class AppResponsiveBody extends StatelessWidget {
  const AppResponsiveBody({
    super.key,
    required Widget this.child,
    this.builder,
    this.maxContentWidth,
    this.scrollable = true,
    this.safeArea = true,
    this.alignment = Alignment.topCenter,
    this.padding,
  }) : assert(
         builder == null,
         'Use AppResponsiveBody.builder when you need layout data.',
       );

  const AppResponsiveBody.builder({
    super.key,
    required this.builder,
    this.maxContentWidth,
    this.scrollable = true,
    this.safeArea = true,
    this.alignment = Alignment.topCenter,
    this.padding,
  }) : child = null;

  final Widget? child;
  final Widget Function(BuildContext context, AppLayoutData layout)? builder;
  final double? maxContentWidth;
  final bool scrollable;
  final bool safeArea;
  final AlignmentGeometry alignment;
  final EdgeInsetsGeometry? padding;

  Widget _buildChild(BuildContext context, AppLayoutData layout) {
    return builder?.call(context, layout) ?? child!;
  }

  @override
  Widget build(BuildContext context) {
    Widget content = AppLayoutBuilder(
      builder: (context, layout) {
        final basePadding =
            padding ??
            EdgeInsets.symmetric(
              horizontal: layout.horizontalPadding,
              vertical: layout.verticalPadding,
            );

        // Instead of clamping children with a maxWidth constraint, we compute
        // additional horizontal "margin" when a maxContentWidth is provided.
        // This keeps content visually centered while still allowing children
        // to opt into full-width layouts (e.g., scrollbars on the screen edge).
        final targetWidth = maxContentWidth ?? layout.width;
        final extraHorizontalMargin =
            (layout.width - targetWidth) > 0 ? (layout.width - targetWidth) / 2 : 0.0;

        final resolvedPadding = basePadding.add(
          EdgeInsets.symmetric(horizontal: extraHorizontalMargin),
        );

        return Align(
          alignment: alignment,
          child: Padding(
            padding: resolvedPadding,
            child: _buildChild(context, layout),
          ),
        );
      },
    );

    if (scrollable) {
      content = SingleChildScrollView(child: content);
    }

    if (safeArea) {
      content = SafeArea(child: content);
    }

    return content;
  }
}
