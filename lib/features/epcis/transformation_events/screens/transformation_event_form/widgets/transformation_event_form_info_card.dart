import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class TransformationEventFormInfoCard extends StatelessWidget {
  const TransformationEventFormInfoCard({required this.onShowHelp, super.key});

  final VoidCallback onShowHelp;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                  'Transformation Event',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Record how input items are transformed into output items according to GS1 EPCIS 2.0 standards.',
            ),
            const SizedBox(height: 4),
            TextButton(onPressed: onShowHelp, child: const Text('Need Help?')),
          ],
        ),
      ),
    );
  }
}
