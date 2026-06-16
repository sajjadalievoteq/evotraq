import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/custom_button_widget.dart';

import '../../../../../gs1/widgets/gtin_validated_field.dart';

class CommissioningManualSerialInput extends StatelessWidget {
  const CommissioningManualSerialInput({
    super.key,
    required this.controller,
    required this.onAdd,
  });

  final TextEditingController controller;
  final ValueChanged<String> onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Gs1ValidatedField(
          controller: controller,
          fieldName: 'serialNumber',
          label: 'Serial Number',
          hintText: 'Enter serial number',
          onEditingComplete: () {
            final value = controller.text.trim();
            if (value.isNotEmpty) onAdd(value);
          },
          validator: (value) =>
              (value == null || value.trim().isEmpty) ? 'Required' : null,
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: CustomButtonWidget(
            onTap: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) onAdd(value);
            },
            title: 'Add',
          ),
        ),
      ],
    );
  }
}
