import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/home/presentation/constants/home_strings.dart';
import 'package:traqtrace_app/features/home/presentation/widgets/throughput_chart/widgets/throughput_dummy_bar_chart.dart';
import 'package:traqtrace_app/shared/widgets/traq_section_title.dart';

import '../../../../../core/theme/traq_theme.dart';
import '../../../../../shared/layout/layout_manager.dart';

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
            const TraqSectionTitle(label: HomeStrings.sectionThroughput24h),
            const SizedBox(height: 12),
            const Expanded(child: ThroughputDummyBarChart()),
          ],
        ),
      ),
    );
  }
}
