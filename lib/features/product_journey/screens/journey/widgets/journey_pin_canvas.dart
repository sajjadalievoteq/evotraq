import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/product_journey/journey_step.dart';
import 'package:traqtrace_app/data/models/product_journey/product_journey.dart';
import 'package:traqtrace_app/features/product_journey/screens/journey/utils/journey_formatters.dart';
import 'package:traqtrace_app/features/product_journey/screens/journey/utils/journey_pin_layout.dart';
import 'package:traqtrace_app/features/product_journey/screens/journey/widgets/journey_canvas_painter.dart';
import 'package:traqtrace_app/features/product_journey/screens/journey/widgets/journey_pin_marker.dart';

/// Full-canvas widget that renders journey steps as coloured teardrop pins
/// connected by one continuous serpentine track through all events in order.
class JourneyPinsCanvas extends StatefulWidget {
  const JourneyPinsCanvas({
    super.key,
    required this.journey,
    required this.selectedStep,
    required this.onStepTapped,
  });

  final ProductJourney journey;
  final JourneyStep? selectedStep;
  final ValueChanged<JourneyStep> onStepTapped;

  @override
  State<JourneyPinsCanvas> createState() => _JourneyPinsCanvasState();
}

class _JourneyPinsCanvasState extends State<JourneyPinsCanvas> {
  final ScrollController _scrollController = ScrollController();

  static const double _pinR = JourneyPinLayout.pinRadius;
  static const double _pinW = JourneyPinLayout.pinWidth;

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

  @override
  Widget build(BuildContext context) {
    final steps = widget.journey.steps;
    if (steps.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(builder: (context, constraints) {
      final viewportW = constraints.maxWidth;
      final viewportH = constraints.maxHeight;
      final axis = context.isDesktop
          ? SerpentineAxis.horizontal
          : SerpentineAxis.vertical;

      final layout = JourneyPinLayout.serpentineLayout(
        count: steps.length,
        viewportW: viewportW,
        viewportH: viewportH,
        axis: axis,
      );
      final canvasW = layout.width;
      final canvasH = layout.height;
      final centres = layout.centres;

      final canvas = SizedBox(
        width: canvasW,
        height: canvasH,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: JourneyCanvasPainter(
                  positions: centres,
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white,
                ),
              ),
            ),
            for (int i = 0; i < steps.length - 1; i++) ...[
              if (_durationBetween(steps, i).inMinutes > 0)
                Builder(builder: (context) {
                  final anchor = JourneyPinLayout.durationLabelAnchor(
                    centres[i],
                    centres[i + 1],
                    axis: axis,
                  );
                  if (anchor == null) return const SizedBox.shrink();
                  return Positioned(
                    left: anchor.dx - _chipHalfW+50,
                    top: anchor.dy - _chipHalfH+50,
                    child: _DurationChip(
                      label: JourneyFormatters.humanDuration(
                        _durationBetween(steps, i),
                      ),
                    ),
                  );
                }),
            ],
            for (int i = 0; i < steps.length; i++)
              Positioned(
                left: centres[i].dx - _pinW / 2,
                top: centres[i].dy - _pinR,
                width: _pinW,
                child: JourneyPinMarker(
                  step: steps[i],
                  stepIndex: i + 1,
                  isSelected:
                      widget.selectedStep?.eventId == steps[i].eventId,
                  isFirst: i == 0,
                  isLast: i == steps.length - 1,
                  onTap: () => widget.onStepTapped(steps[i]),
                  pinRadius: _pinR,
                ),
              ),
          ],
        ),
      );

      final scrollAxis =
          axis == SerpentineAxis.horizontal ? Axis.horizontal : Axis.vertical;
      final canvasExtent =
          axis == SerpentineAxis.horizontal ? canvasW : canvasH;
      final viewportExtent =
          axis == SerpentineAxis.horizontal ? viewportW : viewportH;

      return _scrollableCanvas(
        canvas: canvas,
        scrollAxis: scrollAxis,
        canvasExtent: canvasExtent,
        viewportExtent: viewportExtent,
      );
    });
  }

  Widget _scrollableCanvas({
    required Widget canvas,
    required Axis scrollAxis,
    required double canvasExtent,
    required double viewportExtent,
  }) {
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
  }

  static Duration _durationBetween(List<JourneyStep> steps, int index) {
    return steps[index + 1].eventTime.difference(steps[index].eventTime);
  }

  static const double _chipHalfW = 60.0;
  static const double _chipHalfH = 11.0;
}

class _DurationChip extends StatelessWidget {
  const _DurationChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 0.8,
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
