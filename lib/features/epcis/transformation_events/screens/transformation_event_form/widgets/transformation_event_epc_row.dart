import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_canonical_identifier.dart';
import 'package:traqtrace_app/features/epcis/transformation_events/screens/transformation_event_form/widgets/transformation_event_epc_field.dart';

class TransformationEventEpcRow extends StatelessWidget {
  const TransformationEventEpcRow({
    required this.controller,
    required this.label,
    required this.helperText,
    required this.fieldName,
    required this.onFieldError,
    required this.onGenerateSample,
    required this.onGenerateBatch,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String helperText;
  final String fieldName;
  final void Function(String fieldName, String? error) onFieldError;
  final VoidCallback onGenerateSample;
  final VoidCallback onGenerateBatch;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TransformationEventEpcField(
            controller: controller,
            label: label,
            helperText: helperText,
            fieldName: fieldName,
            onFieldError: onFieldError,
            validator: _validateEpcs,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          children: [
            ElevatedButton(
              onPressed: onGenerateSample,
              child: const Text('Sample EPC'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: onGenerateBatch,
              child: const Text('Sample Batch'),
            ),
          ],
        ),
      ],
    );
  }

  String? _validateEpcs(String? value) {
    if (value == null || value.trim().isEmpty) {
      final direction = fieldName == 'inputEpcs' ? 'input' : 'output';
      return 'At least one $direction EPC is required';
    }
    final epcs = value
        .split(',')
        .map((epc) => epc.trim())
        .where((epc) => epc.isNotEmpty);
    for (final epc in epcs) {
      if (!Gs1CanonicalIdentifier.isValid(epc) &&
          !RegExp(r'\(\d+\)').hasMatch(epc)) {
        return 'Invalid EPC format: $epc';
      }
    }
    return null;
  }
}
