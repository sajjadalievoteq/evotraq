import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/sgtin/utils/sgtin_ui_constants.dart';

import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

class SgtinDetailAwaitingSelection extends StatelessWidget {
  const SgtinDetailAwaitingSelection({
    super.key,
    required this.embedded,
  });

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final body = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TraqIcon(
            AppAssets.iconTarget,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            SgtinUiConstants.awaitingSelectionTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            SgtinUiConstants.awaitingSelectionSubtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    return embedded ? body : Scaffold(body: body);
  }
}
