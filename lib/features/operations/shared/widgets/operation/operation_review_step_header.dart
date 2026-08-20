import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';

class OperationReviewStepHeader extends StatelessWidget {
  const OperationReviewStepHeader({
    super.key,
    required this.title,
    this.showPageHeader = true,
    this.subtitle = 'Please review all details before submitting.',
  });

  final String title;
  final bool showPageHeader;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(title),
        if (showPageHeader) ...[
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(color: Colors.grey)),
        ],
        const SizedBox(height: 16),
      ],
    );
  }
}
