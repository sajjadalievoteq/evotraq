import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/layout/app_layout_data.dart';

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
