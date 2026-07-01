import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_detail/utils/object_event_detail_ui_constants.dart';

import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

class ObjectEventDetailNotFoundPane extends StatelessWidget {
  const ObjectEventDetailNotFoundPane({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TraqIcon(
            AppAssets.iconSearch,
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
