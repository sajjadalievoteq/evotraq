import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import '../cubit/notification_cubit.dart';
import '../cubit/notification_state.dart';
import '../widgets/subscription_card.dart';
import '../widgets/create_subscription_dialog.dart';
import '../widgets/notification_subscription_help.dart';

class SubscriptionManagementScreen extends StatefulWidget {
  const SubscriptionManagementScreen({super.key});

  @override
  State<SubscriptionManagementScreen> createState() => _SubscriptionManagementScreenState();
}

class _SubscriptionManagementScreenState extends State<SubscriptionManagementScreen> {
  final ScrollController _scrollController = ScrollController();
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<NotificationCubit>().loadSubscriptions();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      final state = context.read<NotificationCubit>().state;
      if (state.status == NotificationStatus.success && !state.hasReachedMax) {
        context.read<NotificationCubit>().loadSubscriptions(page: state.currentPage + 1);
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Subscriptions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(context),
            tooltip: 'Help',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<NotificationCubit>().loadSubscriptions(page: 0);
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Filter and Stats Section
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Email & SMS Subscription Management',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Configure your email and SMS notification preferences for EPCIS events',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                // Filter chips
                _buildFilterChips(),
              ],
            ),
          ),
          const Divider(height: 1),
          // Subscription List
          Expanded(
            child: BlocBuilder<NotificationCubit, NotificationState>(
              builder: (context, state) {
                if (state.status == NotificationStatus.initial || 
                    (state.status == NotificationStatus.loading && state.subscriptions.isEmpty)) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state.status == NotificationStatus.error && state.subscriptions.isEmpty) {
                  return _buildErrorWidget(state.error ?? 'Unknown error');
                }
                return _buildSubscriptionsList(state);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateSubscriptionDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New Subscription'),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Wrap(
      spacing: 8.0,
      children: [
        FilterChip(
          label: const Text('All'),
          selected: _selectedFilter == 'all',
          onSelected: (selected) => setState(() => _selectedFilter = 'all'),
        ),
        FilterChip(
          label: const Text('Email Only'),
          selected: _selectedFilter == 'email',
          onSelected: (selected) => setState(() => _selectedFilter = 'email'),
        ),
        FilterChip(
          label: const Text('Active'),
          selected: _selectedFilter == 'active',
          onSelected: (selected) => setState(() => _selectedFilter = 'active'),
        ),
        FilterChip(
          label: const Text('Paused'),
          selected: _selectedFilter == 'paused',
          onSelected: (selected) => setState(() => _selectedFilter = 'paused'),
        ),
      ],
    );
  }

  Widget _buildSubscriptionsList(NotificationState state) {
    final filteredSubscriptions = _filterSubscriptions(state.subscriptions);
    
    if (filteredSubscriptions.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<NotificationCubit>().loadSubscriptions(page: 0);
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        itemCount: filteredSubscriptions.length + (state.hasReachedMax ? 0 : 1),
        itemBuilder: (context, index) {
          if (index >= filteredSubscriptions.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final subscription = filteredSubscriptions[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: SubscriptionCard(
              subscription: subscription,
              onEdit: (sub) => _editSubscription(sub.id),
              onDelete: (sub) => _deleteSubscription(sub.id),
              onPause: (sub) => _pauseSubscription(sub.id),
              onResume: (sub) => _resumeSubscription(sub.id),
              onViewDetails: (sub) => _viewSubscriptionDetails(sub.id),
            ),
          );
        },
      ),
    );
  }

  List<dynamic> _filterSubscriptions(List<dynamic> subscriptions) {
    switch (_selectedFilter) {
      case 'email':
        return subscriptions.where((sub) => 
          sub.subscriptionType?.toLowerCase().contains('email') == true ||
          sub.webhookUrl?.contains('@') == true
        ).toList();
      case 'active':
        return subscriptions.where((sub) => sub.status == 'ACTIVE').toList();
      case 'paused':
        return subscriptions.where((sub) => sub.status == 'PAUSED').toList();
      default:
        return subscriptions;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.subscriptions_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Subscriptions Found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first email or SMS subscription to get notified about EPCIS events',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCreateSubscriptionDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Create Subscription'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Subscriptions',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<NotificationCubit>().loadSubscriptions(page: 0);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showCreateSubscriptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateSubscriptionDialog(),
    ).then((_) {
      // Refresh subscriptions after dialog closes
      context.read<NotificationCubit>().loadSubscriptions(page: 0);
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subscription'),
        content: const Text('Are you sure you want to delete this subscription? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<NotificationCubit>().deleteSubscription(subscriptionId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
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
