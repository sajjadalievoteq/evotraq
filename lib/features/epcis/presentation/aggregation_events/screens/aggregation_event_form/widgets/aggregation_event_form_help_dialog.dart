import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/utils/aggregation_event_form_help_content.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/widgets/aggregation_event_form_help_section.dart';

class AggregationEventFormHelpDialog extends StatelessWidget {
  const AggregationEventFormHelpDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => const AggregationEventFormHelpDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Aggregation Event Help'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  for (final field in AggregationEventFormHelpContent.sectionOrder) ...[
                    if (field != AggregationEventFormHelpContent.sectionOrder.first)
                      const Divider(),
                    Builder(
                      builder: (context) {
                        final helpItem =
                            AggregationEventFormHelpContent.sections[field];
                        if (helpItem == null) return const SizedBox.shrink();
                        return AggregationEventFormHelpSection(
                          title: helpItem['title'] ?? '',
                          content: helpItem['content'] ?? '',
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(4.0),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'GS1 Standards Compliance',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          'This system implements GS1 EPCIS 2.0 standards with backward compatibility to EPCIS 1.3. '
                          'All identifiers, business vocabulary, and event structures comply with GS1 Core Business '
                          'Vocabulary (CBV) and are designed for pharmaceutical track and trace requirements.',
                          style: TextStyle(fontSize: 12.0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
