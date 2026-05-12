import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/services/dashboard_service.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';

class DashboardRecentEventTile extends StatelessWidget {
  const DashboardRecentEventTile({super.key, required this.event});

  final RecentEvent event;

  @override
  Widget build(BuildContext context) {
    final timeAgo = _formatTimeAgo(event.eventTime);

    IconData eventIcon;
    Color eventColor;

    switch (event.eventType.toLowerCase()) {
      case 'objectevent':
        eventIcon = Icons.inventory_2;
        eventColor = Colors.blue;
        break;
      case 'aggregationevent':
        eventIcon = Icons.category;
        eventColor = Colors.green;
        break;
      case 'transactionevent':
        eventIcon = Icons.receipt;
        eventColor = Colors.orange;
        break;
      case 'transformationevent':
        eventIcon = Icons.transform;
        eventColor = Colors.purple;
        break;
      default:
        eventIcon = Icons.event;
        eventColor = Colors.grey;
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: eventColor.withOpacity(0.1),
        child: Icon(eventIcon, color: eventColor, size: 20),
      ),
      title: Text(
        event.eventType,
        style: context.text.body.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        event.action.isNotEmpty
            ? event.action
            : (event.bizStep ?? 'No details'),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.text.bodySm.copyWith(color: context.colors.textSecondary),
      ),
      trailing: Text(
        timeAgo,
        style: context.text.bodySm.copyWith(
          fontSize: 11,
          color: context.colors.textMuted,
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    }
    return 'Just now';
  }
}
