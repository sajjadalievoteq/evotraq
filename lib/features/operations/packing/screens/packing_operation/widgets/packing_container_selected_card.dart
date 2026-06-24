import 'package:flutter/material.dart';

/// Displays the currently selected parent container SSCC.
class PackingContainerSelectedCard extends StatelessWidget {
  const PackingContainerSelectedCard({
    super.key,
    required this.containerId,
    required this.onClear,
  });

  final String containerId;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green[50],
      child: ListTile(
        leading: const Icon(Icons.inventory_2, color: Colors.green),
        title: const Text('Container Selected'),
        subtitle: Text(
          containerId,
          style: const TextStyle(fontFamily: 'monospace'),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: onClear,
        ),
      ),
    );
  }
}
