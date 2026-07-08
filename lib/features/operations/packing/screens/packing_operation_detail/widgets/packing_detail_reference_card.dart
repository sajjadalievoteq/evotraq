import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/packing/packing_response_model.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_info_row_copy.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_formatters.dart';

class PackingDetailReferenceCard extends StatelessWidget {
  const PackingDetailReferenceCard({
    super.key,
    required this.operation,
  });

  final PackingResponse operation;

  @override
  Widget build(BuildContext context) {
    return OperationDetailGroupCard(
      title: 'Reference Details',
      children: [
        if (operation.packingReference != null)
          OperationDetailInfoRowCopy(
            label: 'Packing Reference',
            value: operation.packingReference!,
          ),
        if (operation.operatorId != null)
          OperationDetailInfoRow(label: 'Operator ID', value: operation.operatorId!),
        if (operation.processedAt != null)
          OperationDetailInfoRow(
            label: 'Processed At',
            value: OperationDetailFormatters.formatDateTime(operation.processedAt!),
          ),
      ],
    );
  }
}
