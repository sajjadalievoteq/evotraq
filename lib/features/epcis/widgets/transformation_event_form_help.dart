import 'package:flutter/material.dart';

/// Help widget shown on the transformation event form screen
class TransformationEventFormHelp extends StatelessWidget {
  /// Standard constructor
  const TransformationEventFormHelp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.help_outline, color: Colors.blue),
                    const SizedBox(width: 12),
                    Text(
                      'Form Guidance',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'How to Create a Transformation Event',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildFormFieldHelp(
                  context, 
                  'Transformation ID', 
                  'A unique identifier for this transformation process. Can be a simple ID or a full URI - the system will automatically format simple IDs into the proper URN format.',
                  'Example: "transform_12345" (will be converted to urn:traqtrace:transformation:transform_12345) or use a full URI like "urn:epcglobal:cbv:bizstep:batch_123"'
                ),
                const SizedBox(height: 12),                _buildFormFieldHelp(
                  context, 
                  'Input EPCs', 
                  'List of Electronic Product Codes for items that are inputs to the transformation. These are the items being transformed.',
                  'Enter multiple EPCs separated by commas or use the "Sample EPC" and "Sample Batch" buttons to generate examples automatically.'
                ),
                const SizedBox(height: 12),                _buildFormFieldHelp(
                  context, 
                  'Output EPCs', 
                  'List of Electronic Product Codes for items resulting from the transformation process.',
                  'Enter multiple EPCs separated by commas or use the "Sample EPC" and "Sample Batch" buttons to generate examples automatically.'
                ),
                const SizedBox(height: 12),
                _buildFormFieldHelp(
                  context, 
                  'Business Step', 
                  'The business process step being carried out. Select from the dropdown - the system will send the simple value to the backend.',
                  'Valid values include: transforming, producing, assembling, disassembling, combining, separating, repackaging, manufacturing'
                ),
                const SizedBox(height: 12),
                _buildFormFieldHelp(
                  context, 
                  'Disposition', 
                  'The business state of the objects after the event. Select from the dropdown - options are filtered based on selected Business Step.',
                  'Common values include: active, in_progress, transformed, encoded, assembled, produced (changes based on selected business step)'
                ),
                const SizedBox(height: 12),
                _buildFormFieldHelp(
                  context, 
                  'Business Location GLN', 
                  'The Global Location Number (GLN) where the transformation took place.',
                  'Enter the GLN code exactly as registered in your master data. The system will validate it against existing GLN records.'
                ),
                const SizedBox(height: 16),
                Text(
                  'Example Scenarios',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildScenarioHelp(
                  context, 
                  'Manufacturing',
                  'Raw materials (input EPCs) → Finished products (output EPCs)',
                  'Business Step: producing'
                ),
                const SizedBox(height: 8),
                _buildScenarioHelp(
                  context, 
                  'Repackaging',
                  'Bulk product (input EPC) → Multiple individual packages (output EPCs)',
                  'Business Step: repackaging'
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('CLOSE'),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFormFieldHelp(BuildContext context, String fieldName, String description, String example) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(fieldName, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(description),
        const SizedBox(height: 2),
        Text(example, style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
      ],
    );
  }
  
  Widget _buildScenarioHelp(BuildContext context, String title, String process, String bizStep) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(process),
            const SizedBox(height: 2),
            Text(bizStep, style: const TextStyle(fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }
}
