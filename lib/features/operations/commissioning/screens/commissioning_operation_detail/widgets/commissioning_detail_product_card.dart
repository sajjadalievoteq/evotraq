import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_info_row_copy.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_info_row.dart';

class CommissioningDetailProductCard extends StatelessWidget {
  const CommissioningDetailProductCard({
    super.key,
    required this.batch,
  });

  final CommissioningBatch batch;

  @override
  Widget build(BuildContext context) {
    return OperationDetailGroupCard(
      title: 'Product Details',
      children: [
        if (batch.gtinCode != null)
          OperationDetailInfoRowCopy(label: 'GTIN', value: batch.gtinCode!),
        if (batch.batchLotNumber != null)
          OperationDetailInfoRow(
            label: 'Lot / Batch Number',
            value: batch.batchLotNumber!,
          ),
        if (batch.productionDate != null)
          OperationDetailInfoRow(
            label: 'Production Date',
            value: DateFormat('MMM dd, yyyy').format(batch.productionDate!),
          ),
        if (batch.expiryDate != null)
          OperationDetailInfoRow(
            label: 'Expiry Date',
            value: DateFormat('MMM dd, yyyy').format(batch.expiryDate!),
          ),
      ],
    );
  }
}
