import 'package:flutter/material.dart';

class RouteAwareSelectionArea extends StatelessWidget {
  const RouteAwareSelectionArea({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => SelectionArea(child: child);
}