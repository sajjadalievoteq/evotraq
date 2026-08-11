import 'package:flutter/material.dart';

class ObjectEventFormReadOnlyMap extends StatelessWidget {
  const ObjectEventFormReadOnlyMap({super.key, required this.label, this.map});
  final String label;
  final Map<String, dynamic>? map;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          if (map == null || map!.isEmpty)
            const Text('No items')
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: map!.entries
                  .map(
                    (entry) => Text(
                      '• ${entry.key}: ${entry.value}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  )
                  .toList(),
            ),
          const Divider(),
        ],
      ),
    );
  }
}
