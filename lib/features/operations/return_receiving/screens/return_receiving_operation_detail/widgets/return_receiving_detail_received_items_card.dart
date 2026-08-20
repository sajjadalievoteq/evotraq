import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/return_receiving/return_receiving_response_model.dart';
import 'package:traqtrace_app/features/shared/hierarchy/widgets/epc_contents_card.dart';

class ReturnReceivingDetailReceivedItemsCard extends StatelessWidget {
  const ReturnReceivingDetailReceivedItemsCard({
    super.key,
    required this.operation,
  });

  final ReturnReceivingResponse operation;

  @override
  Widget build(BuildContext context) {
    return EpcContentsCard(
      title: 'Returned Items',
      epcs: operation.epcList ?? [],
      emptyMessage: 'No items returned',
      hierarchyScreenTitle: 'Return Receiving Hierarchy',
    );
  }
}
