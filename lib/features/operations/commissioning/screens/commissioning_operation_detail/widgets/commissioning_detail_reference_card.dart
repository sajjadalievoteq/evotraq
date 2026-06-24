import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_detail/widgets/commissioning_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_detail/widgets/commissioning_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_detail/widgets/commissioning_detail_info_row_copy.dart';

class CommissioningDetailReferenceCard extends StatelessWidget {
  const CommissioningDetailReferenceCard({
    super.key,
    required this.batch,
  });

  final CommissioningBatch batch;

  @override
  Widget build(BuildContext context) {
    return CommissioningDetailGroupCard(
      title: 'Reference Details',
      children: [
        CommissioningDetailInfoRowCopy(label: 'Operation ID', value: batch.batchId),
        if (batch.commissioningReference != null)
          CommissioningDetailInfoRow(
            label: 'Reference',
            value: batch.commissioningReference!,
          ),
        if (batch.epcisEventId != null)
          CommissioningDetailInfoRowCopy(
            label: 'EPCIS Event ID',
            value: batch.epcisEventId!,
          ),
        if (batch.createdAt != null)
          CommissioningDetailInfoRow(
            label: 'Created At',
            value: DateFormat('MMM dd, yyyy HH:mm:ss').format(batch.createdAt!),
          ),
        if (batch.completedAt != null)
          CommissioningDetailInfoRow(
            label: 'Completed At',
            value:
                DateFormat('MMM dd, yyyy HH:mm:ss').format(batch.completedAt!),
          ),
        if (batch.createdBy != null)
          CommissioningDetailInfoRow(label: 'Created By', value: batch.createdBy!),
        if (batch.operatorId != null)
          CommissioningDetailInfoRow(label: 'Operator ID', value: batch.operatorId!),
      ],
    );
  }
}
