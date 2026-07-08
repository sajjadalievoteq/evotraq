import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/epc_uri_validators.dart';
import 'package:traqtrace_app/core/utils/gs1_ai_normalizer.dart';
import 'package:traqtrace_app/core/widgets/gs1_fields/gs1_field_barcode_scan.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_validated_field.dart';

class EpcEntryField extends StatefulWidget {
  const EpcEntryField({
    super.key,
    required this.controller,
    required this.label,
    this.fieldName = 'epc',
    this.enabled = true,
    this.hintText,
    this.helperText,
    this.onChanged,
    this.setFieldError,
    this.validator,
    this.focusNode,
    this.onEditingComplete,
    this.required = false,
    this.barcodeScanEnabled = true,
  });

  final TextEditingController controller;
  final String label;
  final String fieldName;
  final bool enabled;
  final String? hintText;
  final String? helperText;
  final ValueChanged<String>? onChanged;
  final void Function(String, String?)? setFieldError;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final VoidCallback? onEditingComplete;
  final bool required;
  final bool barcodeScanEnabled;

  @override
  State<EpcEntryField> createState() => _EpcEntryFieldState();
}

class _EpcEntryFieldState extends State<EpcEntryField> {
  late final FocusNode _focusNode;
  bool _wasConverted = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode
        ..removeListener(_onFocusChange)
        ..dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }


  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _tryNormalize(widget.controller.text);
    }
  }

  void _tryNormalize(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty || !isGS1AiNotation(trimmed)) return;

    final converted = gs1AiToEpcUri(trimmed);
    if (converted == null) return;

    widget.controller.text = converted;
    widget.onChanged?.call(converted);
    widget.setFieldError?.call(widget.fieldName, null);

    if (mounted) setState(() => _wasConverted = true);
  }


  String? _defaultValidator(String? value) =>
      validateEpcUriField(value?.trim(), required: widget.required);


  void _applyScannedValue(String value) {
    widget.controller.text = value;
    widget.setFieldError?.call(widget.fieldName, null);
    widget.onChanged?.call(value);
    _tryNormalize(value);
  }


  @override
  Widget build(BuildContext context) {
    void onUserChanged(String v) {
      if (_wasConverted && mounted) setState(() => _wasConverted = false);
      widget.onChanged?.call(v);
    }

    final String? effectiveHelper = _wasConverted
        ? '✓ Converted from GS1 barcode to EPC URI'
        : widget.helperText;

    return Gs1ValidatedField(
      controller: widget.controller,
      fieldName: widget.fieldName,
      label: widget.label,
      hintText: widget.hintText ??
          '(01)…(21)…  •  urn:epc:id:sgtin:…  •  https://id.gs1.org/…',
      helperText: effectiveHelper,
      readOnly: !widget.enabled,
      setFieldError: widget.setFieldError,
      focusNode: _focusNode,
      onEditingComplete: () {
        _tryNormalize(widget.controller.text);
        widget.onEditingComplete?.call();
      },
      onChanged: onUserChanged,
      suffixIcon: widget.enabled && widget.barcodeScanEnabled
          ? Gs1FieldBarcodeScan.scanSuffixIcon(
              context: context,
              kind: Gs1FieldScanKind.sgtin,
              onScanned: _applyScannedValue,
            )
          : null,
      validator: widget.validator ?? _defaultValidator,
    );
  }
}
