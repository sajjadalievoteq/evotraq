import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/return_receiving/return_receiving_response_model.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation_detail/widgets/return_receiving_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation_detail/widgets/return_receiving_detail_info_row.dart';

/// Transport and reference group card for Return Receiving operation detail.
class ReturnReceivingDetailProductionCard extends StatelessWidget {
  const ReturnReceivingDetailProductionCard({
    super.key,
    required this.operation,
  });

  final ReturnReceivingResponse operation;

  @override
  Widget build(BuildContext context) {
    return ReturnReceivingDetailGroupCard(
      title: 'Shipment Group Details',
      children: [
        if (operation.carrier != null)
          ReturnReceivingDetailInfoRow(label: 'Carrier', value: operation.carrier!),
        if (operation.trackingNumber != null)
          ReturnReceivingDetailInfoRow(label: 'Tracking Number', value: operation.trackingNumber!),
        if (operation.billOfLadingNumber != null)
          ReturnReceivingDetailInfoRow(label: 'Bill of Lading', value: operation.billOfLadingNumber!),
        if (operation.purchaseOrderNumber != null)
          ReturnReceivingDetailInfoRow(label: 'Purchase Order', value: operation.purchaseOrderNumber!),
        if (operation.despatchAdviceNumber != null)
          ReturnReceivingDetailInfoRow(label: 'Despatch Advice', value: operation.despatchAdviceNumber!),
        if (operation.receivingAdviceNumber != null)
          ReturnReceivingDetailInfoRow(
            label: 'Return Receiving Advice (RECADV)',
            value: operation.receivingAdviceNumber!,
          ),
      ],
    );
  }
}

