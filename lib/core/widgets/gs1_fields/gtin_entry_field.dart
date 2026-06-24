import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/formatters/gs1_input_formatters.dart';
import 'package:traqtrace_app/core/widgets/gs1_fields/gs1_field_barcode_scan.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_field_validators.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_validated_field.dart';

class GtinEntryField extends StatelessWidget {
  const GtinEntryField({
    super.key,
    required this.controller,
    required this.label,
    this.fieldName = 'gtin',
    this.enabled = true,
    this.hintText,
    this.helperText,
    this.onChanged,
    this.setFieldError,
    this.validator,
    this.focusNode,
    this.onEditingComplete,
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
      keyboardType: const TextInputType.numberWithOptions(
        decimal: false,
        signed: false,
      ),
      maxLength: 14,
      inputFormatters: Gs1InputFormatters.gtin(),
      onChanged: onChanged,
      suffixIcon: enabled && barcodeScanEnabled
          ? Gs1FieldBarcodeScan.scanSuffixIcon(
              context: context,
              kind: Gs1FieldScanKind.gtin,
              onScanned: _applyScannedValue,
            )
          : null,
      validator: validator ?? GtinFieldValidators.validateGtinCode,
    );
  }
}
