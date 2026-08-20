import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/widgets/object_event_form_required_indicator.dart';

class ObjectEventFormFieldLabel extends StatelessWidget {
  const ObjectEventFormFieldLabel({
    super.key,
    required this.label,
    required this.isMandatory,
  });
  final String label;
  final bool isMandatory;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        if (isMandatory) const ObjectEventFormRequiredIndicator(),
      ],
    );
  }
}
