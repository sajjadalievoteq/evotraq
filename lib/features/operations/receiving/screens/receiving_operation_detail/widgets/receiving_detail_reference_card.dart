import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/receiving/receiving_response_model.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_info_row_copy.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_formatters.dart';

/// Reference details card for Receiving operation detail.
class ReceivingDetailReferenceCard extends StatelessWidget {
  const ReceivingDetailReferenceCard({
    super.key,
    required this.operation,
  });

  final ReceivingResponse operation;

  @override
  Widget build(BuildContext context) {
    return OperationDetailGroupCard(
      title: 'Reference Details',
      children: [
        if (operation.acceptingReference != null)
          OperationDetailInfoRowCopy(
            label: 'Accepting Reference',
            value: operation.acceptingReference!,
          ),
        if (operation.receivingReference != null)
          OperationDetailInfoRowCopy(
            label: 'Receiving Reference',
            value: operation.receivingReference!,
          ),
        if (operation.receivingOperationId != null)
          OperationDetailInfoRowCopy(
            label: 'Operation ID',
            value: operation.receivingOperationId!,
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
