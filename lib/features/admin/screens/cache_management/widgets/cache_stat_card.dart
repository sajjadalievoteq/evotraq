import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class CacheStatCard extends StatelessWidget {
  const CacheStatCard(
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
    return Column(
      children: [
        TraqIcon(iconAsset, size: 32, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
