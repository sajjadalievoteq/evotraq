import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/compliance_posture/compliance_posture_section.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/quick_actions/quick_actions_section.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';

class QuickActionsAndComplianceRow extends StatelessWidget {
  const QuickActionsAndComplianceRow({super.key, required this.layout});

  final AppLayoutData layout;

  @override
  Widget build(BuildContext context) {
    if (layout.isTabletUp) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(flex: 3, child: QuickActionsSection()),
          SizedBox(width: layout.isCompact ? 12 : 20),
          const Expanded(flex: 2, child: CompliancePostureSection()),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const QuickActionsSection(),
        SizedBox(height: layout.isCompact ? 16 : 20),
        const CompliancePostureSection(),
      ],
    );
  }
}
