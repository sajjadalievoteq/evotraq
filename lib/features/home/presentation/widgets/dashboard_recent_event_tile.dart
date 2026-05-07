import 'package:flutter/material.dart';

class DashboardRecentEventTile extends StatelessWidget {
  const DashboardRecentEventTile({super.key, required this.event});

  final dynamic event;

  @override
  Widget build(BuildContext context) {
    final timeAgo = _formatTimeAgo(event.eventTime as DateTime);

    IconData eventIcon;
    Color eventColor;

    switch ((event.eventType as String).toLowerCase()) {
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
        event.eventType as String,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        (event.action as String).isNotEmpty
            ? event.action as String
            : ((event.bizStep as String?) ?? 'No details'),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        timeAgo,
        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
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

