import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/formatters/gs1_input_formatters.dart';
import 'package:traqtrace_app/core/widgets/gs1_fields/gs1_field_barcode_scan.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_validators.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_validated_field.dart';

class SsccEntryField extends StatelessWidget {
  const SsccEntryField({
    super.key,
    required this.controller,
    required this.label,
    this.fieldName = 'sscc',
    this.enabled = true,
    this.hintText,
    this.helperText,
    this.onChanged,
    this.setFieldError,
    this.validator,
    this.focusNode,
    this.onEditingComplete,
    this.optional = false,
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
  final bool optional;
  final bool barcodeScanEnabled;

  void _applyScannedValue(String value) {
    controller.text = value;
    setFieldError?.call(fieldName, null);
    onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    return Gs1ValidatedField(
      controller: controller,
      fieldName: fieldName,
      label: label,
      hintText: hintText,
      helperText: helperText,
      readOnly: !enabled,
      setFieldError: setFieldError,
      focusNode: focusNode,
      onEditingComplete: onEditingComplete,
      // Use text keyboard so URN / DL values typed or pasted render correctly.
      // For pure-digit entry the smart formatter still restricts to max 18 digits.
      keyboardType: TextInputType.text,
      inputFormatters: Gs1InputFormatters.ssccOrUri(),
      onChanged: onChanged,
      suffixIcon: enabled && barcodeScanEnabled
          ? Gs1FieldBarcodeScan.scanSuffixIcon(
              context: context,
              kind: Gs1FieldScanKind.sscc,
              onScanned: _applyScannedValue,
            )
          : null,
      validator: validator ??
          (optional ? validateSsccCodeOptional : validateSsccCode),
    );
  }
}
