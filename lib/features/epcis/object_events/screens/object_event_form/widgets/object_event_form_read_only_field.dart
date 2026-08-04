import 'package:flutter/material.dart';

class ObjectEventFormReadOnlyText extends StatelessWidget {
  final String label;
  final String? value;

  const ObjectEventFormReadOnlyText({
    super.key,
    required this.label,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value ?? 'Not provided', style: const TextStyle(fontSize: 16)),
          const Divider(),
        ],
      ),
    );
  }
}

class ObjectEventFormReadOnlyList extends StatelessWidget {
  final String label;
  final List<String>? items;

  const ObjectEventFormReadOnlyList({
    super.key,
    required this.label,
    this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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

class ObjectEventFormReadOnlyMap extends StatelessWidget {
  final String label;
  final Map<String, dynamic>? map;

  const ObjectEventFormReadOnlyMap({
    super.key,
    required this.label,
    this.map,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
