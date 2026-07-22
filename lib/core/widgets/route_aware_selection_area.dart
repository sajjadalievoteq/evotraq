import 'package:flutter/material.dart';

/// Wraps route content in [SelectionArea] so text selection works under the
/// Navigator [Overlay] (required by [SelectableRegion]).
///
/// Do not place [SelectionArea] in [MaterialApp.builder] above the router —
/// that sits outside Overlay and throws "No Overlay widget found".
class RouteAwareSelectionArea extends StatelessWidget {
  const RouteAwareSelectionArea({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => SelectionArea(child: child);
}
