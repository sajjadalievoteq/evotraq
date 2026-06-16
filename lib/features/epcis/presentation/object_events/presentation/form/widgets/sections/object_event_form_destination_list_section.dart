import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_types.dart' as types;
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/utilities/object_event_form_source_destination_types.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/utilities/object_event_form_mandatory_fields.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/object_event_form_add_to_list_section.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/object_event_form_required_indicator.dart';

class ObjectEventFormDestinationListSection extends StatefulWidget {
  final List<types.SourceDestination> destinationList;
  final bool isViewOnly;
  final String? action;
  final String? businessStep;
  final bool epcListEmpty;
  final bool quantityListEmpty;
  final List<String> epcList;
  final ValueChanged<List<types.SourceDestination>> onChanged;

  const ObjectEventFormDestinationListSection({
    super.key,
    required this.destinationList,
    required this.isViewOnly,
    this.action,
    this.businessStep,
    this.epcListEmpty = false,
    this.quantityListEmpty = false,
    this.epcList = const [],
    required this.onChanged,
  });

  @override
  State<ObjectEventFormDestinationListSection> createState() =>
      _ObjectEventFormDestinationListSectionState();
}

class _ObjectEventFormDestinationListSectionState
    extends State<ObjectEventFormDestinationListSection> {
  String _type = 'owning_party';
  final _idController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  void _addDestination() {
    final id = _idController.text.trim();
    if (id.isEmpty) return;
    widget.onChanged([
      ...widget.destinationList,
      types.SourceDestination(type: _type, id: id),
    ]);
    _idController.clear();
  }

  void _remove(int index) {
    final updated = List<types.SourceDestination>.from(widget.destinationList)
      ..removeAt(index);
    widget.onChanged(updated);
  }

  void _clearAll() => widget.onChanged([]);

  @override
  Widget build(BuildContext context) {
    return ObjectEventFormAddToListSection(
      title: 'Destination List (EPCIS 2.0)',
      requiredFieldNames: [
        ...ObjectEventFormMandatoryFields.destinationListFields,
        'destinationList',
      ],
      action: widget.action,
      businessStep: widget.businessStep,
      epcListEmpty: widget.epcListEmpty,
      quantityListEmpty: widget.quantityListEmpty,
      epcList: widget.epcList,
      listLabel: 'Destinations',
      itemCount: widget.destinationList.length,
      isViewOnly: widget.isViewOnly,
      emptyMessage: widget.isViewOnly
          ? 'No destinations recorded.'
          : 'No destinations added yet. Fill in the fields above and press Add.',
      inputArea: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _type,
            decoration: InputDecoration(
              label: objectEventFormFieldLabel(context, 'Destination Type', true),
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
            onSubmitted: (_) => _addDestination(),
          ),
        ],
      ),
      onAdd: _addDestination,
      onClearAll: _clearAll,
      items: List.generate(widget.destinationList.length, (index) {
        final destination = widget.destinationList[index];
        return ObjectEventFormListItemData(
          title: objectEventFormSourceDestinationLabel(destination.type),
          subtitle: destination.id,
          onRemove: widget.isViewOnly ? null : () => _remove(index),
        );
      }),
    );
  }
}
