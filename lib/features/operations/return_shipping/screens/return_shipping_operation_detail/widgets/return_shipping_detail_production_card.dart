import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/return_shipping/return_shipping_response_model.dart';
import 'package:traqtrace_app/features/operations/return_shipping/screens/return_shipping_operation_detail/widgets/return_shipping_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/return_shipping/screens/return_shipping_operation_detail/widgets/return_shipping_detail_info_row.dart';

/// Transport and reference group card for shipping operation detail.
class ReturnShippingDetailProductionCard extends StatelessWidget {
  const ReturnShippingDetailProductionCard({
    super.key,
    required this.operation,
  });

  final ReturnShippingResponse operation;

  @override
  Widget build(BuildContext context) {
    return ReturnShippingDetailGroupCard(
      title: 'Shipment Group Details',
      children: [
        if (operation.carrier != null)
          ReturnShippingDetailInfoRow(label: 'Carrier', value: operation.carrier!),
        if (operation.trackingNumber != null)
          ReturnShippingDetailInfoRow(label: 'Tracking Number', value: operation.trackingNumber!),
        if (operation.billOfLadingNumber != null)
          ReturnShippingDetailInfoRow(label: 'Bill of Lading', value: operation.billOfLadingNumber!),
        if (operation.purchaseOrderNumber != null)
          ReturnShippingDetailInfoRow(label: 'Purchase Order', value: operation.purchaseOrderNumber!),
        if (operation.despatchAdviceNumber != null)
          ReturnShippingDetailInfoRow(label: 'Despatch Advice', value: operation.despatchAdviceNumber!),
      ],
    );
  }
}
