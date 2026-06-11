import 'package:flutter/material.dart';

/// Widget that displays help information about transformation events
class TransformationEventsHelp extends StatelessWidget {
  /// Standard constructor
  const TransformationEventsHelp({Key? key}) : super(key: key);

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
                const Icon(Icons.info_outline, color: Colors.blue),
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
            _buildHelpSection(
              context,
              'When to Use Transformation Events',
              'Use transformation events to document processes such as:',
              [
                'Manufacturing: Raw materials into finished products',
                'Repackaging: Bulk products into individual packages',
                'Assembly: Components into assembled products',
                'Disassembly: Breaking down larger units into components'
              ],
            ),
            const SizedBox(height: 12),
            _buildHelpSection(
              context,
              'Key Information Required',
              'When recording a transformation event, you need:',
              [
                'Transformation ID: A unique identifier for this transformation process',
                'Input EPCs: The electronic product codes of items that go into the process',
                'Output EPCs: The electronic product codes of items that result from the process',
                'Business Step: The type of process (e.g., producing, repackaging)',
                'Business Location: Where the transformation took place (GLN)'
              ],
            ),
            const SizedBox(height: 12),
            _buildHelpSection(
              context,
              'Example',
              'A batch of bulk medicine (input EPC: urn:epc:id:sgtin:0614141.107346.2018) '
              'is repackaged into 100 individual packages with new serial numbers. '
              'Each new package receives its own output EPC.',
              [],
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

  Widget _buildHelpSection(
      BuildContext context, String title, String description, List<String> bulletPoints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(description),
        if (bulletPoints.isNotEmpty) const SizedBox(height: 4),
        ...bulletPoints.map(
          (point) => Padding(
            padding: const EdgeInsets.only(left: 16, top: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(child: Text(point)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
