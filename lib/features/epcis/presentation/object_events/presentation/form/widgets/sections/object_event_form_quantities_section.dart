import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_types.dart' as types;
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/object_event_form_section_card.dart';

class ObjectEventFormQuantitiesSection extends StatelessWidget {
  final List<types.QuantityElement> quantityList;
  final bool isViewOnly;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  const ObjectEventFormQuantitiesSection({
    super.key,
    required this.quantityList,
    required this.isViewOnly,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ObjectEventFormSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Quantities',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
              ),
              if (!isViewOnly)
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  onPressed: onAdd,
                  tooltip: 'Add Quantity',
                ),
            ],
          ),
          const SizedBox(height: 8.0),
          if (quantityList.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'No quantities added. Add quantities for class-level identification with amount.',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: quantityList.length,
              itemBuilder: (context, index) {
                final quantity = quantityList[index];
                return ListTile(
                  title: Text('${quantity.quantity} ${quantity.uom ?? ""}'),
                  subtitle: Text('EPC Class: ${quantity.epcClass}'),
                  trailing: isViewOnly
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => onRemove(index),
                        ),
                );
              },
            ),
        ],
      ),
    );
  }
}
