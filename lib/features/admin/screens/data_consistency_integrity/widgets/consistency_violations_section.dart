import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/features/admin/screens/data_consistency_integrity/widgets/consistency_violation_card.dart';

class ConsistencyViolationsSection extends StatelessWidget {
  const ConsistencyViolationsSection({
    super.key,
    required this.report,
    required this.onCorrect,
    required this.onViewDetails,
  });

  final Map<String, dynamic> report;
  final void Function(Map<String, dynamic> violation) onCorrect;
  final void Function(Map<String, dynamic> violation) onViewDetails;

  @override
  Widget build(BuildContext context) {
    final violations = (report['consistency_violations'] as List?) ?? [];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Consistency Violations',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (violations.isEmpty)
              Text(
                'No consistency violations found.',
                style: TextStyle(color: AppColorMapper.successColor(context)),
              )
            else
              ...violations.map(
                (violation) => ConsistencyViolationCard(
                  violation: Map<String, dynamic>.from(violation as Map),
                  onCorrect: () => onCorrect(
                    Map<String, dynamic>.from(violation),
                  ),
                  onViewDetails: () => onViewDetails(
                    Map<String, dynamic>.from(violation),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
