import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_state.dart';
import 'package:traqtrace_app/features/automation_center/screens/notification_center/widgets/notification_center_error.dart';
import 'package:traqtrace_app/features/automation_center/screens/notification_center/widgets/notification_center_loading_skeleton.dart';
import 'package:traqtrace_app/features/automation_center/screens/notification_center/widgets/notification_center_subscriptions_list.dart';

class NotificationCenterBody extends StatelessWidget {
  const NotificationCenterBody({
    super.key,
    required this.state,
    required this.selectedFilter,
    required this.shrinkWrap,
    required this.onRefresh,
    required this.onClearFilters,
    required this.onPrimaryAction,
  });

  final NotificationState state;
  final String selectedFilter;
  final bool shrinkWrap;
  final VoidCallback onRefresh;
  final VoidCallback onClearFilters;
  final VoidCallback onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    if (state.status == NotificationStatus.initial ||
        (state.status == NotificationStatus.loading &&
            state.subscriptions.isEmpty)) {
      return NotificationCenterLoadingSkeleton(shrinkWrap: shrinkWrap);
    }
    if (state.status == NotificationStatus.error &&
        state.subscriptions.isEmpty) {
      return NotificationCenterError(
        message: state.error ?? 'Unknown error',
        onRetry: onRefresh,
      );
    }
    return NotificationCenterSubscriptionsList(
      subscriptions: state.subscriptions,
      selectedFilter: selectedFilter,
      shrinkWrap: shrinkWrap,
      onRefresh: () async => onRefresh(),
      onClearFilters: onClearFilters,
      onPrimaryAction: onPrimaryAction,
    );
  }
}
