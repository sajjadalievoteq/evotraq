import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class PartitionMaintenanceButton extends StatelessWidget {
  const PartitionMaintenanceButton(
    this.title,
    this.subtitle,
    this.iconAsset,
    this.onPressed, {
    super.key,
  });

  final String title;
  final String subtitle;
  final String iconAsset;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: TraqIcon(iconAsset, color: Theme.of(context).primaryColor),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: ElevatedButton(
          onPressed: onPressed,
          child: const Text('Run'),
        ),
      ),
    );
  }
}
