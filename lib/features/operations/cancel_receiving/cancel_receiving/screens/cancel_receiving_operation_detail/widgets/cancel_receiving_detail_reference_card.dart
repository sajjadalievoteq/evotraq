import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/cancel_receiving/cancel_receiving_response_model.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/screens/cancel_receiving_operation_detail/utils/cancel_receiving_detail_formatters.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/screens/cancel_receiving_operation_detail/widgets/cancel_receiving_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/screens/cancel_receiving_operation_detail/widgets/cancel_receiving_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/screens/cancel_receiving_operation_detail/widgets/cancel_receiving_detail_info_row_copy.dart';

class CancelReceivingDetailReferenceCard extends StatelessWidget {
  const CancelReceivingDetailReferenceCard({
    super.key,
    required this.operation,
  });

  final CancelReceivingResponse operation;

  @override
  Widget build(BuildContext context) {
    return CancelReceivingDetailGroupCard(
      title: 'Reference Details',
      children: [
        if (operation.cancelShippingReference != null)
          CancelReceivingDetailInfoRowCopy(
            label: 'Cancel Receiving Reference',
            value: operation.cancelShippingReference!,
          ),
        if (operation.originalReceivingReference != null)
          CancelReceivingDetailInfoRowCopy(
            label: 'Original GINC',
            value: operation.originalReceivingReference!,
          ),
        if (operation.cancelReason != null)
          CancelReceivingDetailInfoRow(
            label: 'Cancellation Reason',
            value: operation.cancelReason!,
          ),
        if (operation.cancelShippingOperationId != null)
          CancelReceivingDetailInfoRowCopy(
            label: 'Operation ID',
            value: operation.cancelShippingOperationId!,
          ),
        if (operation.processedAt != null)
          CancelReceivingDetailInfoRow(
            label: 'Processed At',
            value: CancelReceivingDetailFormatters.formatDateTime(operation.processedAt!),
          ),
      ],
    );
  }
}
