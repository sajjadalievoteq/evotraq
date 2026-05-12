import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/home/presentation/widgets/quick_actions/widgets/quick_actions_grid.dart';
import 'package:traqtrace_app/features/home/presentation/widgets/shared/home_section_title.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HomeSectionTitle(label: 'QUICK ACTIONS'),
        SizedBox(height: 12),
        QuickActionsGrid(),
      ],
    );
  }
}
