import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/data/models/epcis/object_event.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/utilities/detail/object_event_detail_ui_constants.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/widgets/detail/object_event_detail_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';

class ObjectEventDetailLocationSection extends StatelessWidget {
  const ObjectEventDetailLocationSection({super.key, required this.event});

  final ObjectEvent event;

  @override
  Widget build(BuildContext context) {
    final hasLocation =
        event.businessLocation != null || event.readPoint != null;
    if (!hasLocation) return const SizedBox.shrink();

    return Gs1GroupCard(
      title: ObjectEventDetailUiConstants.sectionLocation,
      outlineColor: Theme.of(context).colorScheme.outlineVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (event.businessLocation != null)
            ObjectEventDetailField(
              label: ObjectEventDetailUiConstants.labelBusinessLocation,
              value: event.businessLocation!.locationName.isNotEmpty
                  ? event.businessLocation!.locationName
                  : event.businessLocation!.glnCode,
              monospace: event.businessLocation!.locationName.isEmpty,
            ),
          if (event.readPoint != null)
            ObjectEventDetailField(
              label: ObjectEventDetailUiConstants.labelReadPoint,
              value: event.readPoint!.locationName.isNotEmpty
                  ? event.readPoint!.locationName
                  : event.readPoint!.glnCode,
              monospace: event.readPoint!.locationName.isEmpty,
            ),
        ],
      ),
    );
  }
}
