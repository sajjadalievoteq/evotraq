import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/features/product_journey/utils/journey_pin_layout.dart';
import 'package:traqtrace_app/features/product_journey/widgets/journey_canvas_painter.dart';

/// Skeleton for the product-journey canvas diagram (and optional header).
/// Prefer composing header via [JourneyCanvasPane] so padding matches the loaded UI.
class JourneyCanvasSkeleton extends StatelessWidget {
  const JourneyCanvasSkeleton({
    super.key,
    this.includeHeader = true,
  });

  /// When false, only the diagram skeleton is shown.
  final bool includeHeader;

  @override
  Widget build(BuildContext context) {
    if (!includeHeader) {
      return const JourneyCanvasDiagramSkeleton();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: journeyCanvasHeaderPadding(context),
          child: const JourneyCanvasHeaderSkeleton(),
        ),
        const Expanded(child: JourneyCanvasDiagramSkeleton()),
      ],
    );
  }
}

/// Shared with [JourneyCanvasPane] so loading and loaded use the same top inset.
EdgeInsets journeyCanvasHeaderPadding(BuildContext context) {
  return EdgeInsets.fromLTRB(
    context.padding.top,
    context.padding.top,
    context.padding.top,
    TraqSpacing.sm,
  );
}

/// Timeline header + filter chips placeholder.
class JourneyCanvasHeaderSkeleton extends StatelessWidget {
  const JourneyCanvasHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: TraqSpacing.lg,
                vertical: TraqSpacing.md,
              ),
              child: Row(
                children: const [
                  AppSkeletonBox(width: 64, height: 16),
                  SizedBox(width: TraqSpacing.md),
                  AppSkeletonBox(width: 52, height: 24, radius: 12),
                  SizedBox(width: TraqSpacing.sm),
                  AppSkeletonBox(width: 56, height: 24, radius: 12),
                  Spacer(),
                  AppSkeletonBox(width: 96, height: 12),
                  SizedBox(width: TraqSpacing.lg),
                  AppSkeletonBox(width: 72, height: 12),
                  SizedBox(width: TraqSpacing.lg),
                  AppSkeletonBox(width: 48, height: 12),
                  SizedBox(width: TraqSpacing.lg),
                  AppSkeletonBox(width: 88, height: 12),
                ],
              ),
            ),
          ),
          const SizedBox(height: TraqSpacing.sm),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: TraqSpacing.md,
                vertical: TraqSpacing.sm,
              ),
              child: Row(
                children: [
                  for (int i = 0; i < 7; i++) ...[
                    if (i > 0) const SizedBox(width: TraqSpacing.sm),
                    AppSkeletonBox(
                      width: i == 0 ? 36 : 72 + (i % 3) * 12.0,
                      height: 28,
                      radius: 14,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class JourneyCanvasDiagramSkeleton extends StatefulWidget {
  const JourneyCanvasDiagramSkeleton({super.key});

  /// Serpentine columns on the horizontal canvas (2 pins per column).
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
                  Builder(
                    builder: (context) {
                      final anchor = JourneyPinLayout.durationLabelAnchor(
                        centres[i],
                        centres[i + 1],
                        axis: axis,
                      );
                      if (anchor == null) return const SizedBox.shrink();
                      return Positioned(
                        left: anchor.dx - _chipHalfW + 50,
                        top: anchor.dy - _chipHalfH + 50,
                        child: const AppSkeletonBox(
                          width: 48,
                          height: 18,
                          radius: 10,
                        ),
                      );
                    },
                  ),
                for (int i = 0; i < pinCount; i++)
                  Positioned(
                    left: centres[i].dx - _pinW / 2,
                    top: centres[i].dy - _pinR,
                    width: _pinW,
                    child: _PinSkeleton(
                      isFirst: i == 0,
                      isLast: i == pinCount - 1,
                    ),
                  ),
              ],
            ),
          ),
        );

        final scrollAxis =
            axis == SerpentineAxis.horizontal ? Axis.horizontal : Axis.vertical;
        final canvasExtent =
            axis == SerpentineAxis.horizontal ? layout.width : layout.height;
        final viewportExtent =
            axis == SerpentineAxis.horizontal ? viewportW : viewportH;

        if (canvasExtent <= viewportExtent + 0.5) return canvas;

        return ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: _dragDevices,
          ),
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

class _PinSkeleton extends StatelessWidget {
  const _PinSkeleton({required this.isFirst, required this.isLast});

  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    const r = JourneyPinLayout.pinRadius;
    const pinH = r * 2 + r * 0.5;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppSkeletonBox(width: r * 2, height: pinH, radius: r),
        const SizedBox(height: 6),
        const AppSkeletonBox(width: 96, height: 22, radius: 11),
        const SizedBox(height: 4),
        const AppSkeletonBox(width: double.infinity, height: 52, radius: 8),
        if (isFirst || isLast) ...[
          const SizedBox(height: 3),
          AppSkeletonBox(
            width: isFirst ? 36 : 32,
            height: 14,
            radius: 7,
          ),
        ],
      ],
    );
  }
}
