import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_types.dart' as types;
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/utilities/object_event_form_mandatory_fields.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/object_event_form_add_to_list_section.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/object_event_form_required_indicator.dart';

class ObjectEventFormQuantitiesSection extends StatefulWidget {
  final List<types.QuantityElement> quantityList;
  final bool isViewOnly;
  final String? action;
  final String? businessStep;
  final bool epcListEmpty;
  final ValueChanged<List<types.QuantityElement>> onChanged;

  const ObjectEventFormQuantitiesSection({
    super.key,
    required this.quantityList,
    required this.isViewOnly,
    this.action,
    this.businessStep,
    this.epcListEmpty = false,
    required this.onChanged,
  });

  @override
  State<ObjectEventFormQuantitiesSection> createState() =>
      _ObjectEventFormQuantitiesSectionState();
}

class _ObjectEventFormQuantitiesSectionState
    extends State<ObjectEventFormQuantitiesSection> {
  final _epcClassController = TextEditingController();
  final _quantityController = TextEditingController();
  final _uomController = TextEditingController();

  @override
  void dispose() {
    _epcClassController.dispose();
    _quantityController.dispose();
    _uomController.dispose();
    super.dispose();
  }

  void _addQuantity() {
    final epcClass = _epcClassController.text.trim();
    final quantity = double.tryParse(_quantityController.text.trim()) ?? 0;
    final uom = _uomController.text.trim();
    if (epcClass.isEmpty || quantity <= 0) return;

    widget.onChanged([
      ...widget.quantityList,
      types.QuantityElement(
        epcClass: epcClass,
        quantity: quantity,
        uom: uom.isEmpty ? null : uom,
      ),
    ]);
    _epcClassController.clear();
    _quantityController.clear();
    _uomController.clear();
  }

  void _remove(int index) {
    final updated = List<types.QuantityElement>.from(widget.quantityList)
      ..removeAt(index);
    widget.onChanged(updated);
  }

  void _clearAll() => widget.onChanged([]);

  @override
  Widget build(BuildContext context) {
    return ObjectEventFormAddToListSection(
      title: 'Quantities',
      requiredFieldNames: [
        ...ObjectEventFormMandatoryFields.quantityEntryFields,
        'epcList',
        'quantityList',
      ],
      action: widget.action,
      businessStep: widget.businessStep,
      epcListEmpty: widget.epcListEmpty,
      quantityListEmpty: widget.quantityList.isEmpty,
      epcList: const [],
      listLabel: 'Quantities',
      itemCount: widget.quantityList.length,
      isViewOnly: widget.isViewOnly,
      emptyMessage: widget.isViewOnly
          ? 'No quantities recorded.'
          : 'No quantities added yet. Fill in the fields above and press Add.',
      inputArea: Column(
        children: [
          TextField(
            controller: _epcClassController,
            decoration: InputDecoration(
              label: objectEventFormFieldLabel(context, 'EPC Class', true),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _quantityController,
                  decoration: InputDecoration(
                    label: objectEventFormFieldLabel(context, 'Quantity', true),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: TextField(
                  controller: _uomController,
                  decoration: const InputDecoration(
                    labelText: 'Unit of Measure',
                    hintText: 'KGM, EA, CS',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      onAdd: _addQuantity,
      onClearAll: _clearAll,
      items: List.generate(widget.quantityList.length, (index) {
        final quantity = widget.quantityList[index];
        return ObjectEventFormListItemData(
          title: '${quantity.quantity} ${quantity.uom ?? ''}'.trim(),
          subtitle: 'EPC Class: ${quantity.epcClass}',
          onRemove: widget.isViewOnly ? null : () => _remove(index),
        );
      }),
    );
  }
}
