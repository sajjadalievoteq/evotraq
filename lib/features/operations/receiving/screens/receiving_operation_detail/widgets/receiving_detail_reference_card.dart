import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/receiving/receiving_response_model.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_detail/utils/receiving_detail_formatters.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_detail/widgets/receiving_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_detail/widgets/receiving_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_detail/widgets/receiving_detail_info_row_copy.dart';

/// Reference details card for Receiving operation detail.
class ReceivingDetailReferenceCard extends StatelessWidget {
  const ReceivingDetailReferenceCard({
    super.key,
    required this.operation,
  });

  final ReceivingResponse operation;

  @override
  Widget build(BuildContext context) {
    return ReceivingDetailGroupCard(
      title: 'Reference Details',
      children: [
        if (operation.receivingReference != null)
          ReceivingDetailInfoRowCopy(
            label: 'Receiving Reference',
            value: operation.receivingReference!,
          ),
        if (operation.receivingOperationId != null)
          ReceivingDetailInfoRowCopy(
            label: 'Operation ID',
            value: operation.receivingOperationId!,
          ),
        if (operation.processedAt != null)
          ReceivingDetailInfoRow(
            label: 'Processed At',
            value: ReceivingDetailFormatters.formatDateTime(operation.processedAt!),
          ),
      ],
    );
  }
}
