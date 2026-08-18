import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/display_date_utils.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/empty_state/app_empty_state.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_dashboard_models.dart';
import 'package:traqtrace_app/features/tatmeen_integration/widgets/tatmeen_sync_status_badge.dart';

class TatmeenSyncEventsList extends StatelessWidget {
  const TatmeenSyncEventsList({
    super.key,
    required this.events,
    required this.emptyIconAsset,
    required this.emptyTitle,
    this.emptySubtitle,
    this.attempts,
    this.onRetry,
  });

  final List<TatmeenSyncEvent> events;
  final String emptyIconAsset;
  final String emptyTitle;
  final String? emptySubtitle;
  final Map<String, int>? attempts;
  final ValueChanged<TatmeenSyncEvent>? onRetry;

  static const _tableMinWidth = 760.0;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return AppEmptyState(
        iconAsset: emptyIconAsset,
        title: emptyTitle,
        subtitle: emptySubtitle,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            context.isMobile || constraints.maxWidth < _tableMinWidth;
        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < events.length; i++) ...[
                if (i > 0) Divider(height: 1, color: context.colors.border),
                _EventListTile(
                  event: events[i],
                  attempts: attempts?[events[i].recordId],
                  onRetry: onRetry,
                ),
              ],
            ],
          );
        }

        final showAttempts = attempts != null;
        final showRetry = onRetry != null;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              columnSpacing: TraqSpacing.lg,
              columns: [
                const DataColumn(label: Text('Timestamp')),
                const DataColumn(label: Text('Record Type')),
                const DataColumn(label: Text('Record ID')),
                const DataColumn(label: Text('Status')),
                const DataColumn(label: Text('Message')),
                if (showAttempts) const DataColumn(label: Text('Attempts')),
                if (showRetry) const DataColumn(label: Text('')),
              ],
              rows: [
                for (final event in events)
                  DataRow(
                    cells: [
                      DataCell(Text(DisplayDateUtils.dmyHm(event.timestamp))),
                      DataCell(Text(event.recordType)),
                      DataCell(
                        SizedBox(
                          width: 180,
                          child: Tooltip(
                            message: event.recordId,
                            child: Text(
                              event.recordId,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      DataCell(TatmeenSyncStatusBadge(status: event.status)),
                      DataCell(
                        SizedBox(
                          width: 220,
                          child: Tooltip(
                            message: event.message,
                            child: Text(
                              event.message,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      if (showAttempts)
                        DataCell(Text('${attempts?[event.recordId] ?? 1}')),
                      if (showRetry)
                        DataCell(
                          TextButton(
                            onPressed: () => onRetry!(event),
                            child: const Text('Retry'),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EventListTile extends StatelessWidget {
  const _EventListTile({
    required this.event,
    required this.attempts,
    required this.onRetry,
  });

  final TatmeenSyncEvent event;
  final int? attempts;
  final ValueChanged<TatmeenSyncEvent>? onRetry;

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
              TatmeenSyncStatusBadge(status: event.status),
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
          if (attempts != null) ...[
            const SizedBox(height: TraqSpacing.xs),
            Text(
              'Attempts: $attempts',
              style: context.text.bodySm.copyWith(color: muted),
            ),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: TraqSpacing.xs),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => onRetry!(event),
                child: const Text('Retry'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
