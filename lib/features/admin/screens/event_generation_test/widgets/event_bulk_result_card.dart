import 'package:traqtrace_app/data/services/admin/event_generation_test_models.dart';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/admin/screens/event_generation_test/widgets/event_gen_stat_card.dart';

class EventBulkResultCard extends StatelessWidget {
  const EventBulkResultCard(this.result, {super.key});

  final BulkGenerationResult result;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bulk Generation Result',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: EventGenStatCard(
                    'Generated Count',
                    result.generatedCount.toString(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(child: EventGenStatCard('Status', result.status)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: EventGenStatCard(
                    'Start Time',
                    result.startTime.toString(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: EventGenStatCard(
                    'End Time',
                    result.endTime?.toString() ?? 'N/A',
                  ),
                ),
              ],
            ),
            if (result.eventIds.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Sample Event IDs:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...result.eventIds.take(5).map(
                    (id) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        id,
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }
}
