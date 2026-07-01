import 'package:flutter/material.dart';

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
    return Container(
      margin:   context.horizontalPadding,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          TraqIcon(AppAssets.iconAlert, color: Colors.red.shade700),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
          IconButton(
            icon: TraqIcon(AppAssets.iconX),
            onPressed: onDismiss,
            color: Colors.red.shade700,
          ),
        ],
      ),
    );
  }
}
