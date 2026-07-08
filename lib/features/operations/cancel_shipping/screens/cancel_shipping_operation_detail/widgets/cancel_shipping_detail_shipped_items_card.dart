import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/cancel_shipping/cancel_shipping_response_model.dart';
import 'package:traqtrace_app/features/shared/hierarchy/widgets/epc_contents_card.dart';

class CancelShippingDetailShippedItemsCard extends StatelessWidget {
  const CancelShippingDetailShippedItemsCard({
    super.key,
    required this.operation,
  });

  final CancelShippingResponse operation;

  @override
  Widget build(BuildContext context) {
    return EpcContentsCard(
      title: 'Cancelled EPCs (${operation.epcList?.length ?? 0})',
      epcs: operation.epcList ?? [],
      emptyMessage: 'No EPCs cancelled',
      hierarchyScreenTitle: 'Cancel Shipment Hierarchy',
    );
  }
}
