import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/update_status/update_status_response_model.dart';
import 'package:traqtrace_app/features/shared/hierarchy/widgets/epc_contents_card.dart';

class UpdateStatusDetailUpdatedItemsCard extends StatelessWidget {
  const UpdateStatusDetailUpdatedItemsCard({
    super.key,
    required this.operation,
  });

  final UpdateStatusResponse operation;

  @override
  Widget build(BuildContext context) {
    return EpcContentsCard(
      title: 'Updated Items',
      epcs: operation.epcList ?? [],
      emptyMessage: 'No items updated',
      hierarchyScreenTitle: 'Item Hierarchy',
    );
  }
}
