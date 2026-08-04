import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/automation_center/notification_subscription.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_cubit.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_state.dart';
import 'package:traqtrace_app/features/automation_center/screens/subscription_management/widgets/subscription_management_error.dart';
import 'package:traqtrace_app/features/automation_center/screens/subscription_management/widgets/subscription_management_filter_chips.dart';
import 'package:traqtrace_app/features/automation_center/screens/subscription_management/widgets/subscription_management_list.dart';
import 'package:traqtrace_app/features/automation_center/screens/subscription_management/widgets/subscription_management_loading_skeleton.dart';

class SubscriptionManagementStandaloneScaffold extends StatelessWidget {
  const SubscriptionManagementStandaloneScaffold({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
    required this.onRefresh,
    required this.onHelp,
    required this.onCreate,
    required this.onEdit,
    required this.onDelete,
    required this.onPause,
    required this.onResume,
    required this.onViewDetails,
    required this.onClearFilters,
  });

  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;
  final VoidCallback onRefresh;
  final VoidCallback onHelp;
  final VoidCallback onCreate;
  final void Function(NotificationSubscription) onEdit;
  final void Function(NotificationSubscription) onDelete;
  final void Function(NotificationSubscription) onPause;
  final void Function(NotificationSubscription) onResume;
  final void Function(NotificationSubscription) onViewDetails;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Subscriptions'),
        actions: [
          IconButton(
            icon: TraqIcon(AppAssets.iconInfo),
            onPressed: onHelp,
            tooltip: 'Help',
          ),
          IconButton(
            icon: TraqIcon(AppAssets.iconRefresh),
            onPressed: onRefresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: TraqSpacing.surfacePad,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alert Subscription Management',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: c.textPrimary,
                      ),
                ),
                const SizedBox(height: TraqSpacing.sm),
                Text(
                  'Configure webhook and email alert subscriptions for EPCIS events.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: c.textMuted,
                      ),
                ),
                const SizedBox(height: TraqSpacing.lg),
                SubscriptionManagementFilterChips(
                  selectedFilter: selectedFilter,
                  onFilterSelected: onFilterSelected,
                ),
              ],
            ),
          ),
          Divider(height: 1, color: c.border),
          Expanded(
            child: BlocBuilder<NotificationCubit, NotificationState>(
              builder: (context, state) {
                if (state.status == NotificationStatus.initial ||
                    (state.status == NotificationStatus.loading &&
                        state.subscriptions.isEmpty)) {
                  return const SubscriptionManagementLoadingSkeleton(
                    shrinkWrap: false,
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
                  shrinkWrap: false,
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onCreate,
        label: TraqIcon(AppAssets.iconPlus),
        tooltip: 'Create Subscription',
      ),
    );
  }
}
