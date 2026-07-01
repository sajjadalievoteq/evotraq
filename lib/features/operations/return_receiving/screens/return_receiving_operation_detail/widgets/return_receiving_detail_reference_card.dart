import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/return_receiving/return_receiving_response_model.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation_detail/utils/return_receiving_detail_formatters.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation_detail/widgets/return_receiving_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation_detail/widgets/return_receiving_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation_detail/widgets/return_receiving_detail_info_row_copy.dart';

/// Reference details card for Return Receiving operation detail.
class ReturnReceivingDetailReferenceCard extends StatelessWidget {
  const ReturnReceivingDetailReferenceCard({
    super.key,
    required this.operation,
  });

  final ReturnReceivingResponse operation;

  @override
  Widget build(BuildContext context) {
    return ReturnReceivingDetailGroupCard(
      title: 'Reference Details',
      children: [
        if (operation.returnReceivingReference != null)
          ReturnReceivingDetailInfoRowCopy(
            label: 'Return Receiving Reference',
            value: operation.returnReceivingReference!,
          ),
        if (operation.returnReceivingOperationId != null)
          ReturnReceivingDetailInfoRowCopy(
            label: 'Operation ID',
            value: operation.returnReceivingOperationId!,
          ),
        if (operation.processedAt != null)
          ReturnReceivingDetailInfoRow(
            label: 'Processed At',
            value: ReturnReceivingDetailFormatters.formatDateTime(operation.processedAt!),
          ),
      ],
    );
  }
}

