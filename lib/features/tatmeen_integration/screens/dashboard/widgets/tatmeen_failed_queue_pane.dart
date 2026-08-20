import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_presenter.dart';
import 'package:traqtrace_app/features/tatmeen_integration/data/tatmeen_dummy_sync_data.dart';
import 'package:traqtrace_app/features/tatmeen_integration/screens/dashboard/widgets/tatmeen_sync_events_list.dart';

class TatmeenFailedQueuePane extends StatelessWidget {
  const TatmeenFailedQueuePane({super.key});

  @override
  Widget build(BuildContext context) {
    final items = TatmeenDummySyncData.failedQueue();
    return TatmeenSyncEventsList(
      events: items.map((item) => item.event).toList(),
      emptyIconAsset: AppAssets.iconXCircle,
      emptyTitle: 'No failed items',
      emptySubtitle: 'Failed Tatmeen sync items will appear here.',
      attempts: {for (final item in items) item.event.recordId: item.attempts},
      onRetry: (event) {
        context.showSuccess('Retry queued for ${event.recordId}');
      },
    );
  }
}
