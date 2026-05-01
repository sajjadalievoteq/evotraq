import 'package:flutter/material.dart';
import 'package:traqtrace_app/shared/layout/layout_manager.dart';

/// On wide layouts ([AppLayout] `isDesktopUp`), shows [split]; otherwise [fallback]
/// (typically a full-width list that navigates to detail).
///
/// Keeps both trees mounted in an [IndexedStack] so resizing and cubit state are stable.
class SplitOrListIndexedStack extends StatelessWidget {
  const SplitOrListIndexedStack({
    super.key,
    required this.split,
    required this.fallback,
  });

  final Widget split;
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    return AppLayoutBuilder(
      builder: (context, layout) {
        final showSplit = layout.isDesktopUp;
        return IndexedStack(
          index: showSplit ? 0 : 1,
          children: [split, fallback],
        );
      },
    );
  }
}
