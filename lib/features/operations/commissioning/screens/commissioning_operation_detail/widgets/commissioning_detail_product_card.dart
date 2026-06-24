import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_detail/widgets/commissioning_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_detail/widgets/commissioning_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_detail/widgets/commissioning_detail_info_row_copy.dart';

class CommissioningDetailProductCard extends StatelessWidget {
  const CommissioningDetailProductCard({
    super.key,
    required this.batch,
  });

  final CommissioningBatch batch;

  @override
  Widget build(BuildContext context) {
    return CommissioningDetailGroupCard(
      title: 'Product Details',
      children: [
        if (batch.gtinCode != null)
          CommissioningDetailInfoRowCopy(label: 'GTIN', value: batch.gtinCode!),
        if (batch.batchLotNumber != null)
          CommissioningDetailInfoRow(
            label: 'Lot / Batch Number',
            value: batch.batchLotNumber!,
          ),
        if (batch.productionDate != null)
          CommissioningDetailInfoRow(
            label: 'Production Date',
            value: DateFormat('MMM dd, yyyy').format(batch.productionDate!),
          ),
        if (batch.expiryDate != null)
          CommissioningDetailInfoRow(
            label: 'Expiry Date',
            value: DateFormat('MMM dd, yyyy').format(batch.expiryDate!),
          ),
      ],
    );
  }
}
