import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/home/presentation/widgets/compliance_posture/widgets/system_health_card.dart';
import 'package:traqtrace_app/features/home/presentation/widgets/shared/home_section_title.dart';

class CompliancePostureSection extends StatelessWidget {
  const CompliancePostureSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HomeSectionTitle(label: 'COMPLIANCE POSTURE'),
        SizedBox(height: 12),
        SystemHealthCard(),
      ],
    );
  }
}
