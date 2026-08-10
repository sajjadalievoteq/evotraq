import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class SubscriptionDeliveryTestResultDialog extends StatelessWidget {
  const SubscriptionDeliveryTestResultDialog({
    super.key,
    required this.success,
    required this.message,
  });

  final bool success;
  final String message;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          TraqIcon(
            success ? AppAssets.iconCheckCircle : AppAssets.iconXCircle,
            color: success
                ? AppColorMapper.successColor(context)
                : AppColorMapper.errorColor(context),
          ),
          const SizedBox(width: TraqSpacing.sm),
          Expanded(
            child: Text(
              success ? 'Delivery Test Passed' : 'Delivery Test Failed',
            ),
          ),
        ],
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
