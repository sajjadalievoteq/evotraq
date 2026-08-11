import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class ValidationSimpleError extends StatelessWidget {
  const ValidationSimpleError({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final error = AppColorMapper.errorColor(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TraqIcon(AppAssets.iconChevronR, color: error, size: 20),
          const SizedBox(width: 4.0),
          Expanded(
            child: Text(message, style: TextStyle(color: error)),
          ),
        ],
      ),
    );
  }
}
