import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import '../cubit/notification_cubit.dart';
import '../cubit/notification_state.dart';
import '../widgets/create_subscription_dialog.dart';

class WebhookConfigurationScreen extends StatefulWidget {
  const WebhookConfigurationScreen({super.key});

  @override
  State<WebhookConfigurationScreen> createState() => _WebhookConfigurationScreenState();
}

class _WebhookConfigurationScreenState extends State<WebhookConfigurationScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _webhookUrlController = TextEditingController();
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
    _webhookUrlController.dispose();
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
        title: const Text('Webhook Configuration'),
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
          // Header Section
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Webhook Endpoint Management',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Configure webhook endpoints to receive real-time EPCIS event notifications',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                // Webhook Test Section
                _buildWebhookTestSection(),
                const SizedBox(height: 16),
                // Filter chips
                _buildFilterChips(),
              ],
            ),
          ),
          const Divider(height: 1),
          // Webhook List
          Expanded(
            child: BlocBuilder<NotificationCubit, NotificationState>(
              builder: (context, state) {
                if (state.status == NotificationStatus.initial || 
                    (state.status == NotificationStatus.loading && state.subscriptions.isEmpty)) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state.status == NotificationStatus.error && state.subscriptions.isEmpty) {
                  return _buildErrorWidget(state.error ?? 'Unknown error');
                }
                return _buildWebhooksList(state);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateWebhookDialog(context),
        icon: const Icon(Icons.webhook),
        label: const Text('New Webhook'),
      ),
    );
  }

  Widget _buildWebhookTestSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bug_report, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Test Webhook Endpoint',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _webhookUrlController,
              decoration: const InputDecoration(
                hintText: 'https://your-api.com/webhooks/traqtrace',
                labelText: 'Webhook URL',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _testWebhook,
                  icon: const Icon(Icons.send),
                  label: const Text('Test Webhook'),
                ),
                const SizedBox(width: 12),
                TextButton.icon(
                  onPressed: _showWebhookDocumentation,
                  icon: const Icon(Icons.description),
                  label: const Text('Documentation'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Wrap(
      spacing: 8.0,
      children: [
        FilterChip(
          label: const Text('All Webhooks'),
          selected: _selectedFilter == 'all',
          onSelected: (selected) => setState(() => _selectedFilter = 'all'),
        ),
        FilterChip(
          label: const Text('Active'),
          selected: _selectedFilter == 'active',
          onSelected: (selected) => setState(() => _selectedFilter = 'active'),
        ),
        FilterChip(
          label: const Text('Failed'),
          selected: _selectedFilter == 'failed',
          onSelected: (selected) => setState(() => _selectedFilter = 'failed'),
        ),
        FilterChip(
          label: const Text('Webhooks Only'),
          selected: _selectedFilter == 'webhook',
          onSelected: (selected) => setState(() => _selectedFilter = 'webhook'),
        ),
      ],
    );
  }

  Widget _buildWebhooksList(NotificationState state) {
    final webhookSubscriptions = _filterWebhooks(state.subscriptions);
    
    if (webhookSubscriptions.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<NotificationCubit>().loadSubscriptions(page: 0);
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        itemCount: webhookSubscriptions.length + (state.hasReachedMax ? 0 : 1),
        itemBuilder: (context, index) {
          if (index >= webhookSubscriptions.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final subscription = webhookSubscriptions[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _buildWebhookCard(subscription),
          );
        },
      ),
    );
  }

  List<dynamic> _filterWebhooks(List<dynamic> subscriptions) {
    // Filter to show only webhook subscriptions
    var webhooks = subscriptions.where((sub) => 
      sub.subscriptionType?.toUpperCase() == 'WEBHOOK' ||
      (sub.webhookUrl?.isNotEmpty == true && !sub.webhookUrl.contains('@'))
    ).toList();

    switch (_selectedFilter) {
      case 'active':
        return webhooks.where((sub) => sub.status == 'ACTIVE').toList();
      case 'failed':
        return webhooks.where((sub) => 
          sub.stats?.failedNotifications != null && sub.stats.failedNotifications > 0
        ).toList();
      case 'webhook':
        return webhooks;
      default:
        return webhooks;
    }
  }

  Widget _buildWebhookCard(dynamic subscription) {
    final stats = subscription.stats;
    final hasErrors = stats?.failedNotifications != null && stats.failedNotifications > 0;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _viewWebhookDetails(subscription.id),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      subscription.subscriptionName ?? 'Unnamed Webhook',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildWebhookStatusChip(subscription.status, hasErrors),
                  const SizedBox(width: 8),
                  _buildWebhookActionMenu(subscription),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'URL: ${subscription.webhookUrl}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (stats != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatChip('Success', stats.successfulNotifications ?? 0, Colors.green),
                    const SizedBox(width: 8),
                    _buildStatChip('Failed', stats.failedNotifications ?? 0, Colors.red),
                    const SizedBox(width: 8),
                    _buildStatChip('Total', stats.totalNotifications ?? 0, Colors.blue),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Text(
                'Created: ${_formatDate(subscription.createdAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebhookStatusChip(String status, bool hasErrors) {
    Color color;
    IconData icon;
    
    if (hasErrors) {
      color = Colors.orange;
      icon = Icons.warning;
    } else if (status == 'ACTIVE') {
      color = Colors.green;
      icon = Icons.check_circle;
    } else {
      color = Colors.grey;
      icon = Icons.pause_circle;
    }

    return Chip(
      avatar: Icon(icon, color: Colors.white, size: 16),
      label: Text(
        hasErrors ? 'ERRORS' : status,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
    );
  }

  Widget _buildWebhookActionMenu(dynamic subscription) {
    return PopupMenuButton<String>(
      onSelected: (value) => _handleWebhookAction(value, subscription),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'test',
          child: ListTile(
            leading: Icon(Icons.send),
            title: Text('Test Webhook'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: 'edit',
          child: ListTile(
            leading: Icon(Icons.edit),
            title: Text('Edit'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem(
          value: subscription.status == 'ACTIVE' ? 'pause' : 'resume',
          child: ListTile(
            leading: Icon(subscription.status == 'ACTIVE' ? Icons.pause : Icons.play_arrow),
            title: Text(subscription.status == 'ACTIVE' ? 'Pause' : 'Resume'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: 'history',
          child: ListTile(
            leading: Icon(Icons.history),
            title: Text('View History'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: Text('Delete', style: TextStyle(color: Colors.red)),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip(String label, int count, Color color) {
    return Chip(
      label: Text(
        '$label: $count',
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.webhook,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Webhooks Configured',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first webhook to receive real-time event notifications',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCreateWebhookDialog(context),
            icon: const Icon(Icons.webhook),
            label: const Text('Create Webhook'),
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
            'Error Loading Webhooks',
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
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  void _testWebhook() {
    final url = _webhookUrlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a webhook URL')),
      );
      return;
    }

    context.read<NotificationCubit>().testWebhook(url);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Testing webhook...')),
    );
  }

  void _showWebhookDocumentation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Webhook Documentation'),
        content: const SingleChildScrollView(
          child: Text(
            'Webhook Payload Format:\n\n'
            '{\n'
            '  "subscriptionId": "string",\n'
            '  "eventType": "string",\n'
            '  "eventData": {\n'
            '    "eventTime": "ISO8601",\n'
            '    "businessStep": "string",\n'
            '    "disposition": "string",\n'
            '    "readPoint": "string",\n'
            '    "businessLocation": "string"\n'
            '  },\n'
            '  "timestamp": "ISO8601"\n'
            '}\n\n'
            'Headers:\n'
            '- Content-Type: application/json\n'
            '- X-TraqTrace-Signature: HMAC-SHA256\n\n'
            'Your endpoint should return HTTP 200 for successful delivery.',
            style: TextStyle(fontFamily: 'monospace'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showCreateWebhookDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateSubscriptionDialog(),
    ).then((_) {
      context.read<NotificationCubit>().loadSubscriptions(page: 0);
    });
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Webhook Configuration Help'),
        content: const SingleChildScrollView(
          child: Text(
            'Webhooks allow you to receive real-time notifications when EPCIS events match your subscription criteria.\n\n'
            'Key Features:\n'
            '• Real-time event delivery\n'
            '• Automatic retry on failures\n'
            '• Delivery statistics tracking\n'
            '• Secure payload signing\n\n'
            'Requirements:\n'
            '• HTTPS endpoint\n'
            '• Returns HTTP 200 on success\n'
            '• Handles JSON payload\n\n'
            'Use the test feature to verify your endpoint before going live.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleWebhookAction(String action, dynamic subscription) {
    switch (action) {
      case 'test':
        context.read<NotificationCubit>().testWebhook(subscription.webhookUrl);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Testing webhook...')),
        );
        break;
      case 'edit':
        context.go('/notifications/${subscription.id}');
        break;
      case 'pause':
        context.read<NotificationCubit>().pauseSubscription(subscription.id);
        break;
      case 'resume':
        context.read<NotificationCubit>().resumeSubscription(subscription.id);
        break;
      case 'history':
        _showWebhookHistory(subscription.id);
        break;
      case 'delete':
        _deleteWebhook(subscription.id);
        break;
    }
  }

  void _viewWebhookDetails(String subscriptionId) {
    context.go('/notifications/$subscriptionId');
  }

  void _showWebhookHistory(String subscriptionId) {
    // Load webhook history
    context.read<NotificationCubit>().loadWebhookHistory(subscriptionId);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Webhook History'),
        content: const SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Center(child: Text('Webhook history feature coming soon...')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _deleteWebhook(String subscriptionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Webhook'),
        content: const Text('Are you sure you want to delete this webhook? This action cannot be undone.'),
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
}
