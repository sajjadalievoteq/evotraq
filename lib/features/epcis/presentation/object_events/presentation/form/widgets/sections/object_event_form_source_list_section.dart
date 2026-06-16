import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_types.dart' as types;
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/utilities/object_event_form_source_destination_types.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/utilities/object_event_form_mandatory_fields.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/object_event_form_add_to_list_section.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/object_event_form_required_indicator.dart';

class ObjectEventFormSourceListSection extends StatefulWidget {
  final List<types.SourceDestination> sourceList;
  final bool isViewOnly;
  final ValueChanged<List<types.SourceDestination>> onChanged;

  const ObjectEventFormSourceListSection({
    super.key,
    required this.sourceList,
    required this.isViewOnly,
    required this.onChanged,
  });

  @override
  State<ObjectEventFormSourceListSection> createState() =>
      _ObjectEventFormSourceListSectionState();
}

class _ObjectEventFormSourceListSectionState
    extends State<ObjectEventFormSourceListSection> {
  String _type = 'owning_party';
  final _idController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  void _addSource() {
    final id = _idController.text.trim();
    if (id.isEmpty) return;
    widget.onChanged([
      ...widget.sourceList,
      types.SourceDestination(type: _type, id: id),
    ]);
    _idController.clear();
  }

  void _remove(int index) {
    final updated = List<types.SourceDestination>.from(widget.sourceList)
      ..removeAt(index);
    widget.onChanged(updated);
  }

  void _clearAll() => widget.onChanged([]);

  @override
  Widget build(BuildContext context) {
    return ObjectEventFormAddToListSection(
      title: 'Source List (EPCIS 2.0)',
      requiredFieldNames: ObjectEventFormMandatoryFields.sourceListFields,
      listLabel: 'Sources',
      itemCount: widget.sourceList.length,
      isViewOnly: widget.isViewOnly,
      emptyMessage: widget.isViewOnly
          ? 'No sources recorded.'
          : 'No sources added yet. Fill in the fields above and press Add.',
      inputArea: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _type,
            decoration: InputDecoration(
              label: objectEventFormFieldLabel(context, 'Source Type', true),
              border: const OutlineInputBorder(),
            ),
            items: objectEventFormSourceDestinationTypes
                .map(
                  (entry) => DropdownMenuItem(
                    value: entry.$1,
                    child: Text(entry.$2),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _type = value);
            },
          ),
          const SizedBox(height: 8.0),
          TextField(
            controller: _idController,
            decoration: InputDecoration(
              label: objectEventFormFieldLabel(context, 'GLN or Identifier', true),
              hintText: 'e.g., 0614141000005',
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (_) => _addSource(),
          ),
        ],
      ),
      onAdd: _addSource,
      onClearAll: _clearAll,
      items: List.generate(widget.sourceList.length, (index) {
        final source = widget.sourceList[index];
        return ObjectEventFormListItemData(
          title: objectEventFormSourceDestinationLabel(source.type),
          subtitle: source.id,
          onRemove: widget.isViewOnly ? null : () => _remove(index),
        );
      }),
    );
  }
}
