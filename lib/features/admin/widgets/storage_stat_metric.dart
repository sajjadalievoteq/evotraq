import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class StorageStatMetric extends StatelessWidget {
  const StorageStatMetric(
    this.title,
    this.value,
    this.iconAsset,
    this.color, {
    super.key,
  });

  final String title;
  final String value;
  final String iconAsset;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          TraqIcon(iconAsset, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}