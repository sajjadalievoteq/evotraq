import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class TransformationEventFormErrorCard extends StatelessWidget {
  const TransformationEventFormErrorCard({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final error = AppColorMapper.errorColor(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        color: error.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              TraqIcon(AppAssets.iconAlert, color: error),
              const SizedBox(width: 16),
              Expanded(
                child: Text(message, style: TextStyle(color: error)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
