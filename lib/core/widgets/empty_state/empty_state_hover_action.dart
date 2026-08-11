import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/animation/traq_animation_manager.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class EmptyStateHoverAction extends StatefulWidget {
  const EmptyStateHoverAction({super.key, required this.child});

  final Widget child;

  @override
  State<EmptyStateHoverAction> createState() => _EmptyStateHoverActionState();
}

class _EmptyStateHoverActionState extends State<EmptyStateHoverAction> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: _hovered ? 1 : 0.98,
          duration: const Duration(milliseconds: 140),
          child: widget.child,
        ),
      ),
    );
  }
}
