import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/auth/utils/auth_role_context.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/compliance_posture/compliance_posture_section.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/quick_actions/quick_actions_section.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';

class QuickActionsAndComplianceRow extends StatelessWidget {
  const QuickActionsAndComplianceRow({super.key, required this.layout});

  final AppLayoutData layout;

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.isAdmin;

    if (layout.isTabletUp) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: isAdmin ? 3 : 1,
            child: const QuickActionsSection(),
          ),
          if (isAdmin) ...[
            SizedBox(width: layout.isCompact ? 12 : 20),
            const Expanded(flex: 2, child: CompliancePostureSection()),
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const QuickActionsSection(),
        if (isAdmin) ...[
          SizedBox(height: layout.isCompact ? 16 : 20),
          const CompliancePostureSection(),
        ],
      ],
    );
  }
}
