import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/home/presentation/constants/home_strings.dart';
import 'package:traqtrace_app/features/home/presentation/widgets/key_metrics/widgets/key_metrics_grid.dart';
import 'package:traqtrace_app/shared/widgets/traq_section_title.dart';
import 'package:traqtrace_app/shared/layout/layout_manager.dart';

class KeyMetricsSection extends StatelessWidget {
  const KeyMetricsSection({super.key, required this.layout});

  final AppLayoutData layout;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const TraqSectionTitle(label: HomeStrings.sectionKeyMetrics),
        const SizedBox(height: 12),
        KeyMetricsGrid(layout: layout),
      ],
    );
  }
}
