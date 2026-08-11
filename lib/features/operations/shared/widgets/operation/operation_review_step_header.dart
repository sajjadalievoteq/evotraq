import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_status.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_epc_type_utils.dart';

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
