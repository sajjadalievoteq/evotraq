import 'package:flutter/material.dart';
import 'package:world_countries/world_countries.dart';

/// ISO 3166-1 numeric country picker (shared by GTIN and GLN).
///
/// Display text is derived from [controller] in [build]; there is no second
/// [TextEditingController], so parent updates to the numeric code do not notify
/// a nested [TextFormField] during the same layout/build phase (split-view GTIN
/// switches).
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
  final GlobalKey<FormFieldState<String>> _formFieldKey =
      GlobalKey<FormFieldState<String>>();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onCodeControllerChanged);
  }

  @override
  void didUpdateWidget(covariant GtinCountryCodePickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onCodeControllerChanged);
      widget.controller.addListener(_onCodeControllerChanged);
      _scheduleSync();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onCodeControllerChanged);
    super.dispose();
  }

  void _onCodeControllerChanged() {
    _scheduleSync();
  }

  /// Never call [setState] synchronously from [TextEditingController] listeners:
  /// parents often assign [.text] during [didUpdateWidget], which overlaps layout.
  void _scheduleSync() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _formFieldKey.currentState?.didChange(widget.controller.text);
      setState(() {});
    });
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatted = _format(widget.controller.text);

    return FormField<String>(
      key: _formFieldKey,
      initialValue: widget.controller.text,
      validator: (_) =>
          widget.enabled ? widget.validator?.call(widget.controller.text) : null,
      builder: (fieldState) {
        return GestureDetector(
          onTap: widget.enabled ? () => _openPicker(context) : null,
          child: AbsorbPointer(
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: widget.labelText,
                helperText: widget.helperText,
                border: const OutlineInputBorder(),
                suffixIcon: const Icon(Icons.public),
                errorText: fieldState.errorText,
              ),
              child: Text(
                formatted.isEmpty ? ' ' : formatted,
                style: Theme.of(context).textTheme.bodyLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );
      },
    );
  }
}
