abstract final class ThroughputChartUtils {
  /// Deterministic loading silhouette. Cycled when the selected range has
  /// more bars than this pattern (e.g. 24 hourly buckets).
  static const List<double> placeholderFractions = [
    0.30,
    0.55,
    0.42,
    0.78,
    0.48,
    0.67,
    0.38,
    0.58,
    0.50,
    0.72,
    0.35,
    0.62,
  ];

  static double niceInterval(double maxY) {
    if (maxY <= 0) return 10;
    const steps = [1, 2, 5, 10, 20, 50, 100, 200, 500, 1000, 2000, 5000];
    final target = maxY / 4;
    for (final s in steps) {
      if (s >= target) return s.toDouble();
    }
    return ((maxY / 4) / 1000).ceilToDouble() * 1000;
  }

  static List<double> placeholderHeights(int count) {
    if (count <= 0) return const [];
    return List<double>.generate(
      count,
      (i) => placeholderFractions[i % placeholderFractions.length],
    );
  }

  static double chartMaxY(double maxVal) {
    if (maxVal <= 0) return 10;
    final interval = niceInterval(maxVal);
    return interval * (maxVal / interval).ceil();
  }
}
