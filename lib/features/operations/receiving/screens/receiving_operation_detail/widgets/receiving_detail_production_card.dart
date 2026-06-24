import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/receiving/receiving_response_model.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_detail/widgets/receiving_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_detail/widgets/receiving_detail_info_row.dart';

/// Transport and reference group card for Receiving operation detail.
class ReceivingDetailProductionCard extends StatelessWidget {
  const ReceivingDetailProductionCard({
    super.key,
    required this.operation,
  });

  final ReceivingResponse operation;

  @override
  Widget build(BuildContext context) {
    return ReceivingDetailGroupCard(
      title: 'Shipment Group Details',
      children: [
        if (operation.carrier != null)
          ReceivingDetailInfoRow(label: 'Carrier', value: operation.carrier!),
        if (operation.trackingNumber != null)
          ReceivingDetailInfoRow(label: 'Tracking Number', value: operation.trackingNumber!),
        if (operation.billOfLadingNumber != null)
          ReceivingDetailInfoRow(label: 'Bill of Lading', value: operation.billOfLadingNumber!),
        if (operation.purchaseOrderNumber != null)
          ReceivingDetailInfoRow(label: 'Purchase Order', value: operation.purchaseOrderNumber!),
        if (operation.despatchAdviceNumber != null)
          ReceivingDetailInfoRow(label: 'Despatch Advice', value: operation.despatchAdviceNumber!),
        if (operation.receivingAdviceNumber != null)
          ReceivingDetailInfoRow(
            label: 'Receiving Advice (RECADV)',
            value: operation.receivingAdviceNumber!,
          ),
      ],
    );
  }
}
