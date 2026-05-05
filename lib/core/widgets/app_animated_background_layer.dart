import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/evotraq_theme.dart';
import 'package:traqtrace_app/core/widgets/trace_network_background.dart';

/// App-level animated background.
///
/// This widget is intentionally **background-only** (no `child`), so you can
/// place it behind your routed content in `main.dart` using your own `Stack`.
class AppAnimatedBackgroundLayer extends StatelessWidget {
  final double density;
  final int travelerCount;

  const AppAnimatedBackgroundLayer({
    super.key,
    this.density = 0.85,
    this.travelerCount = 18,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Positioned.fill(
      child: RepaintBoundary(
        child: ColoredBox(
          // TraceNetworkBackground doesn't paint a background, so without this
          // the "empty" pixels can appear white. This ensures bg0 switches with theme.
          color: colors.bg0,
          child: TraceNetworkBackground(
            // Stable key so this element/state doesn't reset.
            key: const ValueKey('app-trace-network-bg'),
            density: density,
            travelerCount: travelerCount,
          ),
        ),
      ),
    );
  }
}

/// Optional convenience wrapper if you ever want background + child together.
class AppAnimatedBackgroundScaffold extends StatelessWidget {
  final Widget child;
  final double density;
  final int travelerCount;

  const AppAnimatedBackgroundScaffold({
    super.key,
    required this.child,
    this.density = 1,
    this.travelerCount = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            child: TraceNetworkBackground(
              key: const ValueKey('app-trace-network-bg'),
              density: density,
              travelerCount: travelerCount,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

