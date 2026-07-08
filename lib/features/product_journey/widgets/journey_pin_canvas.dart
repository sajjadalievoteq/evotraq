import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/product_journey/journey_step.dart';
import 'package:traqtrace_app/data/models/product_journey/product_journey.dart';
import 'package:traqtrace_app/features/product_journey/utils/journey_event_filter.dart';
import 'package:traqtrace_app/features/product_journey/utils/journey_formatters.dart';
import 'package:traqtrace_app/features/product_journey/utils/journey_pin_layout.dart';
import 'package:traqtrace_app/features/product_journey/widgets/journey_canvas_painter.dart';
import 'package:traqtrace_app/features/product_journey/widgets/journey_pin_marker.dart';

class JourneyPinsCanvas extends StatefulWidget {
  const JourneyPinsCanvas({
    super.key,
    required this.journey,
    required this.selectedStep,
    required this.onStepTapped,
    this.eventFilter = JourneyEventFilter.all,
  });

  final ProductJourney journey;
  final JourneyStep? selectedStep;
  final ValueChanged<JourneyStep> onStepTapped;
  final JourneyEventFilter eventFilter;

  @override
  State<JourneyPinsCanvas> createState() => _JourneyPinsCanvasState();
}

class _JourneyPinsCanvasState extends State<JourneyPinsCanvas>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  // Shared entrance controller — drives both line draw and pin stagger.
  // Total duration 900ms: line draws in 0→540ms, pins stagger from 250ms→900ms.
  late final AnimationController _entranceCtrl;
  late final Animation<double> _lineProgress;

  // Tracks the journey identity so we restart the animation when a new journey loads.
  String? _lastJourneyId;

  // Whether the entrance animation has been scheduled for the current journey.
  // Prevents didUpdateWidget from restarting mid-play on unrelated rebuilds.
  bool _entranceScheduled = false;

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
      duration: const Duration(milliseconds: 900),
    );
    // Line draws across the first 60% of the total duration.
    _lineProgress = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.0, 0.60, curve: Curves.easeInOut),
    );
    // Record the current journey so didUpdateWidget can detect a real journey change.
    _lastJourneyId = widget.journey.steps.isEmpty
        ? null
        : widget.journey.steps.first.eventId;

    // Defer forward() until after the first frame so every _AnimatedPin child
    // is fully built and its CurvedAnimation is listening before ticks start.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _entranceCtrl.forward(from: 0.0);
      _entranceScheduled = true;
    });
  }

  @override
  void didUpdateWidget(JourneyPinsCanvas old) {
    super.didUpdateWidget(old);
    final newId = widget.journey.steps.isEmpty
        ? null
        : widget.journey.steps.first.eventId;
    // Only restart when the journey itself changed — not on every BlocBuilder rebuild.
    if (newId != _lastJourneyId) {
      _lastJourneyId = newId;
      _entranceScheduled = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _entranceCtrl.forward(from: 0.0);
        _entranceScheduled = true;
      });
    }
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
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
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _lineProgress,
                  builder: (context, _) => CustomPaint(
                    painter: JourneyCanvasPainter(
                      positions: centres,
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : Colors.white,
                      progress: _lineProgress.value,
                    ),
                  ),
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
                    left: anchor.dx - _chipHalfW + 50,
                    top: anchor.dy - _chipHalfH + 50,
                    child: _AnimatedPin(
                      index: i,
                      totalCount: steps.length,
                      entranceCtrl: _entranceCtrl,
                      startOffset: 0.38,
                      dimmed: false,
                      child: _DurationChip(
                        label: JourneyFormatters.humanDuration(
                          _durationBetween(steps, i),
                        ),
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
                child: _AnimatedPin(
                  index: i,
                  totalCount: steps.length,
                  entranceCtrl: _entranceCtrl,
                  dimmed: widget.eventFilter != JourneyEventFilter.all &&
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

/// Wraps any canvas child in a staggered entrance animation driven by a shared controller.
/// Uses compositor-friendly [FadeTransition] + [ScaleTransition] — zero Dart CPU cost
/// once the animation completes.
class _AnimatedPin extends StatefulWidget {
  const _AnimatedPin({
    required this.index,
    required this.totalCount,
    required this.entranceCtrl,
    required this.dimmed,
    required this.child,
    this.startOffset = 0.28,
  });

  final int index;
  final int totalCount;
  final AnimationController entranceCtrl;
  final bool dimmed;
  final Widget child;
  final double startOffset;

  @override
  State<_AnimatedPin> createState() => _AnimatedPinState();
}

class _AnimatedPinState extends State<_AnimatedPin>
    with SingleTickerProviderStateMixin {
  late CurvedAnimation _curve;

  // Drives a spring-pop when this pin transitions from dimmed → visible.
  // Stays at 1.0 at rest so it never interferes with the steady-state layout.
  late final AnimationController _filterBounceCtrl;
  late final Animation<double> _filterBounceScale;

  @override
  void initState() {
    super.initState();
    _curve = _buildCurve();

    _filterBounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    )..value = 1.0; // start at rest — no bounce on initial load

    _filterBounceScale = CurvedAnimation(
      parent: _filterBounceCtrl,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void didUpdateWidget(_AnimatedPin old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index ||
        old.totalCount != widget.totalCount ||
        old.startOffset != widget.startOffset ||
        old.entranceCtrl != widget.entranceCtrl) {
      _curve.dispose();
      _curve = _buildCurve();
    }
    // Pin just became relevant (filter changed to include it): spring pop.
    if (old.dimmed && !widget.dimmed) {
      _filterBounceCtrl.forward(from: 0.0);
    }
  }

  CurvedAnimation _buildCurve() {
    final available = 1.0 - widget.startOffset;
    final step =
        widget.totalCount > 1 ? available / widget.totalCount : available;
    final start = (widget.startOffset + widget.index * step).clamp(0.0, 0.95);
    final end = (start + 0.45).clamp(start + 0.01, 1.0);

    return CurvedAnimation(
      parent: widget.entranceCtrl,
      curve: Interval(start, end, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _filterBounceCtrl.dispose();
    _curve.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curve,
      child: ScaleTransition(
        scale: _curve,
        alignment: Alignment.bottomCenter,
        child: AnimatedOpacity(
          opacity: widget.dimmed ? 0.22 : 1.0,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeInOut,
          // Scale bounce wraps only the content — entrance ScaleTransition above
          // handles initial layout; this one plays independently on filter change.
          child: ScaleTransition(
            scale: _filterBounceScale,
            alignment: Alignment.bottomCenter,
            child: widget.child,
          ),
        ),
      ),
    );
  }
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
