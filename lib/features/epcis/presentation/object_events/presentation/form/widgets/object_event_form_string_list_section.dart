import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/object_event_form_section_card.dart';

/// Generic list section for string collections (EPCs, EPC classes, etc.).
class ObjectEventFormStringListSection extends StatelessWidget {
  final String title;
  final String emptyMessage;
  final List<String> items;
  final bool isViewOnly;
  final List<Widget>? headerActions;
  final VoidCallback? onAdd;

  const ObjectEventFormStringListSection({
    super.key,
    required this.title,
    required this.emptyMessage,
    required this.items,
    this.isViewOnly = false,
    this.headerActions,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return ObjectEventFormSectionCard(
      title: null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
              ),
              if (!isViewOnly && headerActions != null) ...headerActions!,
              if (!isViewOnly && onAdd != null && headerActions == null)
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  onPressed: onAdd,
                  tooltip: 'Add',
                ),
            ],
          ),
          const SizedBox(height: 8.0),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                emptyMessage,
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(items[index]),
                  trailing: isViewOnly
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            final updated = List<String>.from(items)
                              ..removeAt(index);
                            // Caller handles removal via callback pattern;
                            // use onDelete if provided via parent setState.
                          },
                        ),
                );
              },
            ),
        ],
      ),
    );
  }
}

/// String list section with explicit delete callback.
class ObjectEventFormEditableStringListSection extends StatelessWidget {
  final String title;
  final String emptyMessage;
  final List<String> items;
  final bool isViewOnly;
  final List<Widget>? headerActions;
  final ValueChanged<int> onRemove;

  const ObjectEventFormEditableStringListSection({
    super.key,
    required this.title,
    required this.emptyMessage,
    required this.items,
    required this.onRemove,
    this.isViewOnly = false,
    this.headerActions,
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
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
              ),
              if (!isViewOnly && headerActions != null) ...headerActions!,
            ],
          ),
          const SizedBox(height: 8.0),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                emptyMessage,
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(items[index]),
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
