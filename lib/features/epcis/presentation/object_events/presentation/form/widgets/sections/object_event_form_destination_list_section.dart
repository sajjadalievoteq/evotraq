import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_types.dart' as types;
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/object_event_form_section_card.dart';

class ObjectEventFormDestinationListSection extends StatelessWidget {
  final List<types.SourceDestination> destinationList;
  final bool isViewOnly;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  const ObjectEventFormDestinationListSection({
    super.key,
    required this.destinationList,
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
                'Destination List (EPCIS 2.0)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
              ),
              if (!isViewOnly)
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  onPressed: onAdd,
                  tooltip: 'Add Destination',
                ),
            ],
          ),
          const SizedBox(height: 8.0),
          if (destinationList.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'No destinations added. Destinations identify where products are going in the supply chain.',
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
              itemCount: destinationList.length,
              itemBuilder: (context, index) {
                final destination = destinationList[index];
                return ListTile(
                  title: Text(
                    destination.type.replaceAll('_', ' ').toUpperCase(),
                  ),
                  subtitle: Text('ID: ${destination.id}'),
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
