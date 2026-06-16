import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';

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
            PrimaryFetchScope(
              isPrimary: showSplit,
              child: HeroMode(enabled: showSplit, child: split),
            ),
            PrimaryFetchScope(
              isPrimary: !showSplit,
              child: HeroMode(enabled: !showSplit, child: fallback),
            ),
          ],
        );
      },
    );
  }
}
