import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/display_date_utils.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';
import 'package:traqtrace_app/core/widgets/empty_state/app_empty_state.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_dashboard_models.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_records_models.dart';
import 'package:traqtrace_app/features/tatmeen_integration/widgets/records/tatmeen_operation_details_dialog.dart';
import 'package:traqtrace_app/features/tatmeen_integration/widgets/tatmeen_confirm_dialogs.dart';
import 'package:traqtrace_app/features/tatmeen_integration/widgets/tatmeen_sync_status_badge.dart';

import '../../../../core/utils/responsive_utils.dart';

class TatmeenRecordsTable extends StatelessWidget {
  const TatmeenRecordsTable({
    super.key,
    required this.records,
    required this.isLoading,
    required this.isBusy,
    required this.onRetry,
  });

  final List<TatmeenSyncRecord> records;
  final bool isLoading;
  final bool Function(String id) isBusy;
  final Future<void> Function(TatmeenSyncRecord record) onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const _RowsSkeleton();
    if (records.isEmpty) {
      return const AppEmptyState(
        iconAsset: AppAssets.iconHistory,
        title: 'No sync records found',
        subtitle: 'Try adjusting filters or search.',
      );
    }

    return ListView.separated(
      itemCount: records.length,
      padding: EdgeInsets.symmetric(horizontal:  context.gutter),
      separatorBuilder: (context, index) =>
          Divider(height: 1, color: context.colors.border),
      itemBuilder: (context, index) {
        final record = records[index];
        return Column(
          children: [

            Padding(
              padding:  EdgeInsets.fromLTRB(0, index==0?TraqSpacing.lg:TraqSpacing.lg,0,index==records.length-1?context.gutter:0),
              child: _RecordTile(
                record: record,
                busy: isBusy(record.id),
                onRetry: () => onRetry(record),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({
    required this.record,
    required this.busy,
    required this.onRetry,
  });

  final TatmeenSyncRecord record;
  final bool busy;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final muted = context.colors.textMuted;
    return TraqCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: TraqSpacing.sm),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => showTatmeenOperationDetailsDialog(
                    context,
                    record: record,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DisplayDateUtils.dmyHm(record.createdAt),
                        style: context.text.bodySm.copyWith(color: muted),
                      ),
                      const SizedBox(height: TraqSpacing.xs),
                      Text(record.operationType, style: context.text.body),
                      Text(record.operationId, style: context.text.bodySm),
                      Text(
                        '${record.attemptsLabel}  ·  ${record.durationLabel}',
                        style: context.text.bodySm.copyWith(color: muted),
                      ),
                      Tooltip(
                        message: record.message,
                        child: Text(
                          record.truncatedMessage,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.bodySm.copyWith(color: muted),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: TraqSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TatmeenSyncStatusBadge(status: record.status),
                  if (record.status == TatmeenSyncStatus.failed)
                    FilledButton(
                      onPressed: busy
                          ? null
                          : () async {
                              final confirmed =
                                  await showTatmeenRetryRecordDialog(context);
                              if (confirmed) await onRetry();
                            },
                      child: busy
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Retry'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RowsSkeleton extends StatelessWidget {
  const _RowsSkeleton();

  @override
  Widget build(BuildContext context) {
    final muted = AppShimmer.defaultBaseColor(context);
    return AppShimmer(
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: context.gutter),
        itemCount: 8,
        separatorBuilder: (context, index) =>
            Divider(height: 1, color: context.colors.border),
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              0,
              TraqSpacing.lg,
              0,
              index == 7 ? context.gutter : 0,
            ),
            child: TraqCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: TraqSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppSkeletonBox(width: 140, height: 12, color: muted),
                          const SizedBox(height: TraqSpacing.xs),
                          AppSkeletonBox(width: 180, height: 14, color: muted),
                          const SizedBox(height: TraqSpacing.xs),
                          AppSkeletonBox(width: 120, height: 12, color: muted),
                          const SizedBox(height: TraqSpacing.xs),
                          AppSkeletonBox(width: 160, height: 12, color: muted),
                          const SizedBox(height: TraqSpacing.xs),
                          AppSkeletonBox(
                            width: double.infinity,
                            height: 12,
                            color: muted,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: TraqSpacing.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        AppSkeletonBox(
                          width: 72,
                          height: 24,
                          radius: 12,
                          color: muted,
                        ),
                        const SizedBox(height: TraqSpacing.lg),
                        AppSkeletonBox(
                          width: 72,
                          height: 36,
                          radius: 8,
                          color: muted,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
