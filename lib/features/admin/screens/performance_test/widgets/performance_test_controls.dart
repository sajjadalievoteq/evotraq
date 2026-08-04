import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';

class PerformanceTestControls extends StatelessWidget {
  const PerformanceTestControls({
    super.key,
    required this.onRunAllBackend,
    required this.onRunFrontend,
    required this.onRunGs1Validation,
    required this.onRunBatchInsertion,
    required this.onRunQueryCaching,
    required this.onRunBarcodeParsing,
    required this.singleTestsEnabled,
  });

  final VoidCallback onRunAllBackend;
  final VoidCallback onRunFrontend;
  final VoidCallback? onRunGs1Validation;
  final VoidCallback? onRunBatchInsertion;
  final VoidCallback? onRunQueryCaching;
  final VoidCallback? onRunBarcodeParsing;
  final bool singleTestsEnabled;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Test Suite',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Run data model and GS1 validation performance tests to ensure the system meets requirements.',
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Backend Tests',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: onRunAllBackend,
                  child: const Text('Run All Backend Tests'),
                ),
                OutlinedButton(
                  onPressed: singleTestsEnabled ? onRunGs1Validation : null,
                  child: const Text('GS1 Validation'),
                ),
                OutlinedButton(
                  onPressed: singleTestsEnabled ? onRunBatchInsertion : null,
                  child: const Text('Batch Insertion'),
                ),
                OutlinedButton(
                  onPressed: singleTestsEnabled ? onRunQueryCaching : null,
                  child: const Text('Query Caching'),
                ),
                OutlinedButton(
                  onPressed: singleTestsEnabled ? onRunBarcodeParsing : null,
                  child: const Text('Barcode Parsing'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Frontend Tests',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: onRunFrontend,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorMapper.warningColor(context),
              ),
              child: const Text('Run Frontend Tests'),
            ),
          ],
        ),
      ),
    );
  }
}
