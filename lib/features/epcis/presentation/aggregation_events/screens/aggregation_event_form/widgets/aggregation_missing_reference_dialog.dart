import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/utils/aggregation_form_external_navigation.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/utils/aggregation_missing_reference.dart';

class AggregationMissingReferenceDialog extends StatelessWidget {
  const AggregationMissingReferenceDialog({
    super.key,
    required this.missing,
  });

  final List<AggregationMissingReference> missing;

  static Future<void> show(
    BuildContext context,
    List<AggregationMissingReference> missing,
  ) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AggregationMissingReferenceDialog(missing: missing),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final createActions = <AggregationReferenceKind, AggregationMissingReference>{};
    for (final item in missing) {
      createActions.putIfAbsent(item.kind, () => item);
    }

    return AlertDialog(
      icon: Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
      title: const Text('Master data not found'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'The following identifiers are not registered in the system. '
              'Add them before creating this aggregation event.',
            ),
            const SizedBox(height: 16),
            ...missing.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _iconFor(item.kind),
                      size: 18,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.kindLabel,
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            item.displayValue,
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                          if (item.contextLabel != null)
                            Text(
                              item.contextLabel!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ...createActions.values.map(
          (item) => FilledButton.tonalIcon(
            onPressed: () async {
              Navigator.of(context).pop();
              await openAggregationFormRouteInNewTab(item.createRoute);
            },
            icon: Icon(_iconFor(item.kind), size: 18),
            label: Text(item.createActionLabel),
          ),
        ),
      ],
    );
  }

  IconData _iconFor(AggregationReferenceKind kind) => switch (kind) {
        AggregationReferenceKind.gln => Icons.location_on_outlined,
        AggregationReferenceKind.gtin => Icons.qr_code_2_outlined,
        AggregationReferenceKind.sgtin => Icons.inventory_outlined,
        AggregationReferenceKind.sscc => Icons.inventory_2_outlined,
      };
}
