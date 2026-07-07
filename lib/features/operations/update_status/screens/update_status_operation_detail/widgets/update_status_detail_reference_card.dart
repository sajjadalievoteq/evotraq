import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/update_status/update_status_response_model.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_info_row_copy.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_formatters.dart';

/// Reference details card for Decommissioning operation detail.
class UpdateStatusDetailReferenceCard extends StatelessWidget {
  const UpdateStatusDetailReferenceCard({
    super.key,
    required this.operation,
  });

  final UpdateStatusResponse operation;

  @override
  Widget build(BuildContext context) {
    return OperationDetailGroupCard(
      title: 'Reference Details',
      children: [
        if (operation.decommissioningReference != null)
          OperationDetailInfoRowCopy(
            label: 'Update Status Reference',
            value: operation.decommissioningReference!,
          ),
        if (operation.decommissioningOperationId != null)
          OperationDetailInfoRowCopy(
            label: 'Operation ID',
            value: operation.decommissioningOperationId!,
          ),
        if (operation.processedAt != null)
          OperationDetailInfoRow(
            label: 'Processed At',
            value: OperationDetailFormatters.formatDateTime(operation.processedAt!),
          ),
      ],
    );
  }
}
