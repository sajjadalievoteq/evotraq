import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

Future<bool> showDeleteSubscriptionDialog(
  BuildContext context, {
  required String subscriptionName,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Row(
        children: [
          TraqIcon(
            AppAssets.iconTrash,
            color: AppColorMapper.errorColor(dialogContext),
          ),
          const SizedBox(width: TraqSpacing.sm),
          const Expanded(child: Text('Delete Subscription?')),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subscriptionName,
              style: Theme.of(dialogContext).textTheme.titleMedium,
            ),
            const SizedBox(height: TraqSpacing.sm),
            const Text(
              'Event delivery will stop immediately and the subscription '
              'configuration will be permanently removed. Delivery history '
              'already recorded is not changed.',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Keep Subscription'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColorMapper.errorColor(dialogContext),
          ),
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Delete Subscription'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
