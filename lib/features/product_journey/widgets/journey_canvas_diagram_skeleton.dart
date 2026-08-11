import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/features/product_journey/utils/journey_pin_layout.dart';
import 'package:traqtrace_app/features/product_journey/widgets/journey_canvas_painter.dart';
import 'package:traqtrace_app/features/product_journey/widgets/journey_pin_skeleton.dart';

class JourneyCanvasDiagramSkeleton extends StatefulWidget {
  const JourneyCanvasDiagramSkeleton({super.key});

  static const int horizontalLevels = 6;

  @override
  State<JourneyCanvasDiagramSkeleton> createState() =>
      _JourneyCanvasDiagramSkeletonState();
}

class _JourneyCanvasDiagramSkeletonState
    extends State<JourneyCanvasDiagramSkeleton> {
  final ScrollController _scrollController = ScrollController();

  static const Set<PointerDeviceKind> _dragDevices = {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  int _pinCount(SerpentineAxis axis) {
    return switch (axis) {
      SerpentineAxis.horizontal =>
        JourneyCanvasDiagramSkeleton.horizontalLevels * 2,
      SerpentineAxis.vertical => JourneyCanvasDiagramSkeleton.horizontalLevels,
    };
  }

  static const double _pinR = JourneyPinLayout.pinRadius;
  static const double _pinW = JourneyPinLayout.pinWidth;
  static const double _chipHalfW = 60.0;
  static const double _chipHalfH = 11.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportW = constraints.maxWidth;
        final viewportH = constraints.maxHeight;
        final axis = context.isDesktop
            ? SerpentineAxis.horizontal
            : SerpentineAxis.vertical;
        final pinCount = _pinCount(axis);

        final layout = JourneyPinLayout.serpentineLayout(
          count: pinCount,
          viewportW: viewportW,
          viewportH: viewportH,
          axis: axis,
        );
        final centres = layout.centres;
        final lineGeom = JourneyCanvasPainter.prepare(centres);

        final canvas = AppShimmer(
          child: SizedBox(
            width: layout.width,
            height: layout.height,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: JourneyCanvasPainter(
                      positions: centres,
                      color: Colors.white,
                      progress: const AlwaysStoppedAnimation(1.0),
                      fullPath: lineGeom.path,
                      metrics: lineGeom.metrics,
                      totalLength: lineGeom.totalLength,
                    ),
                  ),
                ),
                for (int i = 0; i < pinCount - 1; i++)
                  if (JourneyPinLayout.durationLabelAnchor(
                        centres[i],
                        centres[i + 1],
                        axis: axis,
                      )
                      case final anchor?)
                    Positioned(
                      left: anchor.dx - _chipHalfW + 50,
                      top: anchor.dy - _chipHalfH + 50,
                      child: const AppSkeletonBox(
                        width: 48,
                        height: 18,
                        radius: 10,
                      ),
                    ),
                for (int i = 0; i < pinCount; i++)
                  Positioned(
                    left: centres[i].dx - _pinW / 2,
                    top: centres[i].dy - _pinR,
                    width: _pinW,
                    child: JourneyPinSkeleton(
                      isFirst: i == 0,
                      isLast: i == pinCount - 1,
                    ),
                  ),
              ],
            ),
          ),
        );

        final scrollAxis = axis == SerpentineAxis.horizontal
            ? Axis.horizontal
            : Axis.vertical;
        final canvasExtent = axis == SerpentineAxis.horizontal
            ? layout.width
            : layout.height;
        final viewportExtent = axis == SerpentineAxis.horizontal
            ? viewportW
            : viewportH;

        if (canvasExtent <= viewportExtent + 0.5) return canvas;

        return ScrollConfiguration(
          behavior: ScrollConfiguration.of(
            context,
          ).copyWith(dragDevices: _dragDevices),
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            interactive: true,
            notificationPredicate: (notification) =>
                notification.metrics.axis == scrollAxis,
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: scrollAxis,
              clipBehavior: Clip.hardEdge,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              child: canvas,
            ),
          ),
        );
      },
    );
  }
}
