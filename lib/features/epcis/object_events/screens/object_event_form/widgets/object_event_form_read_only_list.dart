import 'package:flutter/material.dart';

class ObjectEventFormReadOnlyList extends StatelessWidget {
  const ObjectEventFormReadOnlyList({
    super.key,
    required this.label,
    this.items,
  });
  final String label;
  final List<String>? items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          if (items == null || items!.isEmpty)
            const Text('No items')
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items!
                  .map(
                    (item) =>
                        Text('• $item', style: const TextStyle(fontSize: 16)),
                  )
                  .toList(),
            ),
          const Divider(),
        ],
      ),
    );
  }
}
