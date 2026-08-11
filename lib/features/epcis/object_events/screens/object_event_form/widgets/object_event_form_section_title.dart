import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/widgets/object_event_form_required_mark.dart';

class ObjectEventFormSectionTitle extends StatelessWidget {
  const ObjectEventFormSectionTitle({
    super.key,
    required this.title,
    this.showRequiredIndicator = false,
  });
  final String title;
  final bool showRequiredIndicator;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        if (showRequiredIndicator) const ObjectEventFormRequiredIndicator(),
      ],
    );
  }
}
