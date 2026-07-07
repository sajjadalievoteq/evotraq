import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/product_journey/journey_step.dart';

/// Serpentine track orientation.
enum SerpentineAxis {
  /// Two rows, pins advance in columns left→right (desktop).
  horizontal,

  /// Two columns, pins advance in rows top→bottom (mobile / tablet).
  vertical,
}

/// Pin placement and serpentine track geometry for the journey canvas.
abstract final class JourneyPinLayout {
  static const double pinRadius = 30.0;
  static const double pinWidth = 168.0;

  /// Circle + tip + callout + START/LATEST badge (conservative estimate).
  static const double pinHeight = 230.0;

  static const double _laneSpacing = 280.0;
  static const double _edgePad = 80.0;

  static int seedForSteps(List<JourneyStep> steps) {
    var hash = steps.length;
    for (final step in steps) {
      hash = Object.hash(hash, step.eventId);
    }
    return hash;
  }

  /// Lays out N pins in a 2-lane serpentine grid.
  ///
  /// [horizontal]: two rows at ¼ and ¾ viewport height; columns advance left→right.
  /// [vertical]: two columns at ¼ and ¾ viewport width; rows advance top→bottom.
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
      return (
        width: viewportW,
        height: viewportH,
        centres: [Offset(viewportW / 2, viewportH / 2)],
        axis: axis,
      );
    }

    return switch (axis) {
      SerpentineAxis.horizontal => _horizontalSerpentine(
          count: count,
          viewportW: viewportW,
          viewportH: viewportH,
        ),
      SerpentineAxis.vertical => _verticalSerpentine(
          count: count,
          viewportW: viewportW,
          viewportH: viewportH,
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
  }) {
    const lanes = 2;
    final topY = viewportH * 0.25;
    final bottomY = viewportH * 0.75;
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
      height: viewportH,
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
  }) {
    const lanes = 2;
    final leftX = viewportW * 0.25;
    final rightX = viewportW * 0.75;
    final startY = viewportH * 0.25;

    final rows = (count / lanes).ceil();
    final height = math.max(
      viewportH,
      startY + (rows - 1) * _laneSpacing + startY,
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

  /// Duration chips sit on the long axis of travel (horizontal segments for
  /// vertical layout, vertical segments for horizontal layout).
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
