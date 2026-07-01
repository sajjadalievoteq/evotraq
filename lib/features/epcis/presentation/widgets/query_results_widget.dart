import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/epcis/advanced_query_result.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

class QueryResultsWidget extends StatelessWidget {
  final AdvancedQueryResult? result;
  final bool isLoading;
  final String? error;
  final VoidCallback? onExport;
  final VoidCallback? onRefresh;

  const QueryResultsWidget({
    super.key,
    this.result,
    this.isLoading = false,
    this.error,
    this.onExport,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const Divider(),
          _buildContent(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Query Results',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Row(
            children: [
              if (onRefresh != null)
                IconButton(
                  icon: TraqIcon(AppAssets.iconRefresh),
                  onPressed: isLoading ? null : onRefresh,
                  tooltip: 'Refresh Results',
                ),
              if (onExport != null && result != null)
                IconButton(
                  icon: TraqIcon(AppAssets.iconDownload),
                  onPressed: onExport,
                  tooltip: 'Export Results',
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Executing query...'),
            ],
          ),
        ),
      );
    }

    if (error != null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: Theme.of(context).colorScheme.errorContainer,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                TraqIcon(AppAssets.iconAlert,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Query Error',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (result == null) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            children: [
              TraqIcon(AppAssets.iconSearch,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'No query executed yet',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Configure your query parameters and click Execute to see results.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummary(context),
            const SizedBox(height: 16),
            if (result!.aggregations?.isNotEmpty == true) ...[
              _buildAggregations(context),
              const SizedBox(height: 16),
            ],
            _buildEventsList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            context,
            'Total Events',
            result!.totalCount.toString(),
            AppAssets.iconEvent,
          ),
          _buildSummaryItem(
            context,
            'Returned',
            result!.returnedCount.toString(),
            AppAssets.iconList,
          ),
          _buildSummaryItem(
            context,
            'Execution Time',
            '${result!.executionTimeMs}ms',
            AppAssets.iconTimer,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    String value,
    String iconAsset,
  ) {
    return Column(
      children: [
        TraqIcon(
          iconAsset,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAggregations(BuildContext context) {
    return ExpansionTile(
      title: const Text('Query Aggregations'),
      leading: const TraqIcon(AppAssets.iconBarChart),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            spacing: 16.0,
            runSpacing: 8.0,
            children: result!.aggregations!.entries.map((entry) {
              return Chip(
                label: Text('${entry.key}: ${entry.value}'),
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildEventsList(BuildContext context) {
    if (result!.events.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            children: [
              TraqIcon(AppAssets.iconCalendar, color: Colors.grey, size: 48),
              SizedBox(height: 16),
              Text(
                'No events found',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Events (${result!.events.length})',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: result!.events.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final event = result!.events[index];
                return _buildEventCard(context, event, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, EPCISEvent event, int index) {
    final eventTime = event.eventTime ?? 'Unknown';
    final businessStep = event.bizStep ?? '';
    
    return ExpansionTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Text(
          '${index + 1}',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Row(
        children: [
          Chip(
            label: Text(event.eventType ?? 'Unknown'),
            backgroundColor: _getEventTypeColor(context, event.eventType ?? 'Unknown'),
          ),
          const SizedBox(width: 8),
          if (event.disposition != null)
            Chip(
              label: Text(event.disposition!),
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text('Time: $eventTime'),
          if (businessStep.isNotEmpty)
            Text('Business Step: $businessStep'),
        ],
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Event Details',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                if (event.id != null)
                  _buildEventProperty('Event ID', event.id!),
                if (event.recordTime != null)
                  _buildEventProperty('Record Time', event.recordTime!),
                if (event.readPoint != null)
                  _buildEventProperty('Read Point', event.readPoint!),
                if (event.bizLocation != null)
                  _buildEventProperty('Business Location', event.bizLocation!),
                if (event.epcList != null && event.epcList!.isNotEmpty)
                  _buildEventProperty('EPC List', event.epcList!.join(', ')),
                if (event.additionalData != null)
                  ...event.additionalData!.entries.map((entry) =>
                    _buildEventProperty(entry.key, entry.value.toString()),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventProperty(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }

  Color _getEventTypeColor(BuildContext context, String eventType) {
    switch (eventType.toLowerCase()) {
      case 'objectevent':
        return Colors.blue;
      case 'aggregationevent':
        return Colors.green;
      case 'transactionevent':
        return Colors.orange;
      case 'transformationevent':
        return Colors.purple;
      default:
        return Theme.of(context).colorScheme.surfaceContainerHighest;
    }
  }
}