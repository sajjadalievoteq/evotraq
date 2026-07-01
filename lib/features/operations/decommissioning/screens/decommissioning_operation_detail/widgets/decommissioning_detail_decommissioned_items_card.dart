import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/decommissioning/decommissioning_response_model.dart';
import 'package:traqtrace_app/features/shared/hierarchy/widgets/epc_contents_card.dart';

/// Decommissioned items card for decommissioning operation detail.
class DecommissioningDetailDecommissionedItemsCard extends StatelessWidget {
  const DecommissioningDetailDecommissionedItemsCard({
    super.key,
    required this.operation,
  });

  final DecommissioningResponse operation;

  @override
  Widget build(BuildContext context) {
    return EpcContentsCard(
      title: 'Decommissioned Items',
      epcs: operation.epcList ?? [],
      emptyMessage: 'No items decommissioned',
      hierarchyScreenTitle: 'Item Hierarchy',
    );
  }
}
