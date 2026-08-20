import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/features/gs1/widgets/validated_text_field_wrapper.dart';
import 'package:traqtrace_app/features/gs1_tools/screens/gs1_tools/widgets/mode_selector.dart';

class ValidateKindValueFields extends StatelessWidget {
  const ValidateKindValueFields({
    required this.kinds,
    required this.kind,
    required this.controller,
    required this.fieldName,
    required this.valueLabel,
    required this.requiredLabel,
    required this.loading,
    required this.onKindChanged,
    required this.requiredValidator,
    this.keyboardType,
    super.key,
  });

  final List<(String, String)> kinds;
  final String kind;
  final TextEditingController controller;
  final String fieldName;
  final String valueLabel;
  final String requiredLabel;
  final bool loading;
  final ValueChanged<String> onKindChanged;
  final String? Function(String? value, String label) requiredValidator;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Gs1ToolModeSelector(
          modes: kinds,
          value: kind,
          enabled: !loading,
          label: 'Kind',
          onChanged: onKindChanged,
        ),
        const SizedBox(height: TraqSpacing.md),
        ValidatedTextFieldWrapper(
          controller: controller,
          fieldName: fieldName,
          decoration: InputDecoration(labelText: valueLabel),
          keyboardType: keyboardType,
          readOnly: loading,
          validator: (value) => requiredValidator(value, requiredLabel),
        ),
      ],
    );
  }
}
