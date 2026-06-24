import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/widgets/aggregation_parent_pack_section.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/widgets/object_event_form_section_card.dart';

class AggregationEventFormParentContainerSection extends StatelessWidget {
  const AggregationEventFormParentContainerSection({
    super.key,
    required this.selectedAction,
    required this.initialParentEpc,
    required this.onParentEpcChanged,
  });

  final String selectedAction;
  final String? initialParentEpc;
  final ValueChanged<String> onParentEpcChanged;

  @override
  Widget build(BuildContext context) {
    return ObjectEventFormSectionCard(
      title: 'Parent Container',
      showTitleRequiredIndicator: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AggregationParentPackSection(
            action: selectedAction,
            initialParentEpc: initialParentEpc,
            onParentEpcChanged: onParentEpcChanged,
          ),
          const SizedBox(height: 8),
          Text(
            'Supports URN, SSCC barcode (00)…, SGTIN barcode (01)…(21)…, and GS1 Digital Link. '
            'All inputs are auto-converted to URN on save.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
