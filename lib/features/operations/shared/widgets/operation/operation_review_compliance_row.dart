import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_status.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_epc_type_utils.dart';

class OperationReviewComplianceRow extends StatelessWidget {
  const OperationReviewComplianceRow(this.label, this.value, {super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final missing = value.trim().isEmpty;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Text(
            missing
                ? 'âš  Not provided â€” DSCSA requires the original GINC'
                : value,
            style: TextStyle(
              color: missing
                  ? AppColorMapper.operationStatusColor(
                      context,
                      OperationStatus.partialSuccess,
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
