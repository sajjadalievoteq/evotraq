import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_cubit.dart';
import 'package:traqtrace_app/features/automation_center/screens/subscription_management/widgets/subscription_management_body.dart';
import 'package:traqtrace_app/features/automation_center/widgets/create_subscription_dialog.dart';
import 'package:traqtrace_app/features/automation_center/widgets/notification_subscription_help.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_embedded_body.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_filter_chips.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_standalone_scaffold.dart';

/// Subscription-management filter options (UI labels only; filter logic stays
/// in [SubscriptionFilterUtils.filterManagement]).
const List<SubscriptionFilterOption> kSubscriptionManagementFilterOptions = [
  SubscriptionFilterOption(label: 'All', value: 'all'),
  SubscriptionFilterOption(label: 'Email Only', value: 'email'),
  SubscriptionFilterOption(label: 'Active', value: 'active'),
  SubscriptionFilterOption(label: 'Paused', value: 'paused'),
];

class SubscriptionManagementScreen extends StatefulWidget {
  const SubscriptionManagementScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  SubscriptionManagementScreenState createState() =>
      SubscriptionManagementScreenState();
}

class SubscriptionManagementScreenState
    extends State<SubscriptionManagementScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    context.read<NotificationCubit>().loadSubscriptions();
  }

  void refresh() {
    context.read<NotificationCubit>().loadSubscriptions(force: true);
  }

  void showHelp() => _showHelpDialog(context);

  void showCreate() => _showCreateSubscriptionDialog(context);

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) {
      return _buildEmbedded(context);
    }
    return _buildStandalone(context);
  }

  Widget _buildEmbedded(BuildContext context) {
    final c = context.colors;
    return SubscriptionEmbeddedBody(
      description: Text(
        'Filter by delivery method or status. Supports webhook and email delivery.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: c.textMuted,
            ),
      ),
      filterChips: SubscriptionFilterChips(
        options: kSubscriptionManagementFilterOptions,
        selectedFilter: _selectedFilter,
        onFilterSelected: (filter) => setState(() => _selectedFilter = filter),
      ),
      body: SubscriptionManagementBody(
        selectedFilter: _selectedFilter,
        shrinkWrap: true,
        onRefresh: refresh,
        onEdit: (sub) => _editSubscription(sub.id),
        onDelete: (sub) => _deleteSubscription(sub.id),
        onPause: (sub) => _pauseSubscription(sub.id),
        onResume: (sub) => _resumeSubscription(sub.id),
        onViewDetails: (sub) => _viewSubscriptionDetails(sub.id),
        onClearFilters: () => setState(() => _selectedFilter = 'all'),
        onCreate: () => _showCreateSubscriptionDialog(context),
      ),
    );
  }

  Widget _buildStandalone(BuildContext context) {
    final c = context.colors;
    return SubscriptionStandaloneScaffold(
      title: 'Manage Subscriptions',
      actions: [
        IconButton(
          icon: TraqIcon(AppAssets.iconInfo),
          onPressed: () => _showHelpDialog(context),
          tooltip: 'Help',
        ),
        IconButton(
          icon: TraqIcon(AppAssets.iconRefresh),
          onPressed: refresh,
          tooltip: 'Refresh',
        ),
      ],
      header: Column(
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
          SubscriptionFilterChips(
            options: kSubscriptionManagementFilterOptions,
            selectedFilter: _selectedFilter,
            onFilterSelected: (filter) =>
                setState(() => _selectedFilter = filter),
          ),
        ],
      ),
      body: SubscriptionManagementBody(
        selectedFilter: _selectedFilter,
        shrinkWrap: false,
        onRefresh: refresh,
        onEdit: (sub) => _editSubscription(sub.id),
        onDelete: (sub) => _deleteSubscription(sub.id),
        onPause: (sub) => _pauseSubscription(sub.id),
        onResume: (sub) => _resumeSubscription(sub.id),
        onViewDetails: (sub) => _viewSubscriptionDetails(sub.id),
        onClearFilters: () => setState(() => _selectedFilter = 'all'),
        onCreate: () => _showCreateSubscriptionDialog(context),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateSubscriptionDialog(context),
        label: TraqIcon(AppAssets.iconPlus),
        tooltip: 'Create Subscription',
      ),
    );
  }

  void _showCreateSubscriptionDialog(BuildContext context) {
    // showDialog builds on the root overlay, outside this screen's provider
    // scope, so re-provide the SAME NotificationCubit instance into the dialog
    // subtree via BlocProvider.value (not create:, which would spin up a
    // second cubit). Without this the dialog's BlocListener throws
    // ProviderNotFoundException.
    final cubit = context.read<NotificationCubit>();
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: const CreateSubscriptionDialog(),
      ),
    ).then((_) {
      cubit.loadSubscriptions(force: true);
    });
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const NotificationSubscriptionHelp(),
    );
  }

  void _editSubscription(String subscriptionId) {
    context.go('/notifications/$subscriptionId');
  }

  void _viewSubscriptionDetails(String subscriptionId) {
    context.go('/notifications/$subscriptionId');
  }

  void _deleteSubscription(String subscriptionId) {
    final cubit = context.read<NotificationCubit>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Subscription'),
        content: const Text(
          'Are you sure you want to delete this subscription? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              cubit.deleteSubscription(subscriptionId);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColorMapper.errorColor(context),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _pauseSubscription(String subscriptionId) {
    context.read<NotificationCubit>().pauseSubscription(subscriptionId);
  }

  void _resumeSubscription(String subscriptionId) {
    context.read<NotificationCubit>().resumeSubscription(subscriptionId);
  }
}
