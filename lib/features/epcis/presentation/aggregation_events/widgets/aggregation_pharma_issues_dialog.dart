import 'package:flutter/material.dart';

/// Shows pharma packing rule violations in plain language before submit.
class AggregationPharmaIssuesDialog extends StatelessWidget {
  const AggregationPharmaIssuesDialog({
    super.key,
    required this.issues,
  });

  final List<String> issues;

  static Future<void> show(BuildContext context, List<String> issues) {
    return showDialog<void>(
      context: context,
      builder: (_) => AggregationPharmaIssuesDialog(issues: issues),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      icon: Icon(Icons.block, color: theme.colorScheme.error),
      title: const Text('Cannot pack — pharma rules'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Fix the following before creating this aggregation event:',
            ),
            const SizedBox(height: 12),
            ...issues.map(
              (issue) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 18,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(issue)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
