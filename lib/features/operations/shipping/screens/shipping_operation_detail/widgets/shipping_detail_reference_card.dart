import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/shipping/shipping_response_model.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_info_row_copy.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_formatters.dart';

/// Reference details card for shipping operation detail.
class ShippingDetailReferenceCard extends StatelessWidget {
  const ShippingDetailReferenceCard({
    super.key,
    required this.operation,
  });

  final ShippingResponse operation;

  @override
  Widget build(BuildContext context) {
    return OperationDetailGroupCard(
      title: 'Reference Details',
      children: [
        if (operation.shippingReference != null)
          OperationDetailInfoRowCopy(
            label: 'Shipping Reference',
            value: operation.shippingReference!,
          ),
        if (operation.shippingOperationId != null)
          OperationDetailInfoRowCopy(
            label: 'Operation ID',
            value: operation.shippingOperationId!,
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
