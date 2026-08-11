import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class ValidationStructuredError extends StatelessWidget {
  const ValidationStructuredError({super.key, required this.errorMap});

  final Map<String, dynamic> errorMap;

  @override
  Widget build(BuildContext context) {
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
                style: TextStyle(fontWeight: FontWeight.bold, color: error),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 28.0),
            child: Text(message, style: TextStyle(color: error)),
          ),
        ],
      ),
    );
  }
}
