import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/packing/packing_response_model.dart';
import 'package:traqtrace_app/features/shared/hierarchy/utils/hierarchy_epc_utils.dart';
import 'package:traqtrace_app/features/shared/hierarchy/widgets/epc_contents_card.dart';

class PackingDetailPackedItemsCard extends StatelessWidget {
  const PackingDetailPackedItemsCard({
    super.key,
    required this.operation,
  });

  final PackingResponse operation;

  @override
  Widget build(BuildContext context) {
    return EpcContentsCard(
      title: 'Packed Items',
      epcs: mergeModelEpcFields(
        leading: operation.parentContainerId,
        trailing: operation.childEpcList,
      ),
      emptyMessage: 'No items packed',
      hierarchyScreenTitle: 'Packing Hierarchy',
    );
  }
}
