import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_input_type_badge.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';
import 'package:traqtrace_app/core/widgets/gs1_fields/epc_entry_field.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class EpcInputManualTab extends StatelessWidget {
  const EpcInputManualTab({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.parsedResult,
    required this.validator,
    required this.onChanged,
    required this.onAdd,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final EPCParseResult? parsedResult;
  final FormFieldValidator<String> validator;
  final ValueChanged<String> onChanged;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            EpcEntryField(
              controller: controller,
              label: label,
              hintText: hintText,
              validator: validator,
              onChanged: onChanged,
              onEditingComplete: onAdd,
            ),
            if (parsedResult != null) EpcInputTypeBadge(result: parsedResult!),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: parsedResult != null ? onAdd : null,
              icon: const TraqIcon(AppAssets.iconPlus),
              label: const Text('Add Item'),
            ),
          ],
        ),
      ),
    );
  }
}
