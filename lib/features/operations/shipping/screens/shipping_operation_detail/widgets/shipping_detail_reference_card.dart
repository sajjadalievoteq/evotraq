import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/shipping/shipping_response_model.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation_detail/utils/shipping_detail_formatters.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation_detail/widgets/shipping_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation_detail/widgets/shipping_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation_detail/widgets/shipping_detail_info_row_copy.dart';

/// Reference details card for shipping operation detail.
class ShippingDetailReferenceCard extends StatelessWidget {
  const ShippingDetailReferenceCard({
    super.key,
    required this.operation,
  });

  final ShippingResponse operation;

  @override
  Widget build(BuildContext context) {
    return ShippingDetailGroupCard(
      title: 'Reference Details',
      children: [
        if (operation.shippingReference != null)
          ShippingDetailInfoRowCopy(
            label: 'Shipping Reference',
            value: operation.shippingReference!,
          ),
        if (operation.shippingOperationId != null)
          ShippingDetailInfoRowCopy(
            label: 'Operation ID',
            value: operation.shippingOperationId!,
          ),
        if (operation.processedAt != null)
          ShippingDetailInfoRow(
            label: 'Processed At',
            value: ShippingDetailFormatters.formatDateTime(operation.processedAt!),
          ),
      ],
    );
  }
}
