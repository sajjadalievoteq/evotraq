import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/shipping/shipping_response_model.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation_detail/widgets/shipping_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation_detail/widgets/shipping_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation_detail/widgets/shipping_detail_info_row_copy.dart';

/// Shipped items list card for shipping operation detail.
class ShippingDetailShippedItemsCard extends StatelessWidget {
  const ShippingDetailShippedItemsCard({
    super.key,
    required this.operation,
    required this.showAllEpcs,
    required this.onShowAll,
    this.pageSize = 20,
  });

  final ShippingResponse operation;
  final bool showAllEpcs;
  final VoidCallback onShowAll;
  final int pageSize;

  @override
  Widget build(BuildContext context) {
    final items = operation.epcList ?? [];
    final displayed = showAllEpcs ? items : items.take(pageSize).toList();

    return ShippingDetailGroupCard(
      title: 'Shipped Items (${items.length})',
      children: [
        if (items.isEmpty)
          const ShippingDetailInfoRow(label: 'Items', value: 'No items shipped')
        else ...[
          ...displayed.map((epc) => ShippingDetailInfoRowCopy(label: 'EPC', value: epc)),
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
