import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/cancel_receiving/cancel_receiving_response_model.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_info_row_copy.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_formatters.dart';

class CancelReceivingDetailReferenceCard extends StatelessWidget {
  const CancelReceivingDetailReferenceCard({
    super.key,
    required this.operation,
  });

  final CancelReceivingResponse operation;

  @override
  Widget build(BuildContext context) {
    return OperationDetailGroupCard(
      title: 'Reference Details',
      children: [
        if (operation.cancelReceivingReference != null)
          OperationDetailInfoRowCopy(
            label: 'Cancel Receiving Reference',
            value: operation.cancelReceivingReference!,
          ),
        if (operation.originalReceivingReference != null)
          OperationDetailInfoRowCopy(
            label: 'Original GINC',
            value: operation.originalReceivingReference!,
          ),
        if (operation.cancelReason != null)
          OperationDetailInfoRow(
            label: 'Cancellation Reason',
            value: operation.cancelReason!,
          ),
        if (operation.cancelReceivingOperationId != null)
          OperationDetailInfoRowCopy(
            label: 'Operation ID',
            value: operation.cancelReceivingOperationId!,
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
