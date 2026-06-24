import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/receiving/receiving_response_model.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_detail/widgets/receiving_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_detail/widgets/receiving_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_detail/widgets/receiving_detail_info_row_copy.dart';

/// Received items list card for Receiving operation detail.
class ReceivingDetailReceivedItemsCard extends StatelessWidget {
  const ReceivingDetailReceivedItemsCard({
    super.key,
    required this.operation,
    required this.showAllEpcs,
    required this.onShowAll,
    this.pageSize = 20,
  });

  final ReceivingResponse operation;
  final bool showAllEpcs;
  final VoidCallback onShowAll;
  final int pageSize;

  @override
  Widget build(BuildContext context) {
    final items = operation.epcList ?? [];
    final displayed = showAllEpcs ? items : items.take(pageSize).toList();

    return ReceivingDetailGroupCard(
      title: 'Received Items (${items.length})',
      children: [
        if (items.isEmpty)
          const ReceivingDetailInfoRow(label: 'Items', value: 'No items Received')
        else ...[
          ...displayed.map((epc) => ReceivingDetailInfoRowCopy(label: 'EPC', value: epc)),
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
