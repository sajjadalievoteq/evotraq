import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/layout/app_layout_builder.dart';
import 'package:traqtrace_app/core/layout/app_layout_data.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';

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

  @override
  Widget build(BuildContext context) {
    Widget content = AppLayoutBuilder(
      builder: (context, layout) {
        final targetWidth = maxContentWidth ?? layout.width;
        final extraMargin = (layout.width - targetWidth) > 0
            ? (layout.width - targetWidth) / 2
            : 0.0;
        final resolvedPadding = (padding ?? ResponsiveUtils.paddingAll(context))
            .add(EdgeInsets.symmetric(horizontal: extraMargin));
        return Padding(
          padding: resolvedPadding,
          child: Align(
            alignment: alignment,
            child: builder?.call(context, layout) ?? child!,
          ),
        );
      },
    );
    if (scrollable) content = SingleChildScrollView(child: content);
    if (safeArea) content = SafeArea(child: content);
    return content;
  }
}
