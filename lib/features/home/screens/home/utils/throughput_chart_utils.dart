abstract final class ThroughputChartUtils {
  static double niceInterval(double maxY) {
    if (maxY <= 0) return 10;
    const steps = [1, 2, 5, 10, 20, 50, 100, 200, 500, 1000, 2000, 5000];
    final target = maxY / 4;
    for (final s in steps) {
      if (s >= target) return s.toDouble();
    }
    return ((maxY / 4) / 1000).ceilToDouble() * 1000;
  }
}
