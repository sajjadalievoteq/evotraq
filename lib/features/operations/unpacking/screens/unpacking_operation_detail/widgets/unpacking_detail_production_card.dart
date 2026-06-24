import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/unpacking/unpacking_response_model.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_detail/widgets/unpacking_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_detail/widgets/unpacking_detail_info_row.dart';

/// Production details card for unpacking operation detail.
class UnpackingDetailProductionCard extends StatelessWidget {
  const UnpackingDetailProductionCard({
    super.key,
    required this.operation,
  });

  final UnpackingResponse operation;

  @override
  Widget build(BuildContext context) {
    return UnpackingDetailGroupCard(
      title: 'Production Details',
      children: [
        if (operation.workOrderNumber != null)
          UnpackingDetailInfoRow(label: 'Work Order', value: operation.workOrderNumber!),
        if (operation.batchNumber != null)
          UnpackingDetailInfoRow(label: 'Batch Number', value: operation.batchNumber!),
        if (operation.productionOrder != null)
          UnpackingDetailInfoRow(label: 'Production Order', value: operation.productionOrder!),
        if (operation.unpackingLine != null)
          UnpackingDetailInfoRow(label: 'Unpacking Line', value: operation.unpackingLine!),
      ],
    );
  }
}
