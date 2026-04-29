import 'package:flutter/material.dart';
import 'package:world_countries/world_countries.dart';

class GtinCountryCodePickerField extends StatefulWidget {
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

  @override
  State<GtinCountryCodePickerField> createState() =>
      _GtinCountryCodePickerFieldState();
}

class _GtinCountryCodePickerFieldState extends State<GtinCountryCodePickerField> {
  late final TextEditingController _displayController;

  @override
  void initState() {
    super.initState();
    _displayController = TextEditingController(text: _format(widget.controller.text));
    widget.controller.addListener(_syncFromCode);
  }

  @override
  void didUpdateWidget(covariant GtinCountryCodePickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_syncFromCode);
      widget.controller.addListener(_syncFromCode);
      _displayController.text = _format(widget.controller.text);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncFromCode);
    _displayController.dispose();
    super.dispose();
  }

  void _syncFromCode() {
    final formatted = _format(widget.controller.text);
    if (_displayController.text != formatted) {
      _displayController.text = formatted;
    }
  }

  String _format(String numericCode) {
    final code = numericCode.trim();
    if (code.isEmpty) return '';
    final c = WorldCountry.maybeFromCodeNumeric(code);
    if (c == null) return code;
    final name = _countryName(c);
    return '$name ($code)';
  }

  String _countryName(WorldCountry c) {
    // `world_countries` exposes `name` with localized variants in newer versions.
    // We try common fallbacks while keeping compilation-safe.
    try {
      final dynamic n = (c as dynamic).name;
      if (n is String) return n;
      final dynamic common = (n as dynamic).common;
      if (common is String) return common;
      return n.toString();
    } catch (_) {
      return c.toString();
    }
  }

  Future<void> _openPicker(BuildContext context) async {
    WorldCountry? chosen;
    final existing = widget.controller.text.trim();
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
      widget.controller.text = chosen!.codeNumeric;
      _displayController.text = _format(chosen!.codeNumeric);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.enabled ? () => _openPicker(context) : null,
      child: AbsorbPointer(
        child: TextFormField(
          controller: _displayController,
          decoration: InputDecoration(
            labelText: widget.labelText,
            helperText: widget.helperText,
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.public),
          ),
          readOnly: true,
          validator: widget.enabled ? (_) => widget.validator?.call(widget.controller.text) : null,
        ),
      ),
    );
  }
}
