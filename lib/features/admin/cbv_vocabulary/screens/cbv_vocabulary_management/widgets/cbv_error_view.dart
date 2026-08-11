import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class CbvErrorView extends StatelessWidget {
  const CbvErrorView({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: TraqSpacing.pagePad,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TraqIcon(
              AppAssets.iconAlert,
              size: 64,
              color: context.colors.error,
            ),
            const SizedBox(height: TraqSpacing.lg),
            Text('Failed to load CBV vocabulary', style: context.text.h3),
            const SizedBox(height: TraqSpacing.sm),
            Text(
              message,
              style: context.text.bodySm.copyWith(
                color: context.colors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TraqSpacing.xl),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const TraqIcon(AppAssets.iconRefresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
