import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/return_shipping/return_shipping_response_model.dart';
import 'package:traqtrace_app/features/operations/return_shipping/screens/return_shipping_operation_detail/utils/return_shipping_detail_formatters.dart';
import 'package:traqtrace_app/features/operations/return_shipping/screens/return_shipping_operation_detail/widgets/return_shipping_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/return_shipping/screens/return_shipping_operation_detail/widgets/return_shipping_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/return_shipping/screens/return_shipping_operation_detail/widgets/return_shipping_detail_info_row_copy.dart';

/// Reference details card for shipping operation detail.
class ReturnShippingDetailReferenceCard extends StatelessWidget {
  const ReturnShippingDetailReferenceCard({
    super.key,
    required this.operation,
  });

  final ReturnShippingResponse operation;

  @override
  Widget build(BuildContext context) {
    return ReturnShippingDetailGroupCard(
      title: 'Reference Details',
      children: [
        if (operation.returnReference != null)
          ReturnShippingDetailInfoRowCopy(
            label: 'Return Shipping Reference',
            value: operation.returnReference!,
          ),
        if (operation.returnShippingOperationId != null)
          ReturnShippingDetailInfoRowCopy(
            label: 'Operation ID',
            value: operation.returnShippingOperationId!,
          ),
        if (operation.processedAt != null)
          ReturnShippingDetailInfoRow(
            label: 'Processed At',
            value: ReturnShippingDetailFormatters.formatDateTime(operation.processedAt!),
          ),
      ],
    );
  }
}
