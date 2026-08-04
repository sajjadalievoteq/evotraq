import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

class AggregationPharmaIssuesDialog extends StatelessWidget {
  const AggregationPharmaIssuesDialog({
    super.key,
    required this.issues,
    this.allowProceed = false,
  });

  final List<String> issues;
  final bool allowProceed;

  static Future<bool?> show(
    BuildContext context,
    List<String> issues, {
    bool allowProceed = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AggregationPharmaIssuesDialog(
        issues: issues,
        allowProceed: allowProceed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      icon: TraqIcon(AppAssets.iconBlock, color: theme.colorScheme.error),
      title: Text(
        allowProceed
            ? 'GS1 Compliance Issues'
            : 'Packing Blocked — GS1 Compliance Issues',
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              allowProceed
                  ? 'The following GS1 compliance issues were detected. You may '
                      'resolve them or proceed at your own risk:'
                  : 'The following issues must be resolved before this '
                      'operation can be submitted:',
            ),
            const SizedBox(height: 12),
            ...issues.map(
              (issue) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TraqIcon(AppAssets.iconAlert,
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
      actions: allowProceed
          ? [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Proceed Anyway'),
              ),
            ]
          : [
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
    );
  }
}