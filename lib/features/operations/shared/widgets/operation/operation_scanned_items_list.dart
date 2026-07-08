import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation_epc_product_subtitle.dart';
import 'package:traqtrace_app/features/shared/hierarchy/widgets/epc_hierarchy_row.dart';

class OperationScannedItemsList extends StatelessWidget {
  const OperationScannedItemsList({
    super.key,
    required this.scannedEpcs,
    required this.onRemoveItem,
    required this.onClearAll,
    required this.listTitle,
    required this.queuedLabel,
    required this.hierarchyScreenTitle,
    this.itemWarnings = const {},
  });

  final List<String> scannedEpcs;
  final ValueChanged<int> onRemoveItem;
  final VoidCallback onClearAll;
  final String listTitle;
  final String queuedLabel;
  final String hierarchyScreenTitle;
  final Map<String, String> itemWarnings;

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
                Row(
                  children: [
                    const TraqIcon(AppAssets.iconList),
                    const SizedBox(width: 8),
                    Text(
                      listTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${scannedEpcs.length} EPC(s) $queuedLabel',
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
                  final warning = itemWarnings[epc];
                  return EpcHierarchyRow(
                    epc: epc,
                    hierarchyScreenTitle: hierarchyScreenTitle,
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        OperationEpcProductSubtitle(epc: epc),
                        if (warning != null)
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.amber, width: 1),
                            ),
                            child: Text(
                              'Status: $warning — may be rejected',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.amber,
                              ),
                            ),
                          ),
                      ],
                    ),
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
