import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class JourneyScrollableCanvas extends StatelessWidget {
  const JourneyScrollableCanvas({
    required this.canvas,
    required this.scrollAxis,
    required this.canvasExtent,
    required this.viewportExtent,
    required this.scrollController,
    required this.dragDevices,
    super.key,
  });

  final Widget canvas;
  final Axis scrollAxis;
  final double canvasExtent;
  final double viewportExtent;
  final ScrollController scrollController;
  final Set<PointerDeviceKind> dragDevices;

  @override
  Widget build(BuildContext context) {
    if (canvasExtent <= viewportExtent + 0.5) return canvas;
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(
        context,
      ).copyWith(dragDevices: dragDevices),
      child: Scrollbar(
        controller: scrollController,
        thumbVisibility: true,
        interactive: true,
        notificationPredicate: (notification) =>
            notification.metrics.axis == scrollAxis,
        child: SingleChildScrollView(
          controller: scrollController,
          scrollDirection: scrollAxis,
          clipBehavior: Clip.hardEdge,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          child: canvas,
        ),
      ),
    );
  }
}
