import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_detail/widgets/commissioning_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_detail/widgets/commissioning_detail_serial_item_row.dart';

class CommissioningDetailSerialNumbersCard extends StatefulWidget {
  const CommissioningDetailSerialNumbersCard({
    super.key,
    required this.items,
    this.initialDisplayCount = 50,
  });

  final List<CommissioningBatchItem> items;
  final int initialDisplayCount;

  @override
  State<CommissioningDetailSerialNumbersCard> createState() =>
      _CommissioningDetailSerialNumbersCardState();
}

class _CommissioningDetailSerialNumbersCardState
    extends State<CommissioningDetailSerialNumbersCard> {
  bool _showAllItems = false;

  @override
  Widget build(BuildContext context) {
    final successItems = widget.items.where((i) => i.success).toList();
    final failedItems = widget.items.where((i) => !i.success).toList();
    final displayItems = _showAllItems
        ? widget.items
        : widget.items.take(widget.initialDisplayCount).toList();

    return CommissioningDetailGroupCard(
      title: 'Serial Numbers (${widget.items.length})',
      children: [
        if (failedItems.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(Icons.check_circle, size: 14, color: Colors.green[700]),
                const SizedBox(width: 4),
                Text(
                  '${successItems.length} succeeded',
                  style: TextStyle(fontSize: 12, color: Colors.green[700]),
                ),
                const SizedBox(width: 12),
                Icon(Icons.cancel, size: 14, color: Colors.red[700]),
                const SizedBox(width: 4),
                Text(
                  '${failedItems.length} failed',
                  style: TextStyle(fontSize: 12, color: Colors.red[700]),
                ),
              ],
            ),
          ),
        ...displayItems.map(
          (item) => CommissioningDetailSerialItemRow(item: item),
        ),
        if (!_showAllItems &&
            widget.items.length > widget.initialDisplayCount)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton.icon(
              onPressed: () => setState(() => _showAllItems = true),
              icon: const Icon(Icons.expand_more, size: 18),
              label: Text(
                'Show all ${widget.items.length} items',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
      ],
    );
  }
}
