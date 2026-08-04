import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class CacheManagementAction extends StatelessWidget {
  const CacheManagementAction({
    super.key,
    required this.title,
    required this.description,
    required this.iconAsset,
    required this.onExecute,
    this.isDestructive = false,
  });

  final String title;
  final String description;
  final String iconAsset;
  final VoidCallback onExecute;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: TraqIcon(
        iconAsset,
        color: isDestructive ? AppColorMapper.errorColor(context) : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppColorMapper.errorColor(context) : null,
        ),
      ),
      subtitle: Text(description),
      trailing: ElevatedButton(
        onPressed: onExecute,
        style: isDestructive
            ? ElevatedButton.styleFrom(
                backgroundColor: AppColorMapper.errorColor(context),
              )
            : null,
        child: Text(isDestructive ? 'Clear' : 'Execute'),
      ),
    );
  }
}

class CacheTypedClearAction extends StatelessWidget {
  const CacheTypedClearAction({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconAsset,
    required this.onClear,
  });

  final String title;
  final String subtitle;
  final String iconAsset;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: TraqIcon(iconAsset),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: ElevatedButton(
        onPressed: onClear,
        child: const Text('Clear'),
      ),
    );
  }
}

class CacheManagementTab extends StatelessWidget {
  const CacheManagementTab({
    super.key,
    required this.onWarmUp,
    required this.onSynchronize,
    required this.onIdentifyHotData,
    required this.onClearQueryResults,
    required this.onRefreshMasterData,
    required this.onClearMasterData,
    required this.onClearHotData,
    required this.onClearAll,
    required this.onClearMasterDataType,
    required this.onClearEventDataType,
  });

  final VoidCallback onWarmUp;
  final VoidCallback onSynchronize;
  final VoidCallback onIdentifyHotData;
  final VoidCallback onClearQueryResults;
  final VoidCallback onRefreshMasterData;
  final VoidCallback onClearMasterData;
  final VoidCallback onClearHotData;
  final VoidCallback onClearAll;
  final void Function(String dataType) onClearMasterDataType;
  final void Function(String eventType) onClearEventDataType;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                        onPressed: onWarmUp,
                        icon: const TraqIcon(AppAssets.iconFlame),
                        label: const Text('Warm Up Cache'),
                      ),
                      ElevatedButton.icon(
                        onPressed: onSynchronize,
                        icon: const TraqIcon(AppAssets.iconRefresh),
                        label: const Text('Synchronize'),
                      ),
                      ElevatedButton.icon(
                        onPressed: onIdentifyHotData,
                        icon: const TraqIcon(AppAssets.iconFlame),
                        label: const Text('Identify Hot Data'),
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
                  Text(
                    'Cache Management',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  CacheManagementAction(
                    title: 'Clear Query Results Cache',
                    description: 'Remove all cached query results',
                    iconAsset: AppAssets.iconBarChart,
                    onExecute: onClearQueryResults,
                  ),
                  CacheManagementAction(
                    title: 'Refresh Master Data Cache',
                    description: 'Reload all master data into cache',
                    iconAsset: AppAssets.iconRefresh,
                    onExecute: onRefreshMasterData,
                  ),
                  CacheManagementAction(
                    title: 'Clear Master Data Cache',
                    description:
                        'Remove all cached master data (does not warm up)',
                    iconAsset: AppAssets.iconSparkle,
                    onExecute: onClearMasterData,
                    isDestructive: true,
                  ),
                  CacheManagementAction(
                    title: 'Clear Hot Data Cache',
                    description: 'Remove all cached hot data',
                    iconAsset: AppAssets.iconFlash,
                    onExecute: onClearHotData,
                  ),
                  const Divider(),
                  CacheManagementAction(
                    title: 'Clear All Caches',
                    description: 'Remove all cached data (Use with caution)',
                    iconAsset: AppAssets.iconTrash,
                    onExecute: onClearAll,
                    isDestructive: true,
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
                    'Master Data Cache Management',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  ...'gtin,gln,sscc,sgtin,trading-partner,validation-rule'
                      .split(',')
                      .map(
                        (dataType) => CacheTypedClearAction(
                          title: '${dataType.toUpperCase()} Cache',
                          subtitle: 'Manage $dataType master data cache',
                          iconAsset: AppAssets.iconList,
                          onClear: () => onClearMasterDataType(dataType),
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
                    'Event Data Cache Management',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  ...'object-event,aggregation-event,transaction-event,transformation-event'
                      .split(',')
                      .map(
                        (eventType) => CacheTypedClearAction(
                          title:
                              '${eventType.replaceAll('-', ' ').toUpperCase()} Cache',
                          subtitle: 'Manage $eventType hot data cache',
                          iconAsset: NavIcons.epcisEvents,
                          onClear: () => onClearEventDataType(eventType),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
