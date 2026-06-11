import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_types.dart' as types;
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/object_event_form_section_card.dart';

class ObjectEventFormSourceListSection extends StatelessWidget {
  final List<types.SourceDestination> sourceList;
  final bool isViewOnly;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  const ObjectEventFormSourceListSection({
    super.key,
    required this.sourceList,
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
                'Source List (EPCIS 2.0)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
              ),
              if (!isViewOnly)
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  onPressed: onAdd,
                  tooltip: 'Add Source',
                ),
            ],
          ),
          const SizedBox(height: 8.0),
          if (sourceList.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'No sources added. Sources identify the origin of products in the supply chain.',
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
              itemCount: sourceList.length,
              itemBuilder: (context, index) {
                final source = sourceList[index];
                return ListTile(
                  title: Text(
                    source.type.replaceAll('_', ' ').toUpperCase(),
                  ),
                  subtitle: Text('ID: ${source.id}'),
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
