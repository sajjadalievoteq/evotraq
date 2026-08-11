import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/gs1_fields/gtin_entry_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/validated_text_field_wrapper.dart';
import 'package:traqtrace_app/features/gs1_tools/screens/gs1_tools/widgets/mode_selector.dart';

class ValidateSingleFields extends StatelessWidget {
  const ValidateSingleFields({
    required this.identifierKinds,
    required this.kind,
    required this.valueController,
    required this.serialController,
    required this.loading,
    required this.onKindChanged,
    required this.validatorFor,
    required this.requiredValidator,
    super.key,
  });

  final List<(String, String)> identifierKinds;
  final String kind;
  final TextEditingController valueController;
  final TextEditingController serialController;
  final bool loading;
  final ValueChanged<String> onKindChanged;
  final String? Function(String kind, String? value) validatorFor;
  final String? Function(String? value, String label) requiredValidator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Gs1ToolModeSelector(
          modes: identifierKinds,
          value: kind,
          enabled: !loading,
          label: 'Identifier type',
          onChanged: onKindChanged,
        ),
        const SizedBox(height: TraqSpacing.md),
        if (kind == 'gtin' || kind == 'sgtin')
          GtinEntryField(
            controller: valueController,
            label: 'GTIN',
            enabled: !loading,
            validator: (value) => validatorFor(kind, value),
          )
        else
          ValidatedTextFieldWrapper(
            controller: valueController,
            fieldName: 'single_value',
            decoration: InputDecoration(
              labelText: identifierKinds
                  .firstWhere((item) => item.$1 == kind)
                  .$2,
            ),
            readOnly: loading,
            validator: (value) => validatorFor(kind, value),
          ),
        if (kind == 'sgtin') ...[
          const SizedBox(height: TraqSpacing.md),
          ValidatedTextFieldWrapper(
            controller: serialController,
            fieldName: 'single_serial',
            decoration: const InputDecoration(labelText: 'Serial'),
            readOnly: loading,
            validator: (value) => requiredValidator(value, 'Serial'),
          ),
        ],
      ],
    );
  }
}
