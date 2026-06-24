import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/packing/packing_response_model.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_detail/widgets/packing_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_detail/widgets/packing_detail_info_row.dart';

/// Production details card for packing operation detail.
class PackingDetailProductionCard extends StatelessWidget {
  const PackingDetailProductionCard({
    super.key,
    required this.operation,
  });

  final PackingResponse operation;

  @override
  Widget build(BuildContext context) {
    return PackingDetailGroupCard(
      title: 'Production Details',
      children: [
        if (operation.workOrderNumber != null)
          PackingDetailInfoRow(label: 'Work Order', value: operation.workOrderNumber!),
        if (operation.batchNumber != null)
          PackingDetailInfoRow(label: 'Batch Number', value: operation.batchNumber!),
        if (operation.productionOrder != null)
          PackingDetailInfoRow(label: 'Production Order', value: operation.productionOrder!),
        if (operation.packingLine != null)
          PackingDetailInfoRow(label: 'Packing Line', value: operation.packingLine!),
      ],
    );
  }
}
