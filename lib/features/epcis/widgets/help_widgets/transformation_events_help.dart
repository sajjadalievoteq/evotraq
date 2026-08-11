import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/epcis/widgets/help_widgets/transformation_events_help_section.dart';

class TransformationEventsHelp extends StatelessWidget {
  const TransformationEventsHelp({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TraqIcon(
                  AppAssets.iconInfo,
                  color: AppColorMapper.infoColor(context),
                ),
                const SizedBox(width: 8),
                Text(
                  'About Transformation Events',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Transformation events track processes where input items are transformed into output items. '
              'This is essential for complying with GS1 track and trace requirements in pharmaceutical manufacturing.',
            ),
            const SizedBox(height: 12),
            const TransformationEventsHelpSection(
              title: 'When to Use Transformation Events',
              description:
                  'Use transformation events to document processes such as:',
              bulletPoints: [
                'Manufacturing: Raw materials into finished products',
                'Repackaging: Bulk products into individual packages',
                'Assembly: Components into assembled products',
                'Disassembly: Breaking down larger units into components',
              ],
            ),
            const SizedBox(height: 12),
            const TransformationEventsHelpSection(
              title: 'Key Information Required',
              description: 'When recording a transformation event, you need:',
              bulletPoints: [
                'Transformation ID: A unique identifier for this transformation process',
                'Input EPCs: The electronic product codes of items that go into the process',
                'Output EPCs: The electronic product codes of items that result from the process',
                'Business Step: The type of process (e.g., producing, repackaging)',
                'Business Location: Where the transformation took place (GLN)',
              ],
            ),
            const SizedBox(height: 12),
            const TransformationEventsHelpSection(
              title: 'Example',
              description:
                  'A batch of bulk medicine (input EPC: https://id.gs1.org/01/10614141073464/21/2018) '
                  'is repackaged into 100 individual packages with new serial numbers. '
                  'Each new package receives its own output EPC.',
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('CLOSE'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
