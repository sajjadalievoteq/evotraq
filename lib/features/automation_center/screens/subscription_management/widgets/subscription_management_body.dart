import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/data/models/automation_center/notification_subscription.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_cubit.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_state.dart';
import 'package:traqtrace_app/features/automation_center/utils/subscription_filter_utils.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_card.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_empty_state.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_error_view.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_list_view.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_loading_skeleton.dart';

class SubscriptionManagementBody extends StatelessWidget {
  const SubscriptionManagementBody({
    super.key,
    required this.selectedFilter,
    required this.shrinkWrap,
    required this.onRefresh,
    required this.onEdit,
    required this.onDelete,
    required this.onPause,
    required this.onResume,
    required this.onViewDetails,
    required this.onClearFilters,
    required this.onCreate,
  });

  final String selectedFilter;
  final bool shrinkWrap;
  final VoidCallback onRefresh;
  final void Function(NotificationSubscription) onEdit;
  final void Function(NotificationSubscription) onDelete;
  final void Function(NotificationSubscription) onPause;
  final void Function(NotificationSubscription) onResume;
  final void Function(NotificationSubscription) onViewDetails;
  final VoidCallback onClearFilters;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        if (state.status == NotificationStatus.initial ||
            (state.status == NotificationStatus.loading &&
                state.subscriptions.isEmpty)) {
          return SubscriptionLoadingSkeleton(
            shrinkWrap: shrinkWrap,
            itemCount: 4,
            shape: SubscriptionSkeletonShape.managementCard,
          );
        }
        if (state.status == NotificationStatus.error &&
            state.subscriptions.isEmpty) {
          return SubscriptionErrorView(
            title: 'Error Loading Subscriptions',
            message: state.error ?? 'Unknown error',
            onRetry: onRefresh,
          );
        }
        return _FilteredManagementCards(
          subscriptions: state.subscriptions,
          selectedFilter: selectedFilter,
          shrinkWrap: shrinkWrap,
          onRefresh: () async => onRefresh(),
          onEdit: onEdit,
          onDelete: onDelete,
          onPause: onPause,
          onResume: onResume,
          onViewDetails: onViewDetails,
          onClearFilters: onClearFilters,
          onCreate: onCreate,
        );
      },
    );
  }
}

class _FilteredManagementCards extends StatelessWidget {
  const _FilteredManagementCards({
    required this.subscriptions,
    required this.selectedFilter,
    required this.shrinkWrap,
    required this.onRefresh,
    required this.onEdit,
    required this.onDelete,
    required this.onPause,
    required this.onResume,
    required this.onViewDetails,
    required this.onClearFilters,
    required this.onCreate,
  });

  final List<NotificationSubscription> subscriptions;
  final String selectedFilter;
  final bool shrinkWrap;
  final Future<void> Function() onRefresh;
  final void Function(NotificationSubscription) onEdit;
  final void Function(NotificationSubscription) onDelete;
  final void Function(NotificationSubscription) onPause;
  final void Function(NotificationSubscription) onResume;
  final void Function(NotificationSubscription) onViewDetails;
  final VoidCallback onClearFilters;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final filtered = SubscriptionFilterUtils.filterManagement(
      subscriptions,
      selectedFilter,
    );

    return SubscriptionListView(
      cards: [
        for (final subscription in filtered)
          SubscriptionCard(
            subscription: subscription,
            onEdit: onEdit,
            onDelete: onDelete,
            onPause: onPause,
            onResume: onResume,
            onViewDetails: onViewDetails,
          ),
      ],
      emptyState: SubscriptionEmptyState(
        totalSubscriptions: subscriptions.length,
        selectedFilter: selectedFilter,
        title: 'No subscriptions yet',
        subtitle:
            'Create your first webhook or email subscription to get notified about EPCIS events.',
        onClearFilters: onClearFilters,
        onPrimaryAction: onCreate,
      ),
      shrinkWrap: shrinkWrap,
      onRefresh: onRefresh,
    );
  }
}
