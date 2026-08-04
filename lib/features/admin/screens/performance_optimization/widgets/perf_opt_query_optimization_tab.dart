import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/admin/widgets/load_state.dart';
import 'package:traqtrace_app/features/admin/widgets/load_state_view.dart';

class PerfOptQueryOptimizationTab extends StatefulWidget {
  const PerfOptQueryOptimizationTab({
    super.key,
    required this.reportState,
    required this.onRetry,
    required this.onAnalyzeQuery,
    required this.onDetectSlowQueries,
    required this.onAnalyzeTableIndexes,
  });

  final LoadState<Map<String, dynamic>> reportState;
  final VoidCallback onRetry;
  final ValueChanged<String> onAnalyzeQuery;
  final VoidCallback onDetectSlowQueries;
  final ValueChanged<String> onAnalyzeTableIndexes;

  @override
  State<PerfOptQueryOptimizationTab> createState() =>
      _PerfOptQueryOptimizationTabState();
}

class _PerfOptQueryOptimizationTabState
    extends State<PerfOptQueryOptimizationTab> {
  final TextEditingController _queryController = TextEditingController();

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoadStateView<Map<String, dynamic>>(
      state: widget.reportState,
      onRetry: widget.onRetry,
      builder: (context, report) => SingleChildScrollView(
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
                    const Text(
                      'Query Analysis',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _queryController,
                      decoration: const InputDecoration(
                        labelText: 'SQL Query',
                        hintText: 'Enter SQL query to analyze...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                      onSubmitted: widget.onAnalyzeQuery,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () =>
                              widget.onAnalyzeQuery(_queryController.text),
                          child: const Text('Analyze Query'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: widget.onDetectSlowQueries,
                          child: const Text('Detect Slow Queries'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Index Optimization',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    const Text('Select table for index analysis:'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration:
                          const InputDecoration(border: OutlineInputBorder()),
                      items: [
                        'object_events',
                        'aggregation_events',
                        'transaction_events',
                        'transformation_events',
                      ]
                          .map(
                            (table) => DropdownMenuItem(
                              value: table,
                              child: Text(table),
                            ),
                          )
                          .toList(),
                      onChanged: (table) {
                        if (table != null) {
                          widget.onAnalyzeTableIndexes(table);
                        }
                      },
                      hint: const Text('Select table'),
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
