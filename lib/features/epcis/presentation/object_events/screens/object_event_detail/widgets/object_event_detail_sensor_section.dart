import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/data/models/epcis/object_event.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_detail/utils/object_event_detail_formatters.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_detail/utils/object_event_detail_ui_constants.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_detail/widgets/object_event_detail_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';

class ObjectEventDetailSensorSection extends StatelessWidget {
  const ObjectEventDetailSensorSection({super.key, required this.event});

  final ObjectEvent event;

  @override
  Widget build(BuildContext context) {
    final sensors = event.sensorElementList;
    if (sensors == null || sensors.isEmpty) return const SizedBox.shrink();

    return Gs1GroupCard(
      title: ObjectEventDetailUiConstants.sectionSensorData,
      outlineColor: Theme.of(context).colorScheme.outlineVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sensors.asMap().entries.expand((entry) {
          final sensor = entry.value;
          return [
            if (entry.key > 0) const SizedBox(height: 8),
            if (sensor.deviceId != null)
              ObjectEventDetailField(
                label: ObjectEventDetailUiConstants.labelDeviceId,
                value: sensor.deviceId,
                monospace: true,
              ),
            if (sensor.time != null)
              ObjectEventDetailField(
                label: ObjectEventDetailUiConstants.labelTime,
                value: ObjectEventDetailFormatters.formatDate(sensor.time),
              ),
            ...sensor.measurements.map(
              (m) => ObjectEventDetailField(
                label: m.type,
                value:
                    m.value?.toString() ?? m.stringValue ?? m.hexBinaryValue,
              ),
            ),
          ];
        }).toList(),
      ),
    );
  }
}
