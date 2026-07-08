import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/utils/display_date_utils.dart';
import '../cubit/notification_cubit.dart';
import '../cubit/notification_state.dart';
import '../../domain/models/notification_subscription.dart';
import '../widgets/create_subscription_dialog.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

class SubscriptionDetailsScreen extends StatefulWidget {
  final String subscriptionId;

  const SubscriptionDetailsScreen({
    super.key,
    required this.subscriptionId,
  });

  @override
  State<SubscriptionDetailsScreen> createState() => _SubscriptionDetailsScreenState();
}

class _SubscriptionDetailsScreenState extends State<SubscriptionDetailsScreen> {
  @override
  void initState() {
    super.initState();
    _loadSubscription();
  }

  void _loadSubscription() {
    final cubit = context.read<NotificationCubit>();
    cubit.loadSubscription(widget.subscriptionId);
    cubit.loadSubscriptionStats(widget.subscriptionId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        final subscription = state.selectedSubscription;
        final isLoading = state.status == NotificationStatus.loading && subscription == null;
        final stats = state.lastLoadedStatsSubscriptionId == widget.subscriptionId 
            ? state.lastLoadedStats 
            : null;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Subscription Details'),
            actions: [
              if (subscription != null) ...[
                IconButton(
                  icon: TraqIcon(AppAssets.iconEdit),
                  onPressed: () => _editSubscription(subscription),
                  tooltip: 'Edit Subscription',
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'pause':
                        _pauseSubscription();
                        break;
                      case 'resume':
                        _resumeSubscription();
                        break;
                      case 'delete':
                        _deleteSubscription();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    if (subscription.status == 'ACTIVE')
                      const PopupMenuItem(
                        value: 'pause',
                        child: Row(
                          children: [
                            TraqIcon(AppAssets.iconMinus),
                            SizedBox(width: 8),
                            Text('Pause'),
                          ],
                        ),
                      ),
                    if (subscription.status == 'PAUSED')
                      const PopupMenuItem(
                        value: 'resume',
                        child: Row(
                          children: [
                            TraqIcon(AppAssets.iconArrowR),
                            SizedBox(width: 8),
                            Text('Resume'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          TraqIcon(AppAssets.iconTrash, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          drawer: const AppDrawer(),
          body: BlocListener<NotificationCubit, NotificationState>(
            listener: (context, state) {
              if (state.status == NotificationStatus.error && state.error != null) {
                context.showError(state.error!);
              }
            },
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : subscription == null
                    ? _buildNotFoundWidget()
                    : _buildSubscriptionDetails(subscription, stats),
          ),
        );
      },
    );
  }

  Widget _buildNotFoundWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TraqIcon(AppAssets.iconAlert,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Subscription Not Found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'The requested subscription could not be found or may have been deleted.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/notifications/subscriptions'),
            child: const Text('Back to Subscriptions'),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionDetails(NotificationSubscription subscription, NotificationStats? stats) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          subscription.subscriptionName,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildStatusChip(subscription.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Type: ${subscription.subscriptionType}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  if (subscription.notificationFormat?.isNotEmpty == true) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Format: ${subscription.notificationFormat}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          _buildSection(
            'Contact Information',
            [
              _buildDetailRow('Email', subscription.webhookUrl.contains('@') 
                  ? subscription.webhookUrl : 'Not configured'),
              if (subscription.webhookUrl.isNotEmpty && !subscription.webhookUrl.contains('@'))
                _buildDetailRow('Webhook URL', subscription.webhookUrl),
            ],
          ),

          _buildSection(
            'Subscription Configuration',
            [
              _buildDetailRow('Query Parameters', 
                subscription.queryParameters?.entries
                    .map((e) => '${e.key}: ${e.value}')
                    .join(', ') ?? 'None'),
              _buildDetailRow('Notification Format', 
                subscription.notificationFormat ?? 'Default'),
            ],
          ),

          _buildSection(
            'Timing & Delivery',
            [
              _buildDetailRow('Created', DisplayDateUtils.dmyHm(subscription.createdAt)),
              _buildDetailRow('Last Modified', 
                subscription.updatedAt != null 
                    ? DisplayDateUtils.dmyHm(subscription.updatedAt!) 
                    : 'Never'),
              _buildDetailRow('Next Scheduled', subscription.status == 'ACTIVE' ? 'Real-time' : 'Paused'),
            ],
          ),

          _buildSection(
            'Statistics',
            [
              _buildDetailRow('Total Notifications', stats?.totalNotifications.toString() ?? 'Loading...'),
              _buildDetailRow('Success Rate', stats != null 
                  ? '${(stats.successRate * 100).toStringAsFixed(1)}%' 
                  : 'Loading...'),
              _buildDetailRow('Last Notification', stats?.lastNotificationSent != null 
                  ? DisplayDateUtils.dmyHm(stats!.lastNotificationSent!) 
                  : 'None'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: children,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    String chipIconAsset;

    switch (status) {
      case 'ACTIVE':
        chipColor = Colors.green;
        chipIconAsset = AppAssets.iconCheckCircle;
        break;
      case 'PAUSED':
        chipColor = Colors.orange;
        chipIconAsset = AppAssets.iconPause;
        break;
      case 'ERROR':
        chipColor = Colors.red;
        chipIconAsset = AppAssets.iconXCircle;
        break;
      default:
        chipColor = Colors.grey;
        chipIconAsset = AppAssets.iconHelpCircle;
    }

    return Chip(
      avatar: TraqIcon(chipIconAsset, color: Colors.white, size: 16),
      label: Text(
        status,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: chipColor,
    );
  }

  void _editSubscription(NotificationSubscription subscription) {
    showDialog(
      context: context,
      builder: (context) => CreateSubscriptionDialog(
        subscription: subscription,
      ),
    ).then((_) {
      _loadSubscription();
    });
  }

  void _pauseSubscription() {
    context.read<NotificationCubit>().pauseSubscription(widget.subscriptionId);
    context.showInfo('Subscription paused');
  }

  void _resumeSubscription() {
    context.read<NotificationCubit>().resumeSubscription(widget.subscriptionId);
    context.showInfo('Subscription resumed');
  }

  void _deleteSubscription() {
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
              context.read<NotificationCubit>().deleteSubscription(widget.subscriptionId);
              context.go('/notifications/subscriptions');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
