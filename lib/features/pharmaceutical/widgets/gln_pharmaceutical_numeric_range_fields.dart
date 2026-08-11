import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_text_field.dart';

class GlnPharmaceuticalNumericRangeFields extends StatelessWidget {
  const GlnPharmaceuticalNumericRangeFields({
    required this.minimumController,
    required this.maximumController,
    required this.minimumLabel,
    required this.maximumLabel,
    required this.isEditing,
    super.key,
  });

  final TextEditingController minimumController;
  final TextEditingController maximumController;
  final String minimumLabel;
  final String maximumLabel;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GlnPharmaceuticalTextField(
            controller: minimumController,
            label: minimumLabel,
            enabled: isEditing,
            keyboardType: TextInputType.number,
            maxLength: 10,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GlnPharmaceuticalTextField(
            controller: maximumController,
            label: maximumLabel,
            enabled: isEditing,
            keyboardType: TextInputType.number,
            maxLength: 10,
          ),
        ),
      ],
    );
  }
}
