import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';

class TransformationEventFormSectionHeader extends StatelessWidget {
  const TransformationEventFormSectionHeader({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColorMapper.eventTypeColor(
            context,
            'transformation',
            scheme: AppEventColorScheme.epcis,
          ),
        ),
      ),
    );
  }
}
