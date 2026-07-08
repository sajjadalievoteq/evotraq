import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/cancel_receiving/cancel_receiving_response_model.dart';
import 'package:traqtrace_app/features/shared/hierarchy/widgets/epc_contents_card.dart';

class CancelReceivingDetailShippedItemsCard extends StatelessWidget {
  const CancelReceivingDetailShippedItemsCard({
    super.key,
    required this.operation,
  });

  final CancelReceivingResponse operation;

  @override
  Widget build(BuildContext context) {
    return EpcContentsCard(
      title: 'Cancelled EPCs (${operation.epcList?.length ?? 0})',
      epcs: operation.epcList ?? [],
      emptyMessage: 'No EPCs cancelled',
      hierarchyScreenTitle: 'Cancel Receiving Hierarchy',
    );
  }
}
