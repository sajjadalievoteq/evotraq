import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/gln_selector.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/utils/aggregation_pharma_rules_text.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/widgets/object_event_form_section_card.dart';

class AggregationEventFormLocationSection extends StatelessWidget {
  const AggregationEventFormLocationSection({
    super.key,
    required this.locationGLN,
    required this.locationGlnError,
    required this.onLocationChanged,
  });

  final GLN? locationGLN;
  final String? locationGlnError;
  final ValueChanged<GLN?> onLocationChanged;

  @override
  Widget build(BuildContext context) {
    return ObjectEventFormSectionCard(
      title: 'Location',
      showTitleRequiredIndicator: true,
      child: GLNSelector(
        label: 'GLN',
        hintText: AggregationPharmaRulesText.locationHint,
        initialValue: locationGLN,
        isRequired: true,
        errorText: locationGlnError,
        onChanged: onLocationChanged,
      ),
    );
  }
}
