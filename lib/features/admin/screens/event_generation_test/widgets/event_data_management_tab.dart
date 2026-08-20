import 'package:traqtrace_app/data/services/admin/event_generation_test_data_models.dart';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/admin/screens/event_generation_test/widgets/event_data_action_button.dart';
import 'package:traqtrace_app/features/admin/screens/event_generation_test/widgets/event_gen_stat_card.dart';

class EventDataManagementTab extends StatelessWidget {
  const EventDataManagementTab({
    required this.statistics,
    required this.activeEnvironment,
    required this.isLoading,
    required this.onRefresh,
    required this.onCleanTestData,
    required this.onCleanObjectEvents,
    required this.onCleanGlnData,
    required this.onCleanGtinData,
    required this.onCleanSgtinData,
    required this.onCleanSsccTestData,
    required this.onCleanAllSsccData,
    required this.onCleanAggregationEvents,
    required this.onCleanTransactionEvents,
    required this.onCleanTransformationEvents,
    super.key,
  });

  final TestDataStatistics? statistics;
  final TestEnvironment? activeEnvironment;
  final bool isLoading;
  final VoidCallback onRefresh;
  final VoidCallback onCleanTestData;
  final VoidCallback onCleanObjectEvents;
  final VoidCallback onCleanGlnData;
  final VoidCallback onCleanGtinData;
  final VoidCallback onCleanSgtinData;
  final VoidCallback onCleanSsccTestData;
  final VoidCallback onCleanAllSsccData;
  final VoidCallback onCleanAggregationEvents;
  final VoidCallback onCleanTransactionEvents;
  final VoidCallback onCleanTransformationEvents;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Test Data Statistics',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      ElevatedButton.icon(
                        onPressed: isLoading ? null : onRefresh,
                        icon: const TraqIcon(AppAssets.iconRefresh),
                        label: const Text('Refresh'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (statistics != null) ...[
                    Row(
                      children: [
                        Expanded(
                          child: EventGenStatCard(
                            'Total Events',
                            statistics!.totalEvents.toString(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: EventGenStatCard(
                            'Total Master Data',
                            (statistics!.totalGLNs +
                                    statistics!.totalGTINs +
                                    statistics!.totalSGTINs +
                                    statistics!.totalSSCCs)
                                .toString(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: EventGenStatCard(
                            'Data Size',
                            '${(statistics!.dataSizeBytes / 1024 / 1024).toStringAsFixed(2)} MB',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Event Type Distribution:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ...statistics!.eventTypeCounts.entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry.key),
                            Text(entry.value.toString()),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Master Data Distribution:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ...statistics!.masterDataDistribution.entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry.key),
                            Text(entry.value.toString()),
                          ],
                        ),
                      ),
                    ),
                  ] else
                    const Center(
                      child: Text(
                        'No statistics available. Click Refresh to load.',
                      ),
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
                  Text(
                    'Data Management Actions',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      EventDataActionButton(
                        icon: AppAssets.iconSparkle,
                        label: 'Clean Test Data',
                        onPressed: isLoading ? null : onCleanTestData,
                      ),
                      EventDataActionButton(
                        icon: NavIcons.packaging,
                        label: 'Clean Object Events',
                        onPressed: isLoading ? null : onCleanObjectEvents,
                      ),
                      EventDataActionButton(
                        icon: NavIcons.gln,
                        label: 'Clean GLN Test Data',
                        onPressed: isLoading ? null : onCleanGlnData,
                      ),
                      EventDataActionButton(
                        icon: AppAssets.iconQr,
                        label: 'Clean GTIN Test Data',
                        onPressed: isLoading ? null : onCleanGtinData,
                      ),
                      EventDataActionButton(
                        icon: AppAssets.iconQr,
                        label: 'Clean SGTIN Test Data',
                        onPressed: isLoading ? null : onCleanSgtinData,
                      ),
                      EventDataActionButton(
                        icon: NavIcons.sscc,
                        label: 'Clean SSCC Test Data',
                        onPressed: isLoading ? null : onCleanSsccTestData,
                      ),
                      EventDataActionButton(
                        icon: AppAssets.iconAlert,
                        label: 'DANGER - Delete ALL SSCCs',
                        onPressed: isLoading ? null : onCleanAllSsccData,
                        color: AppColorMapper.errorColor(context),
                      ),
                      EventDataActionButton(
                        icon: NavIcons.aggregationEvents,
                        label: 'Clean Aggregation Events',
                        onPressed: isLoading ? null : onCleanAggregationEvents,
                      ),
                      EventDataActionButton(
                        icon: AppAssets.iconTransform,
                        label: 'Clean Transaction Events',
                        onPressed: isLoading ? null : onCleanTransactionEvents,
                      ),
                      EventDataActionButton(
                        icon: AppAssets.iconTransform,
                        label: 'Clean Transformation Events',
                        onPressed: isLoading
                            ? null
                            : onCleanTransformationEvents,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (activeEnvironment != null) ...[
            const SizedBox(height: 16),
            Card(
              color: context.colors.primary.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Active Environment',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('Name: ${activeEnvironment!.name}'),
                    Text('Description: ${activeEnvironment!.description}'),
                    Text('Created: ${activeEnvironment!.createdAt}'),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
