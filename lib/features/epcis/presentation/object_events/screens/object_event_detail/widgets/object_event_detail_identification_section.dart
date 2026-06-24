import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/data/models/epcis/object_event.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_detail/utils/object_event_detail_formatters.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_detail/utils/object_event_detail_ui_constants.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_detail/widgets/object_event_detail_field.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/widgets/object_event_action_chip.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';

class ObjectEventDetailIdentificationSection extends StatelessWidget {
  const ObjectEventDetailIdentificationSection({super.key, required this.event});

  final ObjectEvent event;

  @override
  Widget build(BuildContext context) {
    return Gs1GroupCard(
      title: ObjectEventDetailUiConstants.sectionIdentification,
      outlineColor: Theme.of(context).colorScheme.outlineVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ObjectEventDetailField(
                  label: ObjectEventDetailUiConstants.labelEventId,
                  value: event.eventId,
                  monospace: true,
                ),
              ),
              const SizedBox(width: 12),
              ObjectEventActionChip(action: event.action),
            ],
          ),
          if (event.id != null)
            ObjectEventDetailField(
              label: ObjectEventDetailUiConstants.labelDatabaseId,
              value: event.id,
            ),
          ObjectEventDetailField(
            label: ObjectEventDetailUiConstants.labelEpcisVersion,
            value: ObjectEventDetailFormatters.epcisVersionLabel(
              event.epcisVersion,
            ),
          ),
          ObjectEventDetailField(
            label: ObjectEventDetailUiConstants.labelEventTime,
            value: ObjectEventDetailFormatters.formatDate(event.eventTime),
          ),
          ObjectEventDetailField(
            label: ObjectEventDetailUiConstants.labelRecordTime,
            value: ObjectEventDetailFormatters.formatDate(event.recordTime),
          ),
          ObjectEventDetailField(
            label: ObjectEventDetailUiConstants.labelTimeZone,
            value: event.eventTimeZone,
          ),
          if (event.createdAt != null)
            ObjectEventDetailField(
              label: ObjectEventDetailUiConstants.labelCreatedAt,
              value: ObjectEventDetailFormatters.formatDate(event.createdAt),
            ),
          if (event.eventHash != null && event.eventHash!.isNotEmpty)
            ObjectEventDetailField(
              label: ObjectEventDetailUiConstants.labelEventHash,
              value: event.eventHash,
              monospace: true,
            ),
        ],
      ),
    );
  }
}
