import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation_epc_product_subtitle.dart';
import 'package:traqtrace_app/features/shared/hierarchy/widgets/epc_hierarchy_row.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

/// List of scanned EPCs with remove and clear-all actions.
class ReceivingScannedItemsList extends StatelessWidget {
  const ReceivingScannedItemsList({
    super.key,
    required this.scannedEpcs,
    required this.onRemoveItem,
    required this.onClearAll,
  });

  final List<String> scannedEpcs;
  final ValueChanged<int> onRemoveItem;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Row(
                  children: [
                    TraqIcon(AppAssets.iconList),
                    SizedBox(width: 8),
                    Text(
                      'Items to Receive',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${scannedEpcs.length} EPC(s) queued for receiving',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.teal[800],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (scannedEpcs.isNotEmpty)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: onClearAll,
                      child: const Text('Clear All'),
                    ),
                  ),
              ],
            ),
            const Divider(),
            if (scannedEpcs.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    'No items scanned yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: scannedEpcs.length,
                itemBuilder: (context, index) {
                  final epc = scannedEpcs[index];
                  return EpcHierarchyRow(
                    epc: epc,
                    hierarchyScreenTitle: 'Receiving Hierarchy',
                    subtitle: OperationEpcProductSubtitle(epc: epc),
                    trailing: IconButton(
                      icon: TraqIcon(AppAssets.iconTrash, color: Colors.red),
                      visualDensity: VisualDensity.compact,
                      onPressed: () => onRemoveItem(index),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
