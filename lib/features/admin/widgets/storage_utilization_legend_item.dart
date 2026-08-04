import 'package:flutter/material.dart';

class StorageUtilizationLegendItem extends StatelessWidget {
  const StorageUtilizationLegendItem(
    this.eventType,
    this.percentage,
    this.color, {
    super.key,
  });

  final String eventType;
  final double percentage;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              eventType,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
