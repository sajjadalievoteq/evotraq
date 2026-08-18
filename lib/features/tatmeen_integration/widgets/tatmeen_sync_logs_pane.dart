import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/features/tatmeen_integration/data/tatmeen_dummy_sync_data.dart';
import 'package:traqtrace_app/features/tatmeen_integration/widgets/tatmeen_sync_events_list.dart';

class TatmeenSyncLogsPane extends StatelessWidget {
  const TatmeenSyncLogsPane({super.key});

  @override
  Widget build(BuildContext context) {
    return TatmeenSyncEventsList(
      events: TatmeenDummySyncData.syncLogs(),
      emptyIconAsset: AppAssets.iconHistory,
      emptyTitle: 'No sync logs yet',
      emptySubtitle: 'Tatmeen sync history will appear here.',
    );
  }
}
