abstract final class HomeSectionLayoutUtils {
  static double throughputAndEventsPairHeight(double maxWidth) {
    return (360 + maxWidth * 0.04).clamp(320.0, 460.0);
  }
}
