import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';

class SystemUserFormField extends StatelessWidget {
  const SystemUserFormField({
    super.key,
    required this.name,
    required this.label,
    this.validators = const [],
    this.keyboardType,
    this.inputFormatters,
  });

  final String name;
  final String label;
  final List<FormFieldValidator<String>> validators;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: TraqSpacing.md),
      child: FormBuilderTextField(
        name: name,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: FormBuilderValidators.compose([
          if (name != 'partyGln') FormBuilderValidators.required(),
          ...validators,
        ]),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
