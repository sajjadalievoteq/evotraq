import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/return_receiving/return_receiving_response_model.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_info_row_copy.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_formatters.dart';

class ReturnReceivingDetailReferenceCard extends StatelessWidget {
  const ReturnReceivingDetailReferenceCard({
    super.key,
    required this.operation,
  });

  final ReturnReceivingResponse operation;

  @override
  Widget build(BuildContext context) {
    return OperationDetailGroupCard(
      title: 'Reference Details',
      children: [
        if (operation.returnReceivingReference != null)
          OperationDetailInfoRowCopy(
            label: 'Return Receiving Reference',
            value: operation.returnReceivingReference!,
          ),
        if (operation.returnReceivingOperationId != null)
          OperationDetailInfoRowCopy(
            label: 'Operation ID',
            value: operation.returnReceivingOperationId!,
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

