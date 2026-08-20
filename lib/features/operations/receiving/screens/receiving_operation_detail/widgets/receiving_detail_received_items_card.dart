import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/receiving/receiving_response_model.dart';
import 'package:traqtrace_app/features/shared/hierarchy/widgets/epc_contents_card.dart';

class ReceivingDetailReceivedItemsCard extends StatelessWidget {
  const ReceivingDetailReceivedItemsCard({
    super.key,
    required this.operation,
  });

  final ReceivingResponse operation;

  @override
  Widget build(BuildContext context) {
    return EpcContentsCard(
      title: 'Received Items',
      epcs: operation.epcList ?? [],
      emptyMessage: 'No items received',
      hierarchyScreenTitle: 'Receiving Hierarchy',
    );
  }
}
