import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/unpacking/unpacking_response_model.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_detail/widgets/unpacking_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_detail/widgets/unpacking_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/unpacking/utils/unpacking_status_utils.dart';

/// Processing info card for unpacking operation detail.
class UnpackingDetailProcessingStatsCard extends StatelessWidget {
  const UnpackingDetailProcessingStatsCard({
    super.key,
    required this.operation,
  });

  final UnpackingResponse operation;

  @override
  Widget build(BuildContext context) {
    return UnpackingDetailGroupCard(
      title: 'Processing Info',
      children: [
        if (operation.processingTimeMs != null)
          UnpackingDetailInfoRow(
            label: 'Processing Time',
            value: '${operation.processingTimeMs} ms',
          ),
        UnpackingDetailInfoRow(
          label: 'Status',
          value: UnpackingStatusUtils.detailLabel(operation.status),
        ),
      ],
    );
  }
}
