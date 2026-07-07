import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

/// Shared selected-container display card.
class OperationContainerSelectedCard extends StatelessWidget {
  const OperationContainerSelectedCard({
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
        leading: TraqIcon(AppAssets.iconPackage, color: Colors.green),
        title: const Text('Container Selected'),
        subtitle: Text(
          containerId,
          style: const TextStyle(fontFamily: 'monospace'),
        ),
        trailing: IconButton(
          icon: TraqIcon(AppAssets.iconX),
          onPressed: onClear,
        ),
      ),
    );
  }
}
