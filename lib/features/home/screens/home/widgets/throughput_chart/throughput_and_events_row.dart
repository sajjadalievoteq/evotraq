import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/home/screens/home/utils/home_section_layout_utils.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/epcis_event_stream/epcis_event_stream_section.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/throughput_chart/throughput_chart_section.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';

class ThroughputAndEventsRow extends StatelessWidget {
  const ThroughputAndEventsRow({super.key, required this.layout});

  final AppLayoutData layout;

  @override
  Widget build(BuildContext context) {
    if (layout.isTabletUp) {
      return LayoutBuilder(
        builder: (context, c) {
          final h = HomeSectionLayoutUtils.throughputAndEventsPairHeight(
            c.maxWidth,
          );
          return SizedBox(
            height: h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Expanded(flex: 3, child: ThroughputChartSection()),
                SizedBox(width: layout.isCompact ? 12 : 20),
                const Expanded(flex: 2, child: EpcisEventStreamSection()),
              ],
            ),
          );
        },
      );
    }

    return LayoutBuilder(
      builder: (context, c) {
        final h = HomeSectionLayoutUtils.throughputAndEventsPairHeight(
          c.maxWidth,
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: h, child: const ThroughputChartSection()),
            SizedBox(height: layout.isCompact ? 16 : 20),
            const EpcisEventStreamSection(),
          ],
        );
      },
    );
  }
}
