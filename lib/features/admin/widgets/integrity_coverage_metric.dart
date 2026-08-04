import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class IntegrityCoverageMetric extends StatelessWidget {
  const IntegrityCoverageMetric(
    this.title,
    this.percentage,
    this.count,
    this.iconAsset,
    this.color, {
    super.key,
  });

  final String title;
  final double percentage;
  final int count;
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
          const SizedBox(height: 8),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          Text(
            '($count events)',
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ],
      ),
    );
  }
}