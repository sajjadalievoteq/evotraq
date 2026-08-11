import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/services/admin/event_generation_test_service.dart';
import 'package:traqtrace_app/features/admin/screens/event_generation_test/widgets/event_bulk_result_card.dart';

class EventGeneratorTab extends StatelessWidget {
  const EventGeneratorTab({
    required this.selectedEventType,
    required this.isBulkGeneration,
    required this.bulkCount,
    required this.isLoading,
    required this.lastBulkResult,
    required this.onEventTypeChanged,
    required this.onBulkGenerationChanged,
    required this.onBulkCountChanged,
    required this.onGenerate,
    super.key,
  });

  final String selectedEventType;
  final bool isBulkGeneration;
  final int bulkCount;
  final bool isLoading;
  final BulkGenerationResult? lastBulkResult;
  final ValueChanged<String> onEventTypeChanged;
  final ValueChanged<bool> onBulkGenerationChanged;
  final ValueChanged<int> onBulkCountChanged;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Test Event Generator',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedEventType,
                    decoration: const InputDecoration(
                      labelText: 'Event Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'OBJECT',
                        child: Text('Object Event'),
                      ),
                      DropdownMenuItem(
                        value: 'AGGREGATION',
                        child: Text('Aggregation Event'),
                      ),
                      DropdownMenuItem(
                        value: 'TRANSACTION',
                        child: Text('Transaction Event'),
                      ),
                      DropdownMenuItem(
                        value: 'TRANSFORMATION',
                        child: Text('Transformation Event'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) onEventTypeChanged(value);
                    },
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Bulk Generation'),
                    subtitle: const Text('Generate multiple events at once'),
                    value: isBulkGeneration,
                    onChanged: onBulkGenerationChanged,
                  ),
                  if (isBulkGeneration) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Event Count',
                        border: OutlineInputBorder(),
                        helperText: 'Number of events to generate',
                      ),
                      initialValue: bulkCount.toString(),
                      keyboardType: TextInputType.number,
                      onChanged: (value) =>
                          onBulkCountChanged(int.tryParse(value) ?? 100),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: isLoading ? null : onGenerate,
                        icon: const TraqIcon(AppAssets.iconArrowR),
                        label: Text(
                          isBulkGeneration
                              ? 'Generate Bulk'
                              : 'Generate Single',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (lastBulkResult != null) ...[
            const SizedBox(height: 16),
            EventBulkResultCard(lastBulkResult!),
          ],
        ],
      ),
    );
  }
}
