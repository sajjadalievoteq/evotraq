import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import '../cubit/notification_cubit.dart';
import '../cubit/notification_state.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  final ScrollController _scrollController = ScrollController();
  String _selectedFilter = 'all';
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Load notifications first
    context.read<NotificationCubit>().loadSubscriptions();
    // Don't auto-connect to WebSocket to avoid connection errors
    // User can manually connect if needed
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // Only disconnect if we're connected
    if (_isConnected) {
      context.read<NotificationCubit>().disconnectWebSocket();
    }
    super.dispose();
  }

  void _connectToWebSocket() {
    try {
      context.read<NotificationCubit>().connectWebSocket();
      setState(() => _isConnected = true);
    } catch (e) {
      setState(() => _isConnected = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect: ${e.toString()}')),
      );
    }
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
        title: const Text('Notification Center'),
        actions: [
          IconButton(
            icon: Icon(
              _isConnected ? Icons.wifi : Icons.wifi_off,
              color: _isConnected ? Colors.green : Colors.red,
            ),
            onPressed: _toggleWebSocketConnection,
            tooltip: _isConnected ? 'Connected to real-time updates' : 'Disconnected',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/notifications/subscriptions'),
            tooltip: 'Manage Subscriptions',
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
          // Status and Filter Section
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Recent Notifications',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildConnectionStatus(),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Real-time notifications from your active subscriptions',
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
          // Notifications List
          Expanded(
            child: BlocBuilder<NotificationCubit, NotificationState>(
              builder: (context, state) {
                if (state.status == NotificationStatus.initial || 
                    (state.status == NotificationStatus.loading && state.subscriptions.isEmpty)) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state.status == NotificationStatus.error && state.subscriptions.isEmpty) {
                  return _buildErrorWidget(state.error ?? 'Unknown error');
                }
                return _buildNotificationsList(state);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/notifications/subscriptions'),
        icon: const Icon(Icons.add),
        label: const Text('Add Subscription'),
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _isConnected ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        border: Border.all(
          color: _isConnected ? Colors.green : Colors.red,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isConnected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
            size: 16,
            color: _isConnected ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 6),
          Text(
            _isConnected ? 'Live' : 'Offline',
            style: TextStyle(
              color: _isConnected ? Colors.green : Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
          label: const Text('Today'),
          selected: _selectedFilter == 'today',
          onSelected: (selected) => setState(() => _selectedFilter = 'today'),
        ),
        FilterChip(
          label: const Text('This Week'),
          selected: _selectedFilter == 'week',
          onSelected: (selected) => setState(() => _selectedFilter = 'week'),
        ),
        FilterChip(
          label: const Text('Transaction Events'),
          selected: _selectedFilter == 'transaction',
          onSelected: (selected) => setState(() => _selectedFilter = 'transaction'),
        ),
        FilterChip(
          label: const Text('Object Events'),
          selected: _selectedFilter == 'object',
          onSelected: (selected) => setState(() => _selectedFilter = 'object'),
        ),
      ],
    );
  }

  Widget _buildNotificationsList(NotificationState state) {
    // For now, we'll show subscription activity as notifications
    // In a full implementation, this would show actual received notifications
    final filteredData = _filterNotifications(state);
    
    if (filteredData.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<NotificationCubit>().loadSubscriptions(page: 0);
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        itemCount: filteredData.length + (state.hasReachedMax ? 0 : 1),
        itemBuilder: (context, index) {
          if (index >= filteredData.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _buildNotificationCard(filteredData[index]),
          );
        },
      ),
    );
  }

  List<dynamic> _filterNotifications(NotificationState state) {
    final now = DateTime.now();
    final subscriptions = state.subscriptions;

    // Filter based on selected criteria
    switch (_selectedFilter) {
      case 'today':
        return subscriptions.where((sub) {
          final created = sub.createdAt;
          return created.day == now.day && 
                 created.month == now.month && 
                 created.year == now.year;
        }).toList();
      case 'week':
        final weekAgo = now.subtract(const Duration(days: 7));
        return subscriptions.where((sub) {
          final created = sub.createdAt;
          return created.isAfter(weekAgo);
        }).toList();
      case 'transaction':
        return subscriptions.where((sub) =>
          sub.queryParameters?.toString().toLowerCase().contains('transaction') == true
        ).toList();
      case 'object':
        return subscriptions.where((sub) =>
          sub.queryParameters?.toString().toLowerCase().contains('object') == true
        ).toList();
      default:
        return subscriptions;
    }
  }

  Widget _buildNotificationCard(dynamic subscription) {
    final stats = subscription.stats;
    final hasActivity = stats != null && (stats.totalNotifications ?? 0) > 0;

    return Card(
      elevation: hasActivity ? 3 : 1,
      child: InkWell(
        onTap: () => _viewSubscriptionDetails(subscription.id),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getNotificationIcon(subscription.subscriptionType),
                    color: hasActivity ? Colors.blue : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subscription.subscriptionName ?? 'Unnamed Subscription',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Type: ${subscription.subscriptionType}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasActivity) _buildActivityBadge(stats),
                ],
              ),
              if (stats != null && hasActivity) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatColumn('Delivered', stats.successfulNotifications ?? 0, Colors.green),
                      ),
                      Expanded(
                        child: _buildStatColumn('Failed', stats.failedNotifications ?? 0, Colors.red),
                      ),
                      Expanded(
                        child: _buildStatColumn('Total', stats.totalNotifications ?? 0, Colors.blue),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    subscription.status == 'ACTIVE' ? Icons.check_circle : Icons.pause_circle,
                    size: 16,
                    color: subscription.status == 'ACTIVE' ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    subscription.status ?? 'UNKNOWN',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: subscription.status == 'ACTIVE' ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Created: ${_formatDate(subscription.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityBadge(dynamic stats) {
    final total = stats.totalNotifications ?? 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        total.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  IconData _getNotificationIcon(String? type) {
    switch (type?.toUpperCase()) {
      case 'EMAIL':
        return Icons.email;
      case 'WEBHOOK':
        return Icons.webhook;
      case 'SMS':
        return Icons.sms;
      default:
        return Icons.notifications;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Notifications Yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create subscriptions to start receiving notifications about EPCIS events',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/notifications/subscriptions'),
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
            'Error Loading Notifications',
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

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown';
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  void _toggleWebSocketConnection() {
    try {
      if (_isConnected) {
        context.read<NotificationCubit>().disconnectWebSocket();
        setState(() => _isConnected = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Disconnected from real-time updates')),
        );
      } else {
        _connectToWebSocket();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connecting to real-time updates...')),
        );
      }
    } catch (e) {
      setState(() => _isConnected = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection error: ${e.toString()}')),
      );
    }
  }

  void _viewSubscriptionDetails(String subscriptionId) {
    context.go('/notifications/$subscriptionId');
  }
}
