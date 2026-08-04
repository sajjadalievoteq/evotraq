import 'package:flutter/material.dart';

import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

class ObjectEventFormErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const ObjectEventFormErrorBanner({
    super.key,
    required this.message,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final error = AppColorMapper.errorColor(context);
    return Container(
      margin: context.horizontalPadding,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: error.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          TraqIcon(AppAssets.iconAlert, color: error),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: error),
            ),
          ),
          IconButton(
            icon: TraqIcon(AppAssets.iconX),
            onPressed: onDismiss,
            color: error,
          ),
        ],
      ),
    );
  }
}
