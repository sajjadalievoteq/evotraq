import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class HelpExampleCard extends StatelessWidget {
  const HelpExampleCard({
    super.key,
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final info = AppColorMapper.infoColor(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColorMapper.infoSoft(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: info.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TraqIcon(AppAssets.iconLightbulb, color: info, size: 16),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, color: info),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(description, style: TextStyle(color: info, height: 1.3)),
        ],
      ),
    );
  }
}
