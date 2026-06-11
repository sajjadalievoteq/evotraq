import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/utilities/detail/object_event_detail_ui_constants.dart';

class ObjectEventDetailNotFoundPane extends StatelessWidget {
  const ObjectEventDetailNotFoundPane({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(ObjectEventDetailUiConstants.detailNotFound),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: onRetry,
            child: const Text(ObjectEventDetailUiConstants.detailRetry),
          ),
        ],
      ),
    );
  }
}
