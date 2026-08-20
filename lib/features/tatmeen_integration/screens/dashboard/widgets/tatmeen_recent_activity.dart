import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/display_date_utils.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';
import 'package:traqtrace_app/core/widgets/empty_state/app_empty_state.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_dashboard_models.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_error_view.dart';

part 'tatmeen_activity_list_tile.dart';
part 'tatmeen_activity_status_badge.dart';
part 'tatmeen_activity_rows_skeleton.dart';

class TatmeenRecentActivity extends StatelessWidget {
  const TatmeenRecentActivity({
    super.key,
    required this.events,
    required this.isLoading,
    required this.error,
    required this.onRetry,
    this.onViewAll,
  });

  final List<TatmeenSyncEvent> events;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;
  final VoidCallback? onViewAll;

  static const _tableMinWidth = 720.0;

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const TatmeenActivityRowsSkeleton();
    if (error != null) {
      return SubscriptionErrorView(
        title: 'Unable to load recent activity',
        message: error!,
        onRetry: onRetry,
        padding: EdgeInsets.zero,
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
                    if (i > 0) Divider(height: 1, color: context.colors.border),
                    TatmeenActivityListTile(event: events[i]),
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
                            DataCell(Text(DisplayDateUtils.dmyHm(e.timestamp))),
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
                            DataCell(
                              TatmeenActivityStatusBadge(status: e.status),
                            ),
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
          child: TextButton(
            onPressed: onViewAll,
            child: const Text('View all'),
          ),
        ),
      ],
    );
  }
}
