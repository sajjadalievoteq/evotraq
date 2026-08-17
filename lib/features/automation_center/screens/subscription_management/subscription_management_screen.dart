import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/data/models/automation_center/notification_subscription.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_cubit.dart';
import 'package:traqtrace_app/features/automation_center/screens/subscription_management/widgets/subscription_management_body.dart';
import 'package:traqtrace_app/features/automation_center/widgets/confirm_delete_subscription_dialog.dart';
import 'package:traqtrace_app/features/automation_center/widgets/create_subscription_dialog.dart';
import 'package:traqtrace_app/features/automation_center/widgets/help_widgets/notification_subscription_help.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_embedded_body.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_filter_chips.dart';
import 'package:traqtrace_app/features/automation_center/screens/subscription_management/widgets/subscription_labeled_filter.dart';

/// Subscription-management filter options (UI labels only; filter logic stays
/// in [SubscriptionFilterUtils.filterManagement]).
const List<SubscriptionFilterOption> kSubscriptionManagementFilterOptions = [
  SubscriptionFilterOption(label: 'All', value: 'all'),
  SubscriptionFilterOption(label: 'API', value: 'webhook'),
  SubscriptionFilterOption(label: 'Email', value: 'email'),
];

const List<SubscriptionFilterOption> kSubscriptionStatusFilterOptions = [
  SubscriptionFilterOption(label: 'All', value: 'all'),
  SubscriptionFilterOption(label: 'Active', value: 'active'),
  SubscriptionFilterOption(label: 'Paused', value: 'paused'),
];

/// Alert Subscriptions panel content for Automation Center.
class SubscriptionManagementScreen extends StatefulWidget {
  const SubscriptionManagementScreen({super.key, this.onViewAllActivity});

  /// Switches the parent Notifications workspace to the Activity tab.
  final VoidCallback? onViewAllActivity;

  @override
  SubscriptionManagementScreenState createState() =>
      SubscriptionManagementScreenState();
}

class SubscriptionManagementScreenState
    extends State<SubscriptionManagementScreen> {
  String _selectedDeliveryFilter = 'all';
  String _selectedStatusFilter = 'all';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<NotificationCubit>().loadSubscriptions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void refresh() {
    context.read<NotificationCubit>().loadSubscriptions(force: true);
  }

  void showHelp() => _showHelpDialog(context);

  void showCreate() => _showCreateSubscriptionDialog(context);

  @override
  Widget build(BuildContext context) {
    return SubscriptionEmbeddedBody(
      description: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search subscriptions...',
          isDense: true,
          prefixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
          border: OutlineInputBorder(borderRadius: TraqRadius.input),
        ),
      ),
      filterChips: Wrap(
        spacing: TraqSpacing.xl,
        runSpacing: TraqSpacing.md,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SubscriptionLabeledFilter(
            label: 'Delivery',
            options: kSubscriptionManagementFilterOptions,
            selected: _selectedDeliveryFilter,
            onSelected: (filter) =>
                setState(() => _selectedDeliveryFilter = filter),
          ),
          SubscriptionLabeledFilter(
            label: 'Status',
            options: kSubscriptionStatusFilterOptions,
            selected: _selectedStatusFilter,
            onSelected: (filter) =>
                setState(() => _selectedStatusFilter = filter),
          ),
        ],
      ),
      body: SubscriptionManagementBody(
        selectedDeliveryFilter: _selectedDeliveryFilter,
        selectedStatusFilter: _selectedStatusFilter,
        searchQuery: _searchQuery,
        shrinkWrap: false,
        onRefresh: refresh,
        onEdit: (sub) => _editSubscription(sub.id),
        onDelete: _deleteSubscription,
        onPause: (sub) => _pauseSubscription(sub.id),
        onResume: (sub) => _resumeSubscription(sub.id),
        onViewDetails: (sub) => _viewSubscriptionDetails(sub.id),
        onViewAllActivity: widget.onViewAllActivity,
        onClearFilters: () => setState(() {
          _selectedDeliveryFilter = 'all';
          _selectedStatusFilter = 'all';
          _searchQuery = '';
          _searchController.clear();
        }),
        onCreate: () => _showCreateSubscriptionDialog(context),
      ),
    );
  }

  Future<void> _showCreateSubscriptionDialog(BuildContext context) async {
    final cubit = context.read<NotificationCubit>();
    await showDialog<bool>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: const CreateSubscriptionDialog(),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const NotificationSubscriptionHelp(),
    );
  }

  void _editSubscription(String subscriptionId) {
    context.push(
      Constants.notificationDetailRoute.replaceFirst(
        ':subscriptionId',
        subscriptionId,
      ),
    );
  }

  void _viewSubscriptionDetails(String subscriptionId) {
    _editSubscription(subscriptionId);
  }

  Future<void> _deleteSubscription(
    NotificationSubscription subscription,
  ) async {
    final cubit = context.read<NotificationCubit>();
    final confirmed = await showDeleteSubscriptionDialog(
      context,
      subscriptionName: subscription.subscriptionName,
    );
    if (confirmed) cubit.deleteSubscription(subscription.id);
  }

  void _pauseSubscription(String subscriptionId) {
    context.read<NotificationCubit>().pauseSubscription(subscriptionId);
  }

  void _resumeSubscription(String subscriptionId) {
    context.read<NotificationCubit>().resumeSubscription(subscriptionId);
  }
}
