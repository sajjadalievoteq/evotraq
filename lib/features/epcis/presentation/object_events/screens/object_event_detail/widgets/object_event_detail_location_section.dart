import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/data/models/epcis/object_event.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_resolution.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_detail/utils/object_event_detail_ui_constants.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_detail/widgets/object_event_detail_field.dart';
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
              value: glnDisplayLabel(event.businessLocation!),
              monospace: isPlaceholderGlnLocation(event.businessLocation!) ||
                  event.businessLocation!.locationName.isEmpty,
            ),
          if (event.readPoint != null)
            ObjectEventDetailField(
              label: ObjectEventDetailUiConstants.labelReadPoint,
              value: glnDisplayLabel(event.readPoint!),
              monospace: isPlaceholderGlnLocation(event.readPoint!) ||
                  event.readPoint!.locationName.isEmpty,
            ),
        ],
      ),
    );
  }
}
