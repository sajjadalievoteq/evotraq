import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/shipping/shipping_response_model.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation_detail/widgets/shipping_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation_detail/widgets/shipping_detail_info_row.dart';

/// Transport and reference group card for shipping operation detail.
class ShippingDetailProductionCard extends StatelessWidget {
  const ShippingDetailProductionCard({
    super.key,
    required this.operation,
  });

  final ShippingResponse operation;

  @override
  Widget build(BuildContext context) {
    return ShippingDetailGroupCard(
      title: 'Shipment Group Details',
      children: [
        if (operation.carrier != null)
          ShippingDetailInfoRow(label: 'Carrier', value: operation.carrier!),
        if (operation.trackingNumber != null)
          ShippingDetailInfoRow(label: 'Tracking Number', value: operation.trackingNumber!),
        if (operation.billOfLadingNumber != null)
          ShippingDetailInfoRow(label: 'Bill of Lading', value: operation.billOfLadingNumber!),
        if (operation.purchaseOrderNumber != null)
          ShippingDetailInfoRow(label: 'Purchase Order', value: operation.purchaseOrderNumber!),
        if (operation.despatchAdviceNumber != null)
          ShippingDetailInfoRow(label: 'Despatch Advice', value: operation.despatchAdviceNumber!),
      ],
    );
  }
}
