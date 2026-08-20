import 'dart:ui' show PathMetric;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/product_journey/widgets/journey_scrollable_canvas.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/product_journey/journey_step.dart';
import 'package:traqtrace_app/data/models/product_journey/product_journey.dart';
import 'package:traqtrace_app/features/product_journey/utils/journey_animation_constants.dart';
import 'package:traqtrace_app/features/product_journey/utils/journey_event_filter.dart';
import 'package:traqtrace_app/features/product_journey/utils/journey_formatters.dart';
import 'package:traqtrace_app/features/product_journey/utils/journey_pin_layout.dart';
import 'package:traqtrace_app/features/product_journey/widgets/journey_canvas_painter.dart';
import 'package:traqtrace_app/features/product_journey/widgets/journey_animated_pin.dart';
import 'package:traqtrace_app/features/product_journey/widgets/journey_duration_chip.dart';
import 'package:traqtrace_app/features/product_journey/widgets/journey_pin_marker.dart';

class JourneyPinsCanvas extends StatefulWidget {
  const JourneyPinsCanvas({
    super.key,
    required this.journey,
    required this.selectedStep,
    required this.onStepTapped,
    this.eventFilter = JourneyEventFilter.all,
    this.topInset = 0,
  });

  final ProductJourney journey;
  final JourneyStep? selectedStep;
  final ValueChanged<JourneyStep> onStepTapped;
  final JourneyEventFilter eventFilter;

  final double topInset;

  @override
  State<JourneyPinsCanvas> createState() => _JourneyPinsCanvasState();
}

class _JourneyPinsCanvasState extends State<JourneyPinsCanvas>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  late final AnimationController _entranceCtrl;
  late final Animation<double> _lineProgress;

  String? _lastJourneyId;

  List<Offset>? _cachedCentres;
  Path? _linePath;
  List<PathMetric>? _lineMetrics;
  double _lineTotalLength = 0;

  static const double _pinR = JourneyPinLayout.pinRadius;
  static const double _pinW = JourneyPinLayout.pinWidth;

  static const Set<PointerDeviceKind> _dragDevices = {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: JourneyAnimationConstants.canvasEntrance,
    );
    _lineProgress = CurvedAnimation(
      parent: _entranceCtrl,
      curve: Interval(
        JourneyAnimationConstants.lineProgressStart,
        JourneyAnimationConstants.lineProgressEnd,
        curve: Curves.easeInOut,
      ),
    );
    _lastJourneyId = widget.journey.steps.isEmpty
        ? null
        : widget.journey.steps.first.eventId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _entranceCtrl.forward(from: 0.0);
    });
  }

  @override
  void didUpdateWidget(JourneyPinsCanvas old) {
    super.didUpdateWidget(old);
    final newId = widget.journey.steps.isEmpty
        ? null
        : widget.journey.steps.first.eventId;
    if (newId != _lastJourneyId) {
      _lastJourneyId = newId;
      _cachedCentres = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _entranceCtrl.forward(from: 0.0);
      });
    }
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _ensureLineGeometry(List<Offset> centres) {
    if (_cachedCentres != null &&
        listEquals(_cachedCentres, centres) &&
        _linePath != null &&
        _lineMetrics != null) {
      return;
    }
    _cachedCentres = List<Offset>.of(centres);
    final prepared = JourneyCanvasPainter.prepare(centres);
    _linePath = prepared.path;
    _lineMetrics = prepared.metrics;
    _lineTotalLength = prepared.totalLength;
  }

  @override
  Widget build(BuildContext context) {
    final steps = widget.journey.steps;
    if (steps.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
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
          topInset: widget.topInset,
        );
        final canvasW = layout.width;
        final canvasH = layout.height;
        final centres = layout.centres;

        _ensureLineGeometry(centres);

        final lineColor = Theme.of(context).brightness == Brightness.light
            ? Colors.black
            : Colors.white;

        final canvas = SizedBox(
          width: canvasW,
          height: canvasH,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: JourneyCanvasPainter(
                      positions: centres,
                      color: lineColor,
                      progress: _lineProgress,
                      fullPath: _linePath!,
                      metrics: _lineMetrics!,
                      totalLength: _lineTotalLength,
                    ),
                  ),
                ),
              ),
              for (int i = 0; i < steps.length - 1; i++) ...[
                if (_durationBetween(steps, i).inSeconds > 0)
                  if (JourneyPinLayout.durationLabelAnchor(
                        centres[i],
                        centres[i + 1],
                        axis: axis,
                      )
                      case final anchor?)
                    Positioned(
                      left: anchor.dx - _chipHalfW + 50,
                      top: anchor.dy - _chipHalfH + 50,
                      child: JourneyAnimatedPin(
                        index: i,
                        totalCount: steps.length,
                        entranceCtrl: _entranceCtrl,
                        startOffset: JourneyAnimationConstants
                            .durationChipStaggerStartOffset,
                        dimmed: false,
                        child: JourneyDurationChip(
                          label: JourneyFormatters.humanDuration(
                            _durationBetween(steps, i),
                          ),
                        ),
                      ),
                    ),
              ],
              for (int i = 0; i < steps.length; i++)
                Positioned(
                  left: centres[i].dx - _pinW / 2,
                  top: centres[i].dy - _pinR,
                  width: _pinW,
                  child: JourneyAnimatedPin(
                    index: i,
                    totalCount: steps.length,
                    entranceCtrl: _entranceCtrl,
                    dimmed:
                        widget.eventFilter != JourneyEventFilter.all &&
                        !widget.eventFilter.matches(steps[i]),
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
                ),
            ],
          ),
        );

        // Horizontal (desktop): the cross-axis is vertical and cannot scroll, so
        // if the natural canvas is taller than the viewport (short screen) scale
        // the whole serpentine to fit — never trim top or bottom. (Vertical/mobile
        // handles overflow via the vertical scroll view below.)
        if (axis == SerpentineAxis.horizontal && canvasH > viewportH + 0.5) {
          return Center(
            child: FittedBox(fit: BoxFit.contain, child: canvas),
          );
        }

        final scrollAxis = axis == SerpentineAxis.horizontal
            ? Axis.horizontal
            : Axis.vertical;
        final canvasExtent = axis == SerpentineAxis.horizontal
            ? canvasW
            : canvasH;
        final viewportExtent = axis == SerpentineAxis.horizontal
            ? viewportW
            : viewportH;

        return JourneyScrollableCanvas(
          canvas: canvas,
          scrollAxis: scrollAxis,
          canvasExtent: canvasExtent,
          viewportExtent: viewportExtent,
          scrollController: _scrollController,
          dragDevices: _dragDevices,
        );
      },
    );
  }

  static Duration _durationBetween(List<JourneyStep> steps, int index) {
    return steps[index + 1].eventTime.difference(steps[index].eventTime);
  }

  static const double _chipHalfW = 60.0;
  static const double _chipHalfH = 11.0;
}
