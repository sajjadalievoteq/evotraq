import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_state.dart';
import 'package:traqtrace_app/features/automation_center/screens/notification_center/widgets/notification_center_body.dart';
import 'package:traqtrace_app/features/automation_center/screens/notification_center/widgets/notification_center_filter_chips.dart';
import 'package:traqtrace_app/features/automation_center/screens/notification_center/widgets/notification_connection_status.dart';

class NotificationCenterEmbeddedBody extends StatelessWidget {
  const NotificationCenterEmbeddedBody({
    super.key,
    required this.state,
    required this.live,
    required this.selectedFilter,
    required this.onFilterSelected,
    required this.onRefresh,
    required this.onClearFilters,
    required this.onPrimaryAction,
  });

  final NotificationState state;
  final bool live;
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;
  final VoidCallback onRefresh;
  final VoidCallback onClearFilters;
  final VoidCallback onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                'Aggregate Delivered / Failed counters per subscription. '
                'This is not a per-event notification inbox.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: c.textMuted,
                    ),
              ),
            ),
            const SizedBox(width: TraqSpacing.sm),
            NotificationConnectionStatus(live: live),
          ],
        ),
        const SizedBox(height: TraqSpacing.lg),
        NotificationCenterFilterChips(
          selectedFilter: selectedFilter,
          onFilterSelected: onFilterSelected,
        ),
        const SizedBox(height: TraqSpacing.lg),
        Divider(height: 1, color: c.border),
        const SizedBox(height: TraqSpacing.lg),
        NotificationCenterBody(
          state: state,
          selectedFilter: selectedFilter,
          shrinkWrap: true,
          onRefresh: onRefresh,
          onClearFilters: onClearFilters,
          onPrimaryAction: onPrimaryAction,
        ),
      ],
    );
  }
}
