import 'package:flutter/material.dart';
import 'package:world_countries/world_countries.dart';

class GtinCountryCodePickerField extends StatelessWidget {
  const GtinCountryCodePickerField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.helperText,
    required this.enabled,
    this.validator,
  });

  final TextEditingController controller;
  final String labelText;
  final String helperText;
  final bool enabled;
  final String? Function(String?)? validator;

  Future<void> _openPicker(BuildContext context) async {
    WorldCountry? chosen;
    final existing = controller.text.trim();
    if (existing.isNotEmpty) {
      chosen = WorldCountry.maybeFromCodeNumeric(existing);
    }

    final picker = CountryPicker(
      chosen: chosen == null ? const [] : [chosen],
      onSelect: (c) {
        chosen = c;
        Navigator.of(context).pop();
      },
    );

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 420,
            maxHeight: 560,
            minWidth: 320,
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 36,
                  left: 12,
                  right: 12,
                  bottom: 12,
                ),
                child: picker,
              ),
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  icon: const Icon(Icons.close),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (chosen != null) {
      controller.text = chosen!.codeNumeric;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? () => _openPicker(context) : null,
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: labelText,
            helperText: helperText,
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.public),
          ),
          readOnly: true,
          validator: enabled ? validator : null,
        ),
      ),
    );
  }
}
