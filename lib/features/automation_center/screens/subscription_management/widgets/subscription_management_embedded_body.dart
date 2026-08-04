import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/data/models/automation_center/notification_subscription.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_cubit.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_state.dart';
import 'package:traqtrace_app/features/automation_center/screens/subscription_management/widgets/subscription_management_error.dart';
import 'package:traqtrace_app/features/automation_center/screens/subscription_management/widgets/subscription_management_filter_chips.dart';
import 'package:traqtrace_app/features/automation_center/screens/subscription_management/widgets/subscription_management_list.dart';
import 'package:traqtrace_app/features/automation_center/screens/subscription_management/widgets/subscription_management_loading_skeleton.dart';

class SubscriptionManagementEmbeddedBody extends StatelessWidget {
  const SubscriptionManagementEmbeddedBody({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
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
  final ValueChanged<String> onFilterSelected;
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
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Filter by delivery method or status. Supports webhook and email delivery.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: c.textMuted,
              ),
        ),
        const SizedBox(height: TraqSpacing.lg),
        SubscriptionManagementFilterChips(
          selectedFilter: selectedFilter,
          onFilterSelected: onFilterSelected,
        ),
        const SizedBox(height: TraqSpacing.lg),
        Divider(height: 1, color: c.border),
        const SizedBox(height: TraqSpacing.lg),
        Expanded(
          child: BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              if (state.status == NotificationStatus.initial ||
                  (state.status == NotificationStatus.loading &&
                      state.subscriptions.isEmpty)) {
                return const SubscriptionManagementLoadingSkeleton(
                  shrinkWrap: true,
                );
              }
              if (state.status == NotificationStatus.error &&
                  state.subscriptions.isEmpty) {
                return SubscriptionManagementError(
                  message: state.error ?? 'Unknown error',
                  onRetry: onRefresh,
                );
              }
              return SubscriptionManagementList(
                subscriptions: state.subscriptions,
                selectedFilter: selectedFilter,
                shrinkWrap: true,
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
          ),
        ),
      ],
    );
  }
}
