import 'package:flutter/material.dart';

String formatCacheStatKey(String key) {
  return key
      .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
      .replaceAll('_', ' ')
      .split(' ')
      .map(
        (word) =>
            word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '',
      )
      .join(' ');
}

String formatCacheStatValue(dynamic value) {
  if (value is double) {
    if (value >= 0 && value <= 1) {
      return '${(value * 100).toStringAsFixed(1)}%';
    }
    return value.toStringAsFixed(2);
  }
  return value.toString();
}

class CacheDetailedStatsCard extends StatelessWidget {
  const CacheDetailedStatsCard(this.title, this.stats, {super.key});

  final String title;
  final Map<String, dynamic> stats;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            ...stats.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatCacheStatKey(entry.key),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      formatCacheStatValue(entry.value),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
