import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/home/presentation/constants/home_strings.dart';
import 'package:traqtrace_app/features/home/presentation/widgets/quick_actions/widgets/quick_actions_grid.dart';
import 'package:traqtrace_app/core/widgets/traq_section_title.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TraqSectionTitle(label: HomeStrings.sectionQuickActions),
        SizedBox(height: 12),
        QuickActionsGrid(),
      ],
    );
  }
}
