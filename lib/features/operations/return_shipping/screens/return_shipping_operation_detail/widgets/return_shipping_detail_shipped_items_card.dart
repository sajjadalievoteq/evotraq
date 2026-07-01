import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/return_shipping/return_shipping_response_model.dart';
import 'package:traqtrace_app/features/shared/hierarchy/widgets/epc_contents_card.dart';

/// Returned items card for return shipping operation detail.
class ReturnShippingDetailShippedItemsCard extends StatelessWidget {
  const ReturnShippingDetailShippedItemsCard({
    super.key,
    required this.operation,
  });

  final ReturnShippingResponse operation;

  @override
  Widget build(BuildContext context) {
    return EpcContentsCard(
      title: 'Returned Items',
      epcs: operation.epcList ?? [],
      emptyMessage: 'No items returned',
      hierarchyScreenTitle: 'Return Shipment Hierarchy',
    );
  }
}
