import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_event.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/object_event_form_section_card.dart';

class ObjectEventFormEpcisVersionSection extends StatelessWidget {
  final EPCISVersion epcisVersion;
  final bool isViewOnly;
  final ValueChanged<EPCISVersion> onChanged;

  const ObjectEventFormEpcisVersionSection({
    super.key,
    required this.epcisVersion,
    required this.isViewOnly,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ObjectEventFormSectionCard(
      title: 'EPCIS Version',
      child: DropdownButtonFormField<EPCISVersion>(
        value: epcisVersion,
        decoration: const InputDecoration(border: OutlineInputBorder()),
        items: EPCISVersion.values
            .map(
              (v) => DropdownMenuItem(value: v, child: Text(v.toString())),
            )
            .toList(),
        onChanged: isViewOnly ? null : (value) => onChanged(value!),
      ),
    );
  }
}
