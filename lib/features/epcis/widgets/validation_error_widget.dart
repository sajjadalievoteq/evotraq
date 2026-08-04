import 'package:flutter/material.dart';

import '../../../../core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
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

    final error = AppColorMapper.errorColor(context);

    return Card(
      color: error.withValues(alpha: 0.1),
      margin: context.horizontalPadding,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TraqIcon(AppAssets.iconAlert, color: error),
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
            ...validationErrors.map((e) {
              if (e is Map<String, dynamic>) {
                return _buildStructuredError(context, e);
              } else if (e is String) {
                return _buildSimpleError(context, e);
              } else {
                return _buildSimpleError(context, e.toString());
              }
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleError(BuildContext context, String message) {
    final error = AppColorMapper.errorColor(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TraqIcon(AppAssets.iconChevronR, color: error, size: 20),
          const SizedBox(width: 4.0),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStructuredError(BuildContext context, Map<String, dynamic> errorMap) {
    final field = errorMap['field'] as String? ?? 'Unknown';
    final message = errorMap['message'] as String? ?? 'Invalid value';
    final error = AppColorMapper.errorColor(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TraqIcon(AppAssets.iconChevronR, color: error, size: 20),
              const SizedBox(width: 4.0),
              Text(
                field,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: error,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 28.0),
            child: Text(
              message,
              style: TextStyle(color: error),
            ),
          ),
        ],
      ),
    );
  }
}
