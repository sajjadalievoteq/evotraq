import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/display_date_utils.dart';
import 'package:traqtrace_app/core/utils/status_visual_mappers.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/admin/monitoring_models.dart';

class IntegrityViolationCard extends StatelessWidget {
  const IntegrityViolationCard(this.violation, {super.key});

  final IntegrityViolation violation;

  @override
  Widget build(BuildContext context) {

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            TraqIcon(
              StatusVisualMappers.severityIcon(violation.severity),
              color: StatusVisualMappers.severityColor(context, violation.severity),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    violation.violationType,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    violation.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    'Event: ${violation.eventId} (${violation.eventType})',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              DisplayDateUtils.dmHm(violation.detectedAt),
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}