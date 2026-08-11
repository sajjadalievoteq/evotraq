import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/gs1/check_digit_utils.dart';
import 'package:traqtrace_app/core/widgets/custom_elevated_button.dart';
import 'package:traqtrace_app/core/widgets/custom_outlined_button_widget.dart';
import 'package:traqtrace_app/core/widgets/gs1_fields/gtin_entry_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/validated_text_field_wrapper.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_date_utils.dart';
import 'package:traqtrace_app/core/web/web_download_stub.dart'
    if (dart.library.html) 'package:traqtrace_app/core/web/web_download_web.dart'
    if (dart.library.io) 'package:traqtrace_app/core/web/web_download_io.dart'
    as web_download;
import 'package:traqtrace_app/core/web/web_print_stub.dart'
    if (dart.library.html) 'package:traqtrace_app/core/web/web_print_web.dart'
    if (dart.library.io) 'package:traqtrace_app/core/web/web_print_io.dart'
    as web_print;
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_cubit.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_state.dart';
import 'package:traqtrace_app/features/gs1_tools/screens/gs1_tools/widgets/mode_selector.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_instructions.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_panel_shell.dart';

/// Consolidated barcode generation / verification workbench.

class BarcodeToolFields extends StatelessWidget {
  const BarcodeToolFields({
    super.key,
    required this.mode,
    required this.loading,
    required this.elementController,
    required this.gtinController,
    required this.serialController,
    required this.expiryController,
    required this.batchController,
    required this.ssccController,
    required this.dataController,
    required this.verifyController,
    required this.requiredValidator,
  });

  final String mode;
  final bool loading;
  final TextEditingController elementController;
  final TextEditingController gtinController;
  final TextEditingController serialController;
  final TextEditingController expiryController;
  final TextEditingController batchController;
  final TextEditingController ssccController;
  final TextEditingController dataController;
  final TextEditingController verifyController;
  final String? Function(String?, String) requiredValidator;

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case 'datamatrix':
      case 'gs1128':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ValidatedTextFieldWrapper(
              controller: elementController,
              fieldName: 'element_string',
              decoration: const InputDecoration(
                labelText: 'GS1 element string',
              ),
              maxLines: 4,
              readOnly: loading,
              validator: (v) => requiredValidator(v, 'Element string'),
            ),
          ],
        );
      case 'pharma':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GtinEntryField(
              controller: gtinController,
              label: 'GTIN (AI 01)',
              enabled: !loading,
              validator: CheckDigitUtils.validateGtin,
            ),
            const SizedBox(height: TraqSpacing.md),
            ValidatedTextFieldWrapper(
              controller: serialController,
              fieldName: 'serial',
              decoration: const InputDecoration(labelText: 'Serial (AI 21)'),
              readOnly: loading,
              validator: (v) => requiredValidator(v, 'Serial'),
            ),
            const SizedBox(height: TraqSpacing.md),
            ValidatedTextFieldWrapper(
              controller: expiryController,
              fieldName: 'expiry',
              decoration: const InputDecoration(
                labelText: 'Expiry YYMMDD (AI 17)',
                helperText: 'Day 00 = last day of month',
              ),
              keyboardType: TextInputType.number,
              readOnly: loading,
              validator: (v) {
                return Gs1DateUtils.validateYymmdd(v, label: 'Expiry');
              },
            ),
            const SizedBox(height: TraqSpacing.md),
            ValidatedTextFieldWrapper(
              controller: batchController,
              fieldName: 'batch',
              decoration: const InputDecoration(
                labelText: 'Batch / lot (AI 10)',
              ),
              readOnly: loading,
              validator: (v) => requiredValidator(v, 'Batch/Lot'),
            ),
          ],
        );
      case 'sscc':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ValidatedTextFieldWrapper(
              controller: ssccController,
              fieldName: 'sscc',
              decoration: const InputDecoration(labelText: 'SSCC'),
              keyboardType: TextInputType.number,
              readOnly: loading,
              validator: CheckDigitUtils.validateSscc,
            ),
          ],
        );
      case 'ean13':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GtinEntryField(
              controller: gtinController,
              label: 'GTIN-13',
              enabled: !loading,
              validator: (v) => CheckDigitUtils.validateGS1CheckDigit(
                v,
                allowedLengths: const {13},
                label: 'GTIN-13',
              ),
            ),
          ],
        );
      case 'upca':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GtinEntryField(
              controller: gtinController,
              label: 'GTIN-12 (UPC-A)',
              enabled: !loading,
              validator: (v) => CheckDigitUtils.validateGS1CheckDigit(
                v,
                allowedLengths: const {12},
                label: 'GTIN-12',
              ),
            ),
          ],
        );
      case 'itf14':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GtinEntryField(
              controller: gtinController,
              label: 'GTIN-14',
              enabled: !loading,
              validator: (v) => CheckDigitUtils.validateGS1CheckDigit(
                v,
                allowedLengths: const {14},
                label: 'GTIN-14',
              ),
            ),
          ],
        );
      case 'qrdl':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ValidatedTextFieldWrapper(
              controller: dataController,
              fieldName: 'digital_link',
              decoration: const InputDecoration(
                labelText: 'Digital Link URL',
                hintText: 'https://id.gs1.org/…',
              ),
              maxLines: 3,
              readOnly: loading,
              validator: (v) => requiredValidator(v, 'Digital Link'),
            ),
          ],
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ValidatedTextFieldWrapper(
              controller: verifyController,
              fieldName: 'verify_input',
              decoration: const InputDecoration(
                labelText: 'Barcode / element string',
              ),
              maxLines: 4,
              readOnly: loading,
              validator: (v) => requiredValidator(v, 'Barcode data'),
            ),
          ],
        );
    }
  }
}
