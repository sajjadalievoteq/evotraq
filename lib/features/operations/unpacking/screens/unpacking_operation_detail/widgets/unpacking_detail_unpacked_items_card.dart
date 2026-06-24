import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/unpacking/unpacking_response_model.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_detail/widgets/unpacking_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_detail/widgets/unpacking_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_detail/widgets/unpacking_detail_info_row_copy.dart';

/// Unpacked items list card for unpacking operation detail.
class UnpackingDetailUnpackedItemsCard extends StatelessWidget {
  const UnpackingDetailUnpackedItemsCard({
    super.key,
    required this.operation,
    required this.showAllEpcs,
    required this.onShowAll,
    this.pageSize = 20,
  });

  final UnpackingResponse operation;
  final bool showAllEpcs;
  final VoidCallback onShowAll;
  final int pageSize;

  @override
  Widget build(BuildContext context) {
    final items = operation.childEpcList ?? [];
    final displayed = showAllEpcs ? items : items.take(pageSize).toList();

    return UnpackingDetailGroupCard(
      title: 'Unpacked Items (${items.length})',
      children: [
        if (items.isEmpty)
          const UnpackingDetailInfoRow(label: 'Items', value: 'No items unpacked')
        else ...[
          ...displayed.map((epc) => UnpackingDetailInfoRowCopy(label: 'EPC', value: epc)),
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
