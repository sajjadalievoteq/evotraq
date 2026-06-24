import 'package:flutter/material.dart';

/// List of scanned EPCs with remove and clear-all actions.
class PackingScannedItemsList extends StatelessWidget {
  const PackingScannedItemsList({
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
            Row(
              children: [
                const Icon(Icons.list_alt),
                const SizedBox(width: 8),
                Text(
                  'Scanned Items (${scannedEpcs.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (scannedEpcs.isNotEmpty)
                  TextButton(
                    onPressed: onClearAll,
                    child: const Text('Clear All'),
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
