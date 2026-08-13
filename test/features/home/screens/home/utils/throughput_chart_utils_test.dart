import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/features/home/screens/home/utils/throughput_chart_utils.dart';

void main() {
  test('placeholder heights are deterministic and cycle the pattern', () {
    final first = ThroughputChartUtils.placeholderHeights(8);
    final second = ThroughputChartUtils.placeholderHeights(8);

    expect(first, ThroughputChartUtils.placeholderFractions.sublist(0, 8));
    expect(first, second);
    expect(first, isNot(everyElement(0)));

    final twentyFour = ThroughputChartUtils.placeholderHeights(24);
    expect(twentyFour.length, 24);
    expect(twentyFour[0], twentyFour[12]);
    expect(twentyFour[8], ThroughputChartUtils.placeholderFractions[8]);
  });

  test('zero throughput uses a quiet positive axis, not a collapsed one', () {
    expect(ThroughputChartUtils.chartMaxY(0), 10);
    expect(ThroughputChartUtils.chartMaxY(50), 60);
  });
}
