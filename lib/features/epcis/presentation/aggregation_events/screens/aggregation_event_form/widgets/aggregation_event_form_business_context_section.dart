import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_event.dart' as epcis_models;
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/widgets/aggregation_cbv_picker.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/widgets/object_event_form_section_card.dart';

class AggregationEventFormBusinessContextSection extends StatelessWidget {
  const AggregationEventFormBusinessContextSection({
    super.key,
    required this.action,
    required this.businessStep,
    required this.disposition,
    required this.onBizStepChanged,
    required this.onDispositionChanged,
  });

  final String? action;
  final String? businessStep;
  final String? disposition;
  final ValueChanged<String?> onBizStepChanged;
  final ValueChanged<String?> onDispositionChanged;

  @override
  Widget build(BuildContext context) {
    return ObjectEventFormSectionCard(
      title: 'Business Context',
      showTitleRequiredIndicator: true,
      child: AggregationCbvPicker(
        action: action,
        initialBizStep: businessStep,
        initialDisposition: disposition,
        epcisVersion: epcis_models.EPCISVersion.v2_0,
        onBizStepChanged: onBizStepChanged,
        onDispositionChanged: onDispositionChanged,
      ),
    );
  }
}
