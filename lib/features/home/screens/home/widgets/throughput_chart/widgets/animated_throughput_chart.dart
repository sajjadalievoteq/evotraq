import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/animation/traq_animation_constants.dart';
import 'package:traqtrace_app/core/animation/traq_animation_manager.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/features/home/screens/home/utils/throughput_chart_utils.dart';

/// Mini bar chart that uses the bars themselves as the loading indicator.
///
/// First appearance staggers bars up from the baseline into a deterministic
/// placeholder silhouette while [loading] is true, then morphs into [values].
/// Later updates interpolate previous → new heights without replaying the
/// entrance. Bars stay still between transitions — no continuous height pulse.
class AnimatedThroughputChart extends StatefulWidget {
  const AnimatedThroughputChart({
    super.key,
    required this.values,
    required this.labels,
    required this.loading,
    this.rangeIndex = 1,
  });

  static const barsKey = Key('throughput-animated-bars');

  final List<double> values;
  final List<String> labels;
  final bool loading;

  /// `1` is the 24-hour view, which densifies bottom labels when narrow.
  final int rangeIndex;

  @override
  State<AnimatedThroughputChart> createState() =>
      AnimatedThroughputChartState();
}

class AnimatedThroughputChartState extends State<AnimatedThroughputChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _morphController;

  List<double> _fromHeights = const [];
  List<double> _toHeights = const [];
  bool _staggered = true;
  bool _started = false;
  int _morphRunCount = 0;
  double _axisMaxY = 10;

  @visibleForTesting
  int get morphRunCount => _morphRunCount;

  bool get _reduceMotion =>
      TraqAnimationManager.reduceMotion(context) ||
      MediaQuery.disableAnimationsOf(context);

  @override
  void initState() {
    super.initState();
    _morphController = AnimationController(vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      _syncTargets(isEntrance: true);
      return;
    }
    if (_reduceMotion) {
      _snapToTargets();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedThroughputChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    final valuesChanged = !listEquals(oldWidget.values, widget.values);
    final countChanged =
        oldWidget.values.length != widget.values.length ||
        oldWidget.labels.length != widget.labels.length;
    if (oldWidget.loading != widget.loading || valuesChanged || countChanged) {
      _syncTargets(isEntrance: false);
    }
  }

  @override
  void dispose() {
    _morphController.dispose();
    super.dispose();
  }

  List<double> _normalizedTargets() {
    final count = math.max(widget.values.length, widget.labels.length);
    if (widget.loading) {
      return ThroughputChartUtils.placeholderHeights(count);
    }
    if (count <= 0) return const [];
    var maxVal = 0.0;
    for (final v in widget.values) {
      if (v > maxVal) maxVal = v;
    }
    if (maxVal <= 0) {
      return List<double>.filled(count, 0);
    }
    return List<double>.generate(count, (i) {
      final v = i < widget.values.length ? widget.values[i] : 0.0;
      return (v / maxVal).clamp(0.0, 1.0);
    });
  }

  List<double> _fit(List<double> source, int n) {
    if (n <= 0) return const [];
    if (source.length == n) return List<double>.from(source);
    return List<double>.generate(n, (i) => i < source.length ? source[i] : 0.0);
  }

  List<double> _displayedHeights() {
    final n = _toHeights.length;
    if (n == 0) return const [];
    return List<double>.generate(n, (i) {
      final from = i < _fromHeights.length ? _fromHeights[i] : 0.0;
      final to = _toHeights[i];
      return (from + (to - from) * _barProgress(i)).clamp(0.0, 1.0);
    });
  }

  double _barProgress(int i) {
    final t = _morphController.value;
    if (!_staggered || _toHeights.length <= 1) {
      return TraqAnimationConstants.curve.transform(t);
    }
    final n = _toHeights.length;
    final totalMs = (_morphController.duration ?? Duration.zero).inMilliseconds
        .toDouble()
        .clamp(1, 1e9);
    final itemMs = TraqAnimationConstants.entranceMs.toDouble();
    final staggerMs = (totalMs - itemMs) / (n - 1);
    final elapsed = t * totalMs;
    final local = ((elapsed - i * staggerMs) / itemMs).clamp(0.0, 1.0);
    return TraqAnimationConstants.curve.transform(local);
  }

  Duration _entranceDuration(int n) {
    if (n <= 1) return TraqAnimationConstants.entrance;
    final raw =
        TraqAnimationConstants.entranceMs +
        (n - 1) * TraqAnimationConstants.staggerDelayMs;
    final clamped = math.min(raw, TraqAnimationConstants.brandingEntranceMs);
    return Duration(milliseconds: clamped);
  }

  void _updateAxisMaxY() {
    if (widget.loading) {
      if (_axisMaxY <= 0) _axisMaxY = 10;
      return;
    }
    var maxVal = 0.0;
    for (final v in widget.values) {
      if (v > maxVal) maxVal = v;
    }
    _axisMaxY = ThroughputChartUtils.chartMaxY(maxVal);
  }

  void _snapToTargets() {
    _toHeights = _normalizedTargets();
    _fromHeights = List<double>.from(_toHeights);
    _staggered = false;
    _updateAxisMaxY();
    _morphController.duration = Duration.zero;
    _morphController.value = 1;
  }

  void _syncTargets({required bool isEntrance}) {
    final next = _normalizedTargets();
    if (_reduceMotion) {
      _toHeights = next;
      _fromHeights = List<double>.from(next);
      _staggered = false;
      _updateAxisMaxY();
      _morphController.duration = Duration.zero;
      _morphController.value = 1;
      return;
    }

    final current = _displayedHeights();
    _fromHeights = isEntrance
        ? List<double>.filled(next.length, 0)
        : _fit(current, next.length);
    _toHeights = next;
    _staggered = isEntrance;
    _updateAxisMaxY();
    _morphRunCount += 1;
    _morphController.duration = isEntrance
        ? _entranceDuration(next.length)
        : TraqAnimationConstants.throughputMorph;
    _morphController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 400;
        final colors = context.colors;
        final leftReserved = isSmall ? 36.0 : 42.0;
        const bottomReserved = 30.0;
        return RepaintBoundary(
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _ThroughputAxesPainter(
                    labels: widget.labels,
                    barCount: math.max(
                      widget.values.length,
                      widget.labels.length,
                    ),
                    maxY: _axisMaxY,
                    rangeIndex: widget.rangeIndex,
                    isSmall: isSmall,
                    leftReserved: leftReserved,
                    bottomReserved: bottomReserved,
                    gridColor: colors.border.withValues(alpha: 0.5),
                    labelColor: colors.textSecondary,
                    mutedLabelColor: colors.textMuted,
                    labelStyle: context.text.bodySm,
                  ),
                ),
              ),
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _morphController,
                  builder: (context, child) {
                    return CustomPaint(
                      key: AnimatedThroughputChart.barsKey,
                      painter: _ThroughputBarsPainter(
                        heights: _displayedHeights(),
                        leftReserved: leftReserved,
                        bottomReserved: bottomReserved,
                        barColor: colors.textMuted.withValues(alpha: 0.45),
                        lastBarColor: colors.success,
                        barRadius: TraqRadius.xs.x,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PlotMetrics {
  const _PlotMetrics({
    required this.plotLeft,
    required this.plotBottom,
    required this.plotWidth,
    required this.barWidth,
    required this.groupsSpace,
    required this.originX,
  });

  final double plotLeft;
  final double plotBottom;
  final double plotWidth;
  final double barWidth;
  final double groupsSpace;
  final double originX;

  static _PlotMetrics? tryCompute({
    required Size size,
    required int count,
    required double leftReserved,
    required double bottomReserved,
  }) {
    if (count <= 0 || size.width <= 0 || size.height <= 0) return null;
    final plotLeft = leftReserved;
    final plotBottom = size.height - bottomReserved;
    final plotWidth = size.width - plotLeft;
    if (plotWidth <= 0 || plotBottom <= 0) return null;
    final groupsSpace = count > 1 ? TraqSpacing.xs : 0.0;
    final rawBarW = count == 1
        ? plotWidth * 0.4
        : (plotWidth - (count - 1) * groupsSpace) / count;
    final barWidth = math.max(rawBarW, 1.0);
    final totalBarsWidth = count * barWidth + (count - 1) * groupsSpace;
    final originX = plotLeft + math.max(0.0, (plotWidth - totalBarsWidth) / 2);
    return _PlotMetrics(
      plotLeft: plotLeft,
      plotBottom: plotBottom,
      plotWidth: plotWidth,
      barWidth: barWidth,
      groupsSpace: groupsSpace,
      originX: originX,
    );
  }
}

class _ThroughputBarsPainter extends CustomPainter {
  _ThroughputBarsPainter({
    required this.heights,
    required this.leftReserved,
    required this.bottomReserved,
    required this.barColor,
    required this.lastBarColor,
    required this.barRadius,
  });

  final List<double> heights;
  final double leftReserved;
  final double bottomReserved;
  final Color barColor;
  final Color lastBarColor;
  final double barRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final count = heights.length;
    final plot = _PlotMetrics.tryCompute(
      size: size,
      count: count,
      leftReserved: leftReserved,
      bottomReserved: bottomReserved,
    );
    if (plot == null) return;

    for (var i = 0; i < count; i++) {
      final x = plot.originX + i * (plot.barWidth + plot.groupsSpace);
      final h = heights[i] * plot.plotBottom;
      if (h <= 0.5) continue;
      final radius = math.min(barRadius, h);
      canvas.drawRRect(
        RRect.fromLTRBAndCorners(
          x,
          plot.plotBottom - h,
          x + plot.barWidth,
          plot.plotBottom,
          topLeft: Radius.circular(radius),
          topRight: Radius.circular(radius),
        ),
        Paint()..color = i == count - 1 ? lastBarColor : barColor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ThroughputBarsPainter oldDelegate) {
    return oldDelegate.leftReserved != leftReserved ||
        oldDelegate.bottomReserved != bottomReserved ||
        oldDelegate.barColor != barColor ||
        oldDelegate.lastBarColor != lastBarColor ||
        oldDelegate.barRadius != barRadius ||
        !listEquals(oldDelegate.heights, heights);
  }
}

class _ThroughputAxesPainter extends CustomPainter {
  _ThroughputAxesPainter({
    required this.labels,
    required this.barCount,
    required this.maxY,
    required this.rangeIndex,
    required this.isSmall,
    required this.leftReserved,
    required this.bottomReserved,
    required this.gridColor,
    required this.labelColor,
    required this.mutedLabelColor,
    required this.labelStyle,
  });

  final List<String> labels;
  final int barCount;
  final double maxY;
  final int rangeIndex;
  final bool isSmall;
  final double leftReserved;
  final double bottomReserved;
  final Color gridColor;
  final Color labelColor;
  final Color mutedLabelColor;
  final TextStyle labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final plot = _PlotMetrics.tryCompute(
      size: size,
      count: barCount,
      leftReserved: leftReserved,
      bottomReserved: bottomReserved,
    );
    if (plot == null) return;

    final interval = ThroughputChartUtils.niceInterval(maxY == 0 ? 10 : maxY);
    final axisMax = maxY <= 0 ? interval : maxY;
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var v = 0.0; v <= axisMax + 0.001; v += interval) {
      final y = plot.plotBottom - (v / axisMax) * plot.plotBottom;
      canvas.drawLine(
        Offset(plot.plotLeft, y),
        Offset(plot.plotLeft + plot.plotWidth, y),
        gridPaint,
      );
    }

    final leftStyle = labelStyle.copyWith(
      fontSize: isSmall ? 8 : 10,
      color: mutedLabelColor,
    );
    for (var v = 0.0; v <= axisMax + 0.001; v += interval) {
      final y = plot.plotBottom - (v / axisMax) * plot.plotBottom;
      final tp = TextPainter(
        text: TextSpan(text: '${v.round()}', style: leftStyle),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout(maxWidth: leftReserved);
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    final count = math.min(barCount, labels.length);
    final styleBase = labelStyle.copyWith(
      fontSize: isSmall ? 9 : 10,
      color: labelColor,
    );
    for (var i = 0; i < count; i++) {
      if (rangeIndex == 1 && isSmall && i % 2 != 0) continue;
      final label = labels[i];
      if (label.isEmpty) continue;
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: styleBase.copyWith(
            fontWeight: i == count - 1 ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout(maxWidth: math.max(plot.barWidth + plot.groupsSpace, 12));
      final x =
          plot.originX +
          i * (plot.barWidth + plot.groupsSpace) +
          (plot.barWidth - tp.width) / 2;
      tp.paint(canvas, Offset(x, plot.plotBottom + 6));
    }
  }

  @override
  bool shouldRepaint(covariant _ThroughputAxesPainter oldDelegate) {
    return oldDelegate.maxY != maxY ||
        oldDelegate.barCount != barCount ||
        oldDelegate.rangeIndex != rangeIndex ||
        oldDelegate.isSmall != isSmall ||
        oldDelegate.leftReserved != leftReserved ||
        oldDelegate.bottomReserved != bottomReserved ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.labelColor != labelColor ||
        oldDelegate.mutedLabelColor != mutedLabelColor ||
        !listEquals(oldDelegate.labels, labels);
  }
}
