import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/notification_cubit.dart';
import '../cubit/notification_state.dart';
import '../widgets/subscription_card.dart';
import '../widgets/create_subscription_dialog.dart';
import '../widgets/notification_quick_guide.dart';

import '../../domain/models/realtime_notification.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<NotificationCubit>().loadSubscriptions();
    // Don't automatically connect to WebSocket on init to avoid connection issues
    // User can manually trigger connection if needed
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
        context.read<NotificationCubit>().loadSubscriptions(
              page: state.currentPage + 1,
            );
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
        title: const Text('Notification Subscriptions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateDialog(context),
          ),
          BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              if (state.status == NotificationStatus.webSocketConnected) {
                return const Icon(
                  Icons.wifi,
                  color: Colors.green,
                );
              } else if (state.status == NotificationStatus.webSocketDisconnected) {
                return const Icon(
                  Icons.wifi_off,
                  color: Colors.red,
                );
              }
              return const Icon(
                Icons.wifi_off,
                color: Colors.grey,
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: BlocConsumer<NotificationCubit, NotificationState>(
        listener: (context, state) {
          if (state.status == NotificationStatus.error && state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state.status == NotificationStatus.subscriptionCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Subscription created successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state.status == NotificationStatus.subscriptionDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Subscription deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state.lastRealtimeNotification != null) {
            _showRealtimeNotification(context, state.lastRealtimeNotification!);
          }
        },
        builder: (context, state) {
          if (state.status == NotificationStatus.loading && state.subscriptions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == NotificationStatus.success || 
              state.status == NotificationStatus.loading ||
              state.status == NotificationStatus.subscriptionCreated ||
              state.status == NotificationStatus.subscriptionDeleted ||
              state.status == NotificationStatus.subscriptionUpdated) {
            
            if (state.subscriptions.isEmpty && state.status != NotificationStatus.loading) {
              return _buildEmptyState(context);
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<NotificationCubit>().loadSubscriptions();
              },
              child: ListView.builder(
                controller: _scrollController,
                itemCount: state.hasReachedMax
                    ? state.subscriptions.length
                    : state.subscriptions.length + 1,
                itemBuilder: (context, index) {
                  if (index >= state.subscriptions.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: SubscriptionCard(
                      subscription: state.subscriptions[index],
                      onEdit: (subscription) => _showEditDialog(
                        context,
                        subscription,
                      ),
                      onDelete: (subscription) => _showDeleteDialog(
                        context,
                        subscription,
                      ),
                      onPause: (subscription) => context
                          .read<NotificationCubit>()
                          .pauseSubscription(subscription.id),
                      onResume: (subscription) => context
                          .read<NotificationCubit>()
                          .resumeSubscription(subscription.id),
                      onViewDetails: (subscription) => context.push(
                        '/notifications/${subscription.id}',
                      ),
                    ),
                  );
                },
              ),
            );
          }

          if (state.status == NotificationStatus.error && state.subscriptions.isEmpty) {
            return _buildErrorState(context, state.error ?? 'Unknown error');
          }

          return _buildEmptyState(context);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const NotificationQuickGuide(),
          const SizedBox(height: 24),
          Icon(
            Icons.notifications_none,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No notification subscriptions',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first subscription to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCreateDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Create Subscription'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.red[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<NotificationCubit>().loadSubscriptions();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<NotificationCubit>(),
        child: const CreateSubscriptionDialog(),
      ),
    );
  }

  void _showEditDialog(BuildContext context, subscription) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<NotificationCubit>(),
        child: CreateSubscriptionDialog(subscription: subscription),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, subscription) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Subscription'),
        content: Text(
          'Are you sure you want to delete "${subscription.subscriptionName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context
                  .read<NotificationCubit>()
                  .deleteSubscription(subscription.id);
              Navigator.of(dialogContext).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showRealtimeNotification(BuildContext context, RealtimeNotification notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Real-time Notification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Event: ${notification.eventType}'),
            Text('Time: ${notification.timestamp}'),
            Text('Source: ${notification.source}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
