import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/epcis/widgets/help_widgets/transformation_form_field_help.dart';
import 'package:traqtrace_app/features/epcis/widgets/help_widgets/transformation_scenario_help.dart';

class TransformationEventFormHelp extends StatelessWidget {
  const TransformationEventFormHelp({super.key});

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
                    TraqIcon(
                      AppAssets.iconInfo,
                      color: AppColorMapper.infoColor(context),
                    ),
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const TransformationFormFieldHelp(
                  fieldName: 'Transformation ID',
                  description:
                      'A unique identifier for this transformation process. Can be a simple ID or a full URI - the system will automatically format simple IDs into the proper URN format.',
                  example:
                      'Example: "transform_12345" (will be converted to a URN) or use a full URI with your organization namespace.',
                ),
                const SizedBox(height: 12),
                const TransformationFormFieldHelp(
                  fieldName: 'Input EPCs',
                  description:
                      'List of Electronic Product Codes for items that are inputs to the transformation. These are the items being transformed.',
                  example:
                      'Enter multiple EPCs separated by commas or use the "Sample EPC" and "Sample Batch" buttons to generate examples automatically.',
                ),
                const SizedBox(height: 12),
                const TransformationFormFieldHelp(
                  fieldName: 'Output EPCs',
                  description:
                      'List of Electronic Product Codes for items resulting from the transformation process.',
                  example:
                      'Enter multiple EPCs separated by commas or use the "Sample EPC" and "Sample Batch" buttons to generate examples automatically.',
                ),
                const SizedBox(height: 12),
                const TransformationFormFieldHelp(
                  fieldName: 'Business Step',
                  description:
                      'The business process step being carried out. Select from the dropdown - the system will send the simple value to the backend.',
                  example:
                      'Valid values include: transforming, producing, assembling, disassembling, combining, separating, repackaging, manufacturing',
                ),
                const SizedBox(height: 12),
                const TransformationFormFieldHelp(
                  fieldName: 'Disposition',
                  description:
                      'The business state of the objects after the event. Select from the dropdown - options are filtered based on selected Business Step.',
                  example:
                      'Common values include: active, in_progress, transformed, encoded, assembled, produced (changes based on selected business step)',
                ),
                const SizedBox(height: 12),
                const TransformationFormFieldHelp(
                  fieldName: 'Business Location GLN',
                  description:
                      'The Global Location Number (GLN) where the transformation took place.',
                  example:
                      'Enter the GLN code exactly as registered in your master data. The system will validate it against existing GLN records.',
                ),
                const SizedBox(height: 16),
                Text(
                  'Example Scenarios',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const TransformationScenarioHelp(
                  title: 'Manufacturing',
                  process:
                      'Raw materials (input EPCs) → Finished products (output EPCs)',
                  bizStep: 'Business Step: producing',
                ),
                const SizedBox(height: 8),
                const TransformationScenarioHelp(
                  title: 'Repackaging',
                  process:
                      'Bulk product (input EPC) → Multiple individual packages (output EPCs)',
                  bizStep: 'Business Step: repackaging',
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
}
