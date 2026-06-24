import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/epcis/aggregation_event.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_hierarchy/widgets/aggregation_event_hierarchy_history_tile.dart';

class AggregationEventHierarchyContent extends StatelessWidget {
  const AggregationEventHierarchyContent({
    super.key,
    required this.epc,
    required this.isParent,
    required this.error,
    required this.hierarchyContents,
    required this.historyEvents,
    required this.isVerified,
    required this.onRetry,
    required this.onNavigateToEpc,
    required this.onViewEventDetails,
  });

  final String epc;
  final bool isParent;
  final String? error;
  final List<String> hierarchyContents;
  final List<AggregationEvent> historyEvents;
  final bool isVerified;
  final VoidCallback onRetry;
  final void Function(String epc, {required bool isParent}) onNavigateToEpc;
  final ValueChanged<String> onViewEventDetails;

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48.0,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16.0),
            Text(
              'Error loading hierarchy data',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8.0),
            Text(
              error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isParent ? 'Container EPC:' : 'Item EPC:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    epc,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    isParent
                        ? 'This container currently contains ${hierarchyContents.length} items.'
                        : hierarchyContents.isNotEmpty
                            ? 'This item is currently contained in:'
                            : 'This item is not currently in any container.',
                  ),
                  if (isVerified) ...[
                    const SizedBox(height: 8.0),
                    const Row(
                      children: [
                        Icon(
                          Icons.verified,
                          color: Colors.green,
                          size: 16.0,
                        ),
                        SizedBox(width: 4.0),
                        Text(
                          'Hierarchy Verified',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          Text(
            isParent ? 'Current Contents:' : 'Current Container:',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8.0),
          if (hierarchyContents.isEmpty)
            Card(
              child: ListTile(
                leading: Icon(isParent ? Icons.inventory : Icons.inventory_2),
                title: Text(isParent
                    ? 'This container is currently empty'
                    : 'This item is not currently in any container'),
              ),
            )
          else
            Card(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: hierarchyContents.length,
                itemBuilder: (context, index) {
                  final contentEpc = hierarchyContents[index];
                  return ListTile(
                    leading: Icon(
                      isParent ? Icons.inventory_2 : Icons.inventory,
                    ),
                    title: Text(contentEpc),
                    trailing: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => onNavigateToEpc(
                        contentEpc,
                        isParent: !isParent,
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 24.0),
          Text(
            'Event History:',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8.0),
          if (historyEvents.isEmpty)
            const Card(
              child: ListTile(
                leading: Icon(Icons.history),
                title: Text('No event history found'),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: historyEvents.length,
              itemBuilder: (context, index) {
                return AggregationEventHierarchyHistoryTile(
                  event: historyEvents[index],
                  onViewDetails: onViewEventDetails,
                );
              },
            ),
        ],
      ),
    );
  }
}
