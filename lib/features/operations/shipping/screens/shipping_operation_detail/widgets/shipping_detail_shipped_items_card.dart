import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/shipping/shipping_response_model.dart';
import 'package:traqtrace_app/features/shared/hierarchy/widgets/epc_contents_card.dart';

class ShippingDetailShippedItemsCard extends StatelessWidget {
  const ShippingDetailShippedItemsCard({
    super.key,
    required this.operation,
  });

  final ShippingResponse operation;

  @override
  Widget build(BuildContext context) {
    return EpcContentsCard(
      title: 'Shipped Items',
      epcs: operation.epcList ?? [],
      emptyMessage: 'No items shipped',
      hierarchyScreenTitle: 'Shipment Hierarchy',
    );
  }
}
