import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

/// Error view for shipping operation detail with retry action.
class ShippingDetailErrorView extends StatelessWidget {
  const ShippingDetailErrorView({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  final String errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TraqIcon(AppAssets.iconAlert,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(errorMessage, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: TraqIcon(AppAssets.iconRefresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
