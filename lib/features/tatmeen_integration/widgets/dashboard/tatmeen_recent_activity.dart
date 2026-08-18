import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/display_date_utils.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';
import 'package:traqtrace_app/core/widgets/empty_state/app_empty_state.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_dashboard_models.dart';

class TatmeenRecentActivity extends StatelessWidget {
  const TatmeenRecentActivity({
    super.key,
    required this.events,
    required this.isLoading,
    required this.error,
    required this.onRetry,
  });

  final List<TatmeenSyncEvent> events;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;

  static const _tableMinWidth = 720.0;

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const _RowsSkeleton();
    if (error != null) {
      return Center(
        child: FilledButton(onPressed: onRetry, child: const Text('Retry')),
      );
    }
    if (events.isEmpty) {
      return const AppEmptyState(
        iconAsset: AppAssets.iconHistory,
        title: 'No sync activity yet',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final compact =
                context.isMobile || constraints.maxWidth < _tableMinWidth;
            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < events.length; i++) ...[
                    if (i > 0)
                      Divider(height: 1, color: context.colors.border),
                    _ActivityListTile(event: events[i]),
                  ],
                ],
              );
            }
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                      columnSpacing: TraqSpacing.lg,
                      columns: const [
                        DataColumn(label: Text('Timestamp')),
                        DataColumn(label: Text('Record Type')),
                        DataColumn(label: Text('Record ID')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Message')),
                      ],
                      rows: events
                          .map(
                            (e) => DataRow(
                              cells: [
                                DataCell(
                                  Text(DisplayDateUtils.dmyHm(e.timestamp)),
                                ),
                                DataCell(Text(e.recordType)),
                                DataCell(
                                  SizedBox(
                                    width: 180,
                                    child: Tooltip(
                                      message: e.recordId,
                                      child: Text(
                                        e.recordId,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(_StatusBadge(status: e.status)),
                                DataCell(
                                  SizedBox(
                                    width: 220,
                                    child: Tooltip(
                                      message: e.message,
                                      child: Text(
                                        e.message,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                );
              },
            ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(onPressed: () {}, child: const Text('View all')),
        ),
      ],
    );
  }
}

class _ActivityListTile extends StatelessWidget {
  const _ActivityListTile({required this.event});

  final TatmeenSyncEvent event;

  @override
  Widget build(BuildContext context) {
    final muted = context.colors.textMuted;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TraqSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  DisplayDateUtils.dmyHm(event.timestamp),
                  style: context.text.bodySm.copyWith(color: muted),
                ),
              ),
              _StatusBadge(status: event.status),
            ],
          ),
          const SizedBox(height: TraqSpacing.xs),
          Text(event.recordType, style: context.text.body),
          const SizedBox(height: TraqSpacing.xs),
          Tooltip(
            message: event.recordId,
            child: Text(
              event.recordId,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodySm,
            ),
          ),
          const SizedBox(height: TraqSpacing.xs),
          Tooltip(
            message: event.message,
            child: Text(
              event.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodySm.copyWith(color: muted),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final TatmeenSyncStatus status;
  @override
  Widget build(BuildContext context) {
    final (text, color) = switch (status) {
      TatmeenSyncStatus.successful => ('Successful', context.colors.success),
      TatmeenSyncStatus.failed => ('Failed', context.colors.error),
      TatmeenSyncStatus.pending => ('Pending', context.colors.warning),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TraqSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        borderRadius: TraqRadius.chip,
      ),
      child: Text(
        text,
        style: context.text.bodySm.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
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
      child: Column(
        children: List.generate(
          5,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: TraqSpacing.sm),
            child: AppSkeletonBox(height: 24, color: muted),
          ),
        ),
      ),
    );
  }
}
