import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';

class TatmeenSecretField extends StatelessWidget {
  const TatmeenSecretField({
    super.key,
    required this.label,
    required this.configured,
    required this.configuredLabel,
    required this.editing,
    required this.controller,
    required this.obscure,
    required this.busy,
    required this.onToggleObscure,
    required this.onChange,
    required this.onCancelChange,
    required this.onRemove,
    required this.validator,
  });

  final String label;
  final bool configured;
  final String configuredLabel;
  final bool editing;
  final TextEditingController controller;
  final bool obscure;
  final bool busy;
  final VoidCallback onToggleObscure;
  final VoidCallback onChange;
  final VoidCallback onCancelChange;
  final Future<void> Function() onRemove;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    if (configured && !editing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
            ),
            child: Text(configuredLabel),
          ),
          const SizedBox(height: TraqSpacing.xs),
          Wrap(
            spacing: TraqSpacing.sm,
            children: [
              TextButton(
                onPressed: busy ? null : onChange,
                child: const Text('Change'),
              ),
              TextButton(
                onPressed: busy ? null : () async => onRemove(),
                child: Text('Remove $label'),
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: controller,
          enabled: !busy,
          obscureText: obscure,
          enableSuggestions: false,
          autocorrect: false,
          inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Icons.visibility_off : Icons.visibility,
                size: 20,
              ),
              tooltip: obscure ? 'Show $label' : 'Hide $label',
              onPressed: onToggleObscure,
            ),
          ),
          validator: validator,
        ),
        if (configured && editing)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: busy ? null : onCancelChange,
              child: const Text('Cancel change'),
            ),
          ),
      ],
    );
  }
}
