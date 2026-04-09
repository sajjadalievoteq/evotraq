import 'package:flutter/material.dart';
import '../../domain/models/notification_subscription.dart';

class SubscriptionCard extends StatelessWidget {
  final NotificationSubscription subscription;
  final Function(NotificationSubscription) onEdit;
  final Function(NotificationSubscription) onDelete;
  final Function(NotificationSubscription) onPause;
  final Function(NotificationSubscription) onResume;
  final Function(NotificationSubscription) onViewDetails;

  const SubscriptionCard({
    super.key,
    required this.subscription,
    required this.onEdit,
    required this.onDelete,
    required this.onPause,
    required this.onResume,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => onViewDetails(subscription),
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  _buildStatusChip(context),
                  const SizedBox(width: 8),
                  _buildActionMenu(context),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Type: ${subscription.subscriptionType}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Webhook: ${subscription.webhookUrl}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Created: ${_formatDate(subscription.createdAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              if (subscription.stats != null) ...[
                const SizedBox(height: 12),
                _buildStatsRow(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color color;
    IconData icon;
    String label = subscription.status;

    switch (subscription.status.toLowerCase()) {
      case 'active':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'paused':
        color = Colors.orange;
        icon = Icons.pause_circle;
        break;
      case 'error':
        color = Colors.red;
        icon = Icons.error;
        break;
      case 'expired':
        color = Colors.grey;
        icon = Icons.schedule;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }

    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color.withValues(alpha: 0.3)),
    );
  }

  Widget _buildActionMenu(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit(subscription);
            break;
          case 'pause':
            onPause(subscription);
            break;
          case 'resume':
            onResume(subscription);
            break;
          case 'delete':
            onDelete(subscription);
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit),
              SizedBox(width: 8),
              Text('Edit'),
            ],
          ),
        ),
        if (subscription.status.toLowerCase() == 'active')
          const PopupMenuItem(
            value: 'pause',
            child: Row(
              children: [
                Icon(Icons.pause),
                SizedBox(width: 8),
                Text('Pause'),
              ],
            ),
          ),
        if (subscription.status.toLowerCase() == 'paused')
          const PopupMenuItem(
            value: 'resume',
            child: Row(
              children: [
                Icon(Icons.play_arrow),
                SizedBox(width: 8),
                Text('Resume'),
              ],
            ),
          ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final stats = subscription.stats!;
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            context,
            'Success Rate',
            '${(stats.successRate * 100).toStringAsFixed(1)}%',
            Icons.check_circle_outline,
            Colors.green,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            context,
            'Total',
            stats.totalNotifications.toString(),
            Icons.notifications_outlined,
            Colors.blue,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            context,
            'Failed',
            stats.failedNotifications.toString(),
            Icons.error_outline,
            Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
