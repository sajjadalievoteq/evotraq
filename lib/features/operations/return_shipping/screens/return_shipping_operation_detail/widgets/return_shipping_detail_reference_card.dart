import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/return_shipping/return_shipping_response_model.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_info_row_copy.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_formatters.dart';

class ReturnShippingDetailReferenceCard extends StatelessWidget {
  const ReturnShippingDetailReferenceCard({
    super.key,
    required this.operation,
  });

  final ReturnShippingResponse operation;

  @override
  Widget build(BuildContext context) {
    return OperationDetailGroupCard(
      title: 'Reference Details',
      children: [
        if (operation.returnReference != null)
          OperationDetailInfoRowCopy(
            label: 'Return Shipping Reference',
            value: operation.returnReference!,
          ),
        if (operation.returnShippingOperationId != null)
          OperationDetailInfoRowCopy(
            label: 'Operation ID',
            value: operation.returnShippingOperationId!,
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
