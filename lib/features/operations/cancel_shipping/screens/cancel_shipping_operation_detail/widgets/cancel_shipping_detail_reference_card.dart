import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/cancel_shipping/cancel_shipping_response_model.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_info_row_copy.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_formatters.dart';

class CancelShippingDetailReferenceCard extends StatelessWidget {
  const CancelShippingDetailReferenceCard({
    super.key,
    required this.operation,
  });

  final CancelShippingResponse operation;

  @override
  Widget build(BuildContext context) {
    return OperationDetailGroupCard(
      title: 'Reference Details',
      children: [
        if (operation.cancelShippingReference != null)
          OperationDetailInfoRowCopy(
            label: 'Cancel Shipping Reference',
            value: operation.cancelShippingReference!,
          ),
        if (operation.originalShippingReference != null)
          OperationDetailInfoRowCopy(
            label: 'Original GINC',
            value: operation.originalShippingReference!,
          ),
        if (operation.cancelReason != null)
          OperationDetailInfoRow(
            label: 'Cancellation Reason',
            value: operation.cancelReason!,
          ),
        if (operation.cancelShippingOperationId != null)
          OperationDetailInfoRowCopy(
            label: 'Operation ID',
            value: operation.cancelShippingOperationId!,
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
