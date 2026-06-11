import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/utilities/detail/object_event_detail_ui_constants.dart';

class ObjectEventDetailAwaitingPane extends StatelessWidget {
  const ObjectEventDetailAwaitingPane({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_note_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            ObjectEventDetailUiConstants.detailAwaitingSelection,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            ObjectEventDetailUiConstants.detailAwaitingHint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
