import 'package:flutter/material.dart';
import 'package:traqtrace_app/shared/layout/layout_manager.dart';

/// Marks which branch of [SplitOrListIndexedStack] is visible so list screens can
/// run a single initial fetch (the hidden branch stays mounted but must not duplicate
/// the same network request).
class PrimaryFetchScope extends InheritedWidget {
  const PrimaryFetchScope({
    super.key,
    required this.isPrimary,
    required super.child,
  });

  final bool isPrimary;

  static PrimaryFetchScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PrimaryFetchScope>();
  }

  @override
  bool updateShouldNotify(covariant PrimaryFetchScope oldWidget) {
    return oldWidget.isPrimary != isPrimary;
  }
}

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
          children: [
            PrimaryFetchScope(isPrimary: showSplit, child: split),
            PrimaryFetchScope(isPrimary: !showSplit, child: fallback),
          ],
        );
      },
    );
  }
}
