import 'package:flutter/material.dart';

import '../../../../core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

class ValidationErrorWidget extends StatelessWidget {
  final List<dynamic> validationErrors;
  
  final String? title;
  
  final VoidCallback? onDismiss;

  const ValidationErrorWidget({
    Key? key,
    required this.validationErrors,
    this.title,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (validationErrors.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      color: Colors.red[50],
      margin:      context.horizontalPadding,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TraqIcon(AppAssets.iconAlert, color: Colors.red),
                const SizedBox(width: 8.0),
                Text(
                  title ?? 'Validation Errors',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                const Spacer(),
                if (onDismiss != null)
                  IconButton(
                    icon: TraqIcon(AppAssets.iconX),
                    onPressed: onDismiss,
                    tooltip: 'Dismiss',
                  ),
              ],
            ),
            const Divider(),
            ...validationErrors.map((error) {
              if (error is Map<String, dynamic>) {
                return _buildStructuredError(error);
              } else if (error is String) {
                return _buildSimpleError(error);
              } else {
                return _buildSimpleError(error.toString());
              }
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleError(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TraqIcon(AppAssets.iconChevronR, color: Colors.red, size: 20),
          const SizedBox(width: 4.0),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStructuredError(Map<String, dynamic> error) {
    final field = error['field'] as String? ?? 'Unknown';
    final message = error['message'] as String? ?? 'Invalid value';
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TraqIcon(AppAssets.iconChevronR, color: Colors.red, size: 20),
              const SizedBox(width: 4.0),
              Text(
                field,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 28.0),
            child: Text(
              message,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
