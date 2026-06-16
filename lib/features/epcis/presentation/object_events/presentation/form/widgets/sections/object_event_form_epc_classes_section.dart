import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/object_event_form_add_to_list_section.dart';

class ObjectEventFormEpcClassesSection extends StatefulWidget {
  final List<String> epcClassList;
  final bool isViewOnly;
  final ValueChanged<List<String>> onChanged;

  const ObjectEventFormEpcClassesSection({
    super.key,
    required this.epcClassList,
    required this.isViewOnly,
    required this.onChanged,
  });

  @override
  State<ObjectEventFormEpcClassesSection> createState() =>
      _ObjectEventFormEpcClassesSectionState();
}

class _ObjectEventFormEpcClassesSectionState
    extends State<ObjectEventFormEpcClassesSection> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addEpcClass() {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    widget.onChanged([...widget.epcClassList, value]);
    _controller.clear();
  }

  void _remove(int index) {
    final updated = List<String>.from(widget.epcClassList)..removeAt(index);
    widget.onChanged(updated);
  }

  void _clearAll() => widget.onChanged([]);

  @override
  Widget build(BuildContext context) {
    return ObjectEventFormAddToListSection(
      title: 'EPC Classes (if not using EPCs)',
      listLabel: 'EPC Classes',
      itemCount: widget.epcClassList.length,
      isViewOnly: widget.isViewOnly,
      emptyMessage: widget.isViewOnly
          ? 'No EPC classes recorded.'
          : 'No EPC classes added yet. Enter a value above and press Add.',
      inputArea: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: 'EPC Class',
          hintText: 'urn:epc:idpat:sgtin:CompanyPrefix.ItemReference.*',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (_) => _addEpcClass(),
      ),
      onAdd: _addEpcClass,
      onClearAll: _clearAll,
      items: List.generate(widget.epcClassList.length, (index) {
        final epcClass = widget.epcClassList[index];
        return ObjectEventFormListItemData(
          title: epcClass,
          onRemove: widget.isViewOnly ? null : () => _remove(index),
        );
      }),
    );
  }
}
