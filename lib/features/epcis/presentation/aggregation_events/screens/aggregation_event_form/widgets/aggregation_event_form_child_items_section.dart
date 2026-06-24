import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/gs1_fields/epc_entry_field.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/utils/aggregation_event_form_quantity_row_controllers.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/utils/aggregation_event_form_validators.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/utils/aggregation_pharma_rules_text.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/widgets/object_event_form_section_card.dart';

class AggregationEventFormChildItemsSection extends StatelessWidget {
  const AggregationEventFormChildItemsSection({
    super.key,
    required this.selectedAction,
    required this.useQuantityList,
    required this.onUseQuantityListChanged,
    required this.childEpcControllers,
    required this.onAddChildEpc,
    required this.onRemoveChildEpc,
    required this.onScanAndAddChildEpc,
    required this.quantityRows,
    required this.onAddQuantityRow,
    required this.onRemoveQuantityRow,
  });

  final String selectedAction;
  final bool useQuantityList;
  final ValueChanged<bool> onUseQuantityListChanged;
  final List<TextEditingController> childEpcControllers;
  final VoidCallback onAddChildEpc;
  final ValueChanged<int> onRemoveChildEpc;
  final VoidCallback onScanAndAddChildEpc;
  final List<AggregationEventFormQuantityRowControllers> quantityRows;
  final VoidCallback onAddQuantityRow;
  final void Function(int index, AggregationEventFormQuantityRowControllers row)
      onRemoveQuantityRow;

  @override
  Widget build(BuildContext context) {
    return ObjectEventFormSectionCard(
      title: 'Items',
      showTitleRequiredIndicator: selectedAction != 'DELETE',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Use class-level quantities'),
            subtitle: const Text(
              'childQuantityList (EPC class + quantity) instead of instance-level item EPCs',
            ),
            value: useQuantityList,
            onChanged: onUseQuantityListChanged,
          ),
          const SizedBox(height: 8),
          if (!useQuantityList) ...[
            ...childEpcControllers.asMap().entries.map((entry) {
              final index = entry.key;
              final ctrl = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: EpcEntryField(
                        controller: ctrl,
                        label: selectedAction == 'DELETE'
                            ? 'Item EPC ${index + 1} (optional)'
                            : 'Item EPC ${index + 1} *',
                        fieldName: 'childEpc_$index',
                        required: selectedAction != 'DELETE',
                        hintText: 'SGTIN URN or (01)…(21)… barcode',
                        helperText: index == 0
                            ? (selectedAction == 'DELETE'
                                ? 'Leave empty to unpack all items'
                                : AggregationPharmaRulesText.childEpcsHint)
                            : null,
                      ),
                    ),
                    if (childEpcControllers.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: IconButton(
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            color: Colors.red,
                            size: 20,
                          ),
                          tooltip: 'Remove EPC',
                          onPressed: () => onRemoveChildEpc(index),
                        ),
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 4),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: onAddChildEpc,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add EPC'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: onScanAndAddChildEpc,
                  icon: const Icon(Icons.qr_code_scanner, size: 18),
                  label: const Text('Scan & Add'),
                ),
              ],
            ),
          ] else ...[
            ...quantityRows.asMap().entries.map((entry) {
              final index = entry.key;
              final row = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Quantity #${index + 1}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          if (quantityRows.length > 1)
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 20,
                              ),
                              onPressed: () => onRemoveQuantityRow(index, row),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: row.epcClass,
                        decoration: const InputDecoration(
                          labelText: 'EPC class *',
                          hintText: 'urn:epc:idpat:sgtin:….*',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        validator: selectedAction == 'DELETE'
                            ? null
                            : AggregationEventFormValidators.validateEpcClass,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: row.quantity,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Quantity *',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              validator: selectedAction == 'DELETE'
                                  ? null
                                  : AggregationEventFormValidators.validateQuantity,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: row.uom,
                              decoration: const InputDecoration(
                                labelText: 'UoM',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            TextButton.icon(
              onPressed: onAddQuantityRow,
              icon: const Icon(Icons.add),
              label: const Text('Add quantity row'),
            ),
          ],
        ],
      ),
    );
  }
}
