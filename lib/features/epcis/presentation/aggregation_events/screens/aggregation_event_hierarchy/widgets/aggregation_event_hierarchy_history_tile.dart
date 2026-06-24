import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/data/models/epcis/aggregation_event.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_hierarchy/utils/aggregation_event_hierarchy_utils.dart';

class AggregationEventHierarchyHistoryTile extends StatelessWidget {
  const AggregationEventHierarchyHistoryTile({
    super.key,
    required this.event,
    required this.onViewDetails,
  });

  final AggregationEvent event;
  final ValueChanged<String> onViewDetails;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ExpansionTile(
        leading: AggregationEventHierarchyUtils.actionIcon(event.action),
        title: Text('${event.action} Event'),
        subtitle: Text(
          DateFormat.yMd().add_Hms().format(event.eventTime),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Parent: ${event.parentID}'),
                Text('Business Step: ${event.businessStep}'),
                Text('Disposition: ${event.disposition}'),
                const SizedBox(height: 8.0),
                const Text(
                  'Child EPCs:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...event.childEPCs
                    .take(5)
                    .map((epc) => Text('• $epc')),
                if (event.childEPCs.length > 5)
                  Text(
                    '... and ${event.childEPCs.length - 5} more',
                    style: TextStyle(color: Theme.of(context).disabledColor),
                  ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => onViewDetails(event.eventId),
                      child: const Text('View Full Details'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
