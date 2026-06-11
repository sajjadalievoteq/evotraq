import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/object_event_form_string_list_section.dart';

class ObjectEventFormEpcsSection extends StatelessWidget {
  final List<String> epcList;
  final bool isViewOnly;
  final VoidCallback onAdd;
  final VoidCallback onBulkAdd;
  final VoidCallback onGenerate;
  final ValueChanged<int> onRemove;

  const ObjectEventFormEpcsSection({
    super.key,
    required this.epcList,
    required this.isViewOnly,
    required this.onAdd,
    required this.onBulkAdd,
    required this.onGenerate,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ObjectEventFormEditableStringListSection(
      title:
          'EPCs (Serialized Items - at least one object identifier required)',
      emptyMessage:
          'No EPCs added. Add at least one EPC for single items.',
      items: epcList,
      isViewOnly: isViewOnly,
      onRemove: onRemove,
      headerActions: isViewOnly
          ? null
          : [
              IconButton(
                icon: const Icon(Icons.add_circle),
                onPressed: onAdd,
                tooltip: 'Add EPC',
              ),
              IconButton(
                icon: const Icon(Icons.format_list_bulleted),
                onPressed: onBulkAdd,
                tooltip: 'Bulk Add EPCs',
              ),
              IconButton(
                icon: const Icon(Icons.autorenew),
                onPressed: onGenerate,
                tooltip: 'Generate EPC',
              ),
            ],
    );
  }
}
