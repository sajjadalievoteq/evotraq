import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/epcis/utils/epcis_event_ui_utils.dart';

class IntegrityEventTypeRow extends StatelessWidget {
  const IntegrityEventTypeRow(
    this.eventType,
    this.integrityCount, {
    super.key,
  });

  final String eventType;
  final int integrityCount;

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: EpcisEventUiUtils.eventTypeColor(context, eventType),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
            child: Text(
              eventType,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const Spacer(),
          Text(
            '$integrityCount events',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}