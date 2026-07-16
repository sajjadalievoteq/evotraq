import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/product_journey/journey_step.dart';

enum SerpentineAxis {
  horizontal,
  vertical,
}

abstract final class JourneyPinLayout {
  static const double pinRadius = 30.0;
  static const double pinWidth = 168.0;

  static const double pinHeight = 230.0;

  static const double _laneSpacing = 280.0;
  static const double _edgePad = 80.0;
  static const double _bandGap = 16.0;
  static const double _bottomGap = 16.0;

  /// Minimum usable band height so top/bottom lanes don't collapse on short screens.
  static const double _minBandHeight = 220.0;

  static int seedForSteps(List<JourneyStep> steps) {
    var hash = steps.length;
    for (final step in steps) {
      hash = Object.hash(hash, step.eventId);
    }
    return hash;
  }

  static ({
    double width,
    double height,
    List<Offset> centres,
    SerpentineAxis axis,
  }) serpentineLayout({
    required int count,
    required double viewportW,
    required double viewportH,
    required SerpentineAxis axis,
    double topInset = 0,
  }) {
    if (count == 0) {
      return (
        width: viewportW,
        height: viewportH,
        centres: <Offset>[],
        axis: axis,
      );
    }
    if (count == 1) {
      final usableTop = topInset + _bandGap;
      final cy = math.max(
        usableTop + pinRadius,
        (usableTop + viewportH) / 2,
      );
      return (
        width: viewportW,
        height: math.max(viewportH, usableTop + pinHeight),
        centres: [Offset(viewportW / 2, cy)],
        axis: axis,
      );
    }

    return switch (axis) {
      SerpentineAxis.horizontal => _horizontalSerpentine(
          count: count,
          viewportW: viewportW,
          viewportH: viewportH,
          topInset: topInset,
        ),
      SerpentineAxis.vertical => _verticalSerpentine(
          count: count,
          viewportW: viewportW,
          viewportH: viewportH,
          topInset: topInset,
        ),
    };
  }

  static ({
    double width,
    double height,
    List<Offset> centres,
    SerpentineAxis axis,
  }) _horizontalSerpentine({
    required int count,
    required double viewportW,
    required double viewportH,
    required double topInset,
  }) {
    const lanes = 2;
    final usableTop = topInset + _bandGap;
    final minHeight = usableTop + _minBandHeight + _bottomGap;
    final height = math.max(viewportH, minHeight);
    final usableBottom = height - _bottomGap;
    final band = math.max(_minBandHeight, usableBottom - usableTop);
    final topY = usableTop + band * 0.05;
    final bottomY = usableTop + band * 0.75;
    final startX = _edgePad + pinWidth / 2;

    final cols = (count / lanes).ceil();
    final width = _edgePad * 2 + pinWidth + (cols - 1) * _laneSpacing;

    final centres = <Offset>[];
    for (int i = 0; i < count; i++) {
      final col = i ~/ lanes;
      final laneInCol = i % lanes;
      final reverseCol = col % 2 == 1;

      final x = startX + col * _laneSpacing;
      final y = reverseCol
          ? (laneInCol == 0 ? bottomY : topY)
          : (laneInCol == 0 ? topY : bottomY);

      centres.add(Offset(x, y));
    }

    return (
      width: width,
      height: height,
      centres: centres,
      axis: SerpentineAxis.horizontal,
    );
  }

  static ({
    double width,
    double height,
    List<Offset> centres,
    SerpentineAxis axis,
  }) _verticalSerpentine({
    required int count,
    required double viewportW,
    required double viewportH,
    required double topInset,
  }) {
    const lanes = 2;
    final leftX = viewportW * 0.25;
    final rightX = viewportW * 0.75;
    final startY = topInset + _bandGap + viewportH * 0.12;

    final rows = (count / lanes).ceil();
    final height = math.max(
      viewportH,
      startY + (rows - 1) * _laneSpacing + pinHeight,
    );

    final centres = <Offset>[];
    for (int i = 0; i < count; i++) {
      final row = i ~/ lanes;
      final laneInRow = i % lanes;
      final reverseRow = row % 2 == 1;

      final x = reverseRow
          ? (laneInRow == 0 ? rightX : leftX)
          : (laneInRow == 0 ? leftX : rightX);
      final y = startY + row * _laneSpacing;

      centres.add(Offset(x, y));
    }

    return (
      width: viewportW,
      height: height,
      centres: centres,
      axis: SerpentineAxis.vertical,
    );
  }

  static Offset? durationLabelAnchor(
    Offset from,
    Offset to, {
    required SerpentineAxis axis,
  }) {
    const tolerance = 10.0;
    final isVerticalSegment = (from.dx - to.dx).abs() < tolerance;
    final isHorizontalSegment = (from.dy - to.dy).abs() < tolerance;

    return switch (axis) {
      SerpentineAxis.horizontal => isHorizontalSegment
          ? Offset((from.dx + to.dx) / 2, from.dy - 18)
          : isVerticalSegment
              ? Offset(from.dx + 18, (from.dy + to.dy) / 2)
              : null,
      SerpentineAxis.vertical => isVerticalSegment
          ? Offset(from.dx + 18, (from.dy + to.dy) / 2)
          : isHorizontalSegment
              ? Offset((from.dx + to.dx) / 2, from.dy - 18)
              : null,
    };
  }
}
