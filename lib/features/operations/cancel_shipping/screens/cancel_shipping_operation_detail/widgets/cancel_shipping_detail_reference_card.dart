import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/cancel_shipping/cancel_shipping_response_model.dart';
import 'package:traqtrace_app/features/operations/cancel_shipping/screens/cancel_shipping_operation_detail/utils/cancel_shipping_detail_formatters.dart';
import 'package:traqtrace_app/features/operations/cancel_shipping/screens/cancel_shipping_operation_detail/widgets/cancel_shipping_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/cancel_shipping/screens/cancel_shipping_operation_detail/widgets/cancel_shipping_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/cancel_shipping/screens/cancel_shipping_operation_detail/widgets/cancel_shipping_detail_info_row_copy.dart';

class CancelShippingDetailReferenceCard extends StatelessWidget {
  const CancelShippingDetailReferenceCard({
    super.key,
    required this.operation,
  });

  final CancelShippingResponse operation;

  @override
  Widget build(BuildContext context) {
    return CancelShippingDetailGroupCard(
      title: 'Reference Details',
      children: [
        if (operation.cancelShippingReference != null)
          CancelShippingDetailInfoRowCopy(
            label: 'Cancel Shipping Reference',
            value: operation.cancelShippingReference!,
          ),
        if (operation.originalShippingReference != null)
          CancelShippingDetailInfoRowCopy(
            label: 'Original GINC',
            value: operation.originalShippingReference!,
          ),
        if (operation.cancelReason != null)
          CancelShippingDetailInfoRow(
            label: 'Cancellation Reason',
            value: operation.cancelReason!,
          ),
        if (operation.cancelShippingOperationId != null)
          CancelShippingDetailInfoRowCopy(
            label: 'Operation ID',
            value: operation.cancelShippingOperationId!,
          ),
        if (operation.processedAt != null)
          CancelShippingDetailInfoRow(
            label: 'Processed At',
            value: CancelShippingDetailFormatters.formatDateTime(operation.processedAt!),
          ),
      ],
    );
  }
}
