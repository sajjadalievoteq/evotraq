import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/packing/packing_response_model.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_detail/widgets/packing_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_detail/widgets/packing_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_detail/widgets/packing_detail_info_row_copy.dart';

/// Packed items list card for packing operation detail.
class PackingDetailPackedItemsCard extends StatelessWidget {
  const PackingDetailPackedItemsCard({
    super.key,
    required this.operation,
    required this.showAllEpcs,
    required this.onShowAll,
    this.pageSize = 20,
  });

  final PackingResponse operation;
  final bool showAllEpcs;
  final VoidCallback onShowAll;
  final int pageSize;

  @override
  Widget build(BuildContext context) {
    final items = operation.childEpcList ?? [];
    final displayed = showAllEpcs ? items : items.take(pageSize).toList();

    return PackingDetailGroupCard(
      title: 'Packed Items (${items.length})',
      children: [
        if (items.isEmpty)
          const PackingDetailInfoRow(label: 'Items', value: 'No items packed')
        else ...[
          ...displayed.map((epc) => PackingDetailInfoRowCopy(label: 'EPC', value: epc)),
          if (items.length > pageSize && !showAllEpcs)
            TextButton(
              onPressed: onShowAll,
              child: Text('Show all ${items.length} items'),
            ),
        ],
      ],
    );
  }
}
