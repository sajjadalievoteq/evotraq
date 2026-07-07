import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_info_row.dart';

/// Shared production-line detail card for packing/unpacking operations.
class OperationDetailProductionCard extends StatelessWidget {
  const OperationDetailProductionCard({
    super.key,
    required this.title,
    this.workOrderNumber,
    this.batchNumber,
    this.productionOrder,
    this.batchLabel = 'Batch',
    this.lineLabel = 'Line',
    this.lineValue,
    this.operatorId,
    this.extraChildren = const [],
  });

  final String title;
  final String? workOrderNumber;
  final String? batchNumber;
  final String batchLabel;
  final String? productionOrder;
  final String lineLabel;
  final String? lineValue;
  final String? operatorId;
  final List<Widget> extraChildren;

  @override
  Widget build(BuildContext context) {
    return OperationDetailGroupCard(
      title: title,
      children: [
        if (workOrderNumber?.isNotEmpty == true)
          OperationDetailInfoRow(label: 'Work Order', value: workOrderNumber!),
        if (batchNumber?.isNotEmpty == true)
          OperationDetailInfoRow(label: batchLabel, value: batchNumber!),
        if (productionOrder?.isNotEmpty == true)
          OperationDetailInfoRow(
            label: 'Production Order',
            value: productionOrder!,
          ),
        if (lineValue?.isNotEmpty == true)
          OperationDetailInfoRow(label: lineLabel, value: lineValue!),
        if (operatorId?.isNotEmpty == true)
          OperationDetailInfoRow(label: 'Operator', value: operatorId!),
        ...extraChildren,
      ],
    );
  }
}
