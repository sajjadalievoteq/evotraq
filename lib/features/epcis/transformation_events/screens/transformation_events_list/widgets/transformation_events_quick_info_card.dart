import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class TransformationEventsQuickInfoCard extends StatelessWidget {
  const TransformationEventsQuickInfoCard({
    super.key,
    required this.onLearnMore,
  });

  final VoidCallback onLearnMore;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TraqIcon(
                  AppAssets.iconTransform,
                  color: AppColorMapper.eventTypeColor(
                    context,
                    'transformation',
                    scheme: AppEventColorScheme.epcis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'GS1 Transformation Events',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Track product transformations such as manufacturing, repackaging, or assembly processes.',
            ),
            const SizedBox(height: 4),
            TextButton(onPressed: onLearnMore, child: const Text('Learn More')),
          ],
        ),
      ),
    );
  }
}
