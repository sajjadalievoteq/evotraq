import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class CacheHelpSection extends StatelessWidget {
  const CacheHelpSection(
    this.title,
    this.iconAsset,
    this.color,
    this.items, {
    super.key,
  });

  final String title;
  final String iconAsset;
  final Color color;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TraqIcon(iconAsset, color: color, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...items.map((item) {
              if (item.isEmpty) {
                return const SizedBox(height: 8);
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  item,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                      ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
