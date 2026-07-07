import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_info_row_copy.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_info_row.dart';

class CommissioningDetailReferenceCard extends StatelessWidget {
  const CommissioningDetailReferenceCard({
    super.key,
    required this.batch,
  });

  final CommissioningBatch batch;

  @override
  Widget build(BuildContext context) {
    return OperationDetailGroupCard(
      title: 'Reference Details',
      children: [
        OperationDetailInfoRowCopy(label: 'Operation ID', value: batch.batchId),
        if (batch.commissioningReference != null)
          OperationDetailInfoRow(
            label: 'Reference',
            value: batch.commissioningReference!,
          ),
        if (batch.epcisEventId != null)
          OperationDetailInfoRowCopy(
            label: 'EPCIS Event ID',
            value: batch.epcisEventId!,
          ),
        if (batch.createdAt != null)
          OperationDetailInfoRow(
            label: 'Created At',
            value: DateFormat('MMM dd, yyyy HH:mm:ss').format(batch.createdAt!),
          ),
        if (batch.completedAt != null)
          OperationDetailInfoRow(
            label: 'Completed At',
            value:
                DateFormat('MMM dd, yyyy HH:mm:ss').format(batch.completedAt!),
          ),
        if (batch.createdBy != null)
          OperationDetailInfoRow(label: 'Created By', value: batch.createdBy!),
        if (batch.operatorId != null)
          OperationDetailInfoRow(label: 'Operator ID', value: batch.operatorId!),
      ],
    );
  }
}
