import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/data/models/epcis/object_event.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_detail/utils/object_event_detail_ui_constants.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_detail/widgets/object_event_detail_field.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/utils/object_event_shared_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';

class ObjectEventDetailBizContextSection extends StatelessWidget {
  const ObjectEventDetailBizContextSection({super.key, required this.event});

  final ObjectEvent event;

  @override
  Widget build(BuildContext context) {
    return Gs1GroupCard(
      title: ObjectEventDetailUiConstants.sectionBizStep,
      outlineColor: Theme.of(context).colorScheme.outlineVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ObjectEventDetailField(
            label: ObjectEventDetailUiConstants.labelBusinessStep,
            value: ObjectEventSharedUiConstants.friendlyBizStep(
              event.businessStep,
            ),
          ),
          ObjectEventDetailField(
            label: ObjectEventDetailUiConstants.labelDisposition,
            value: ObjectEventSharedUiConstants.friendlyDisposition(
              event.disposition,
            ),
          ),
          if (event.businessStep != null)
            ObjectEventDetailField(
              label: ObjectEventDetailUiConstants.labelBusinessStepUrn,
              value: event.businessStep,
              monospace: true,
            ),
          if (event.disposition != null)
            ObjectEventDetailField(
              label: ObjectEventDetailUiConstants.labelDispositionUrn,
              value: event.disposition,
              monospace: true,
            ),
          if (event.persistentDisposition?.isNotEmpty ?? false)
            ObjectEventDetailField(
              label: ObjectEventDetailUiConstants.labelPersistentDisposition,
              value: event.persistentDisposition,
            ),
          if (event.sourceList?.isNotEmpty ?? false)
            ObjectEventDetailField(
              label: ObjectEventDetailUiConstants.labelSources,
              value: event.sourceList!
                  .map((s) => '${s.type}: ${s.id}')
                  .join(', '),
            ),
          if (event.destinationList?.isNotEmpty ?? false)
            ObjectEventDetailField(
              label: ObjectEventDetailUiConstants.labelDestinations,
              value: event.destinationList!
                  .map((d) => '${d.type}: ${d.id}')
                  .join(', '),
            ),
        ],
      ),
    );
  }
}
