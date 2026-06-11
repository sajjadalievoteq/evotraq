import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/object_event_form_string_list_section.dart';

class ObjectEventFormEpcClassesSection extends StatelessWidget {
  final List<String> epcClassList;
  final bool isViewOnly;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  const ObjectEventFormEpcClassesSection({
    super.key,
    required this.epcClassList,
    required this.isViewOnly,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ObjectEventFormEditableStringListSection(
      title: 'EPC Classes (if not using EPCs)',
      emptyMessage:
          'No EPC classes added. Add EPC classes for class-level identification.',
      items: epcClassList,
      isViewOnly: isViewOnly,
      onRemove: onRemove,
      headerActions: isViewOnly
          ? null
          : [
              IconButton(
                icon: const Icon(Icons.add_circle),
                onPressed: onAdd,
                tooltip: 'Add EPC Class',
              ),
            ],
    );
  }
}
