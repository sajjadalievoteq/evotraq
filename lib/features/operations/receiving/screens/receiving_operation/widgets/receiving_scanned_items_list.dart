import 'package:flutter/material.dart';

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
                Row(
                  children: [
                    const Icon(Icons.list_alt),
                    const SizedBox(width: 8),
                    const Text(
                      'Items to Ship',
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
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.teal[100],
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: Colors.teal[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    title: Text(
                      epc,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => onRemoveItem(index),
                    ),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
