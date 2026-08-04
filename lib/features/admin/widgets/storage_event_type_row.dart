import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/epcis/utils/epcis_event_ui_utils.dart';

class StorageEventTypeRow extends StatelessWidget {
  const StorageEventTypeRow(
    this.eventType,
    this.percentage, {
    super.key,
  });

  final String eventType;
  final double percentage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              eventType,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation(
                EpcisEventUiUtils.eventTypeColor(context, eventType),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('${percentage.toStringAsFixed(1)}%'),
        ],
      ),
    );
  }
}
