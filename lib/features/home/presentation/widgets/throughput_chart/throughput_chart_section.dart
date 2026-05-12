import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/home/presentation/widgets/shared/home_section_title.dart';
import 'package:traqtrace_app/features/home/presentation/widgets/throughput_chart/widgets/throughput_dummy_bar_chart.dart';

class ThroughputChartSection extends StatelessWidget {
  const ThroughputChartSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(

      clipBehavior: Clip.antiAlias,

      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            const HomeSectionTitle(label: 'COMMISSIONING THROUGHPUT — 24H'),
            const SizedBox(height: 12),
            const Expanded(child: ThroughputDummyBarChart()),
          ],
        ),
      ),
    );
  }
}
