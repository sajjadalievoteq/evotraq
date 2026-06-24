import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/home/utils/home_strings.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/compliance_posture/widgets/system_health_card.dart';
import 'package:traqtrace_app/core/widgets/traq_section_title.dart';

class CompliancePostureSection extends StatelessWidget {
  const CompliancePostureSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TraqSectionTitle(label: HomeStrings.sectionCompliancePosture),
        SizedBox(height: 12),
        SystemHealthCard(),
      ],
    );
  }
}
