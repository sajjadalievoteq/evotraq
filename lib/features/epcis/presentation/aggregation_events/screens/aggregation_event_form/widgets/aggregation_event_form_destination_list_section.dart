import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/widgets/object_event_form_section_card.dart';

class AggregationEventFormDestinationListSection extends StatelessWidget {
  const AggregationEventFormDestinationListSection({
    super.key,
    required this.destinationListControllers,
    required this.onAddDestinationEntry,
    required this.onRemoveDestinationEntry,
  });

  final List<MapEntry<TextEditingController, TextEditingController>>
      destinationListControllers;
  final VoidCallback onAddDestinationEntry;
  final ValueChanged<int> onRemoveDestinationEntry;

  @override
  Widget build(BuildContext context) {
    return ObjectEventFormSectionCard(
      title: 'Destination List',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (destinationListControllers.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No destinations added. Tap "Add Destination" to specify where products are going.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontStyle: FontStyle.italic),
              ),
            ),
          ...destinationListControllers.asMap().entries.map((entry) {
            final index = entry.key;
            final controllers = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Destination #${index + 1}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 20,
                          ),
                          onPressed: () => onRemoveDestinationEntry(index),
                          tooltip: 'Remove',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Destination Type *',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      value: controllers.key.text.isNotEmpty
                          ? controllers.key.text
                          : null,
                      items: ['owning_party', 'possessing_party', 'location']
                          .map(
                            (t) => DropdownMenuItem(value: t, child: Text(t)),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) controllers.key.text = v;
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: controllers.value,
                      decoration: const InputDecoration(
                        labelText: 'Destination Value *',
                        hintText: 'urn:epc:id:sgln:… or GLN',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      validator: (value) {
                        if (controllers.key.text.isNotEmpty &&
                            (value == null || value.isEmpty)) {
                          return 'Destination value is required';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onAddDestinationEntry,
            icon: const Icon(Icons.add),
            label: const Text('Add Destination'),
          ),
        ],
      ),
    );
  }
}
