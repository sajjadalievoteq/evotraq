import 'dart:math' show log, pi, sin;

abstract final class DashboardStatCardSparklineUtils {
  static int? parseMetricValue(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return null;
    return int.tryParse(digits);
  }

  static List<double>? sparklineFromMetric(int n) {
    if (n <= 0) return null;
    const points = 22;
    final logN = log(n + 1);
    final logRef = log(100001);
    final hi = (logN / logRef).clamp(0.2, 0.92);
    final lo = (hi * 0.5).clamp(0.14, hi);
    return List.generate(points, (i) {
      final t = points <= 1 ? 0.0 : i / (points - 1);
      final mid = lo + (hi - lo) * t;
      final ripple = 0.035 * sin(2 * pi * 2.5 * t + n % 7);
      return (mid + ripple).clamp(0.1, 0.98);
    });
  }
}
