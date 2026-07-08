import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/unpacking/unpacking_response_model.dart';
import 'package:traqtrace_app/features/shared/hierarchy/utils/hierarchy_epc_utils.dart';
import 'package:traqtrace_app/features/shared/hierarchy/widgets/epc_contents_card.dart';

class UnpackingDetailUnpackedItemsCard extends StatelessWidget {
  const UnpackingDetailUnpackedItemsCard({
    super.key,
    required this.operation,
  });

  final UnpackingResponse operation;

  @override
  Widget build(BuildContext context) {
    return EpcContentsCard(
      title: 'Unpacked Items',
      epcs: mergeModelEpcFields(
        leading: operation.parentContainerId,
        trailing: operation.childEpcList,
      ),
      emptyMessage: 'No items unpacked',
      hierarchyScreenTitle: 'Unpacking Hierarchy',
    );
  }
}
