import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_canonical_identifier.dart';
import 'package:traqtrace_app/core/widgets/gln_selector.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_model.dart';
import 'package:traqtrace_app/features/epcis/presentation/widgets/validated_text_field.dart';
import 'package:traqtrace_app/features/gs1/sgtin/widgets/sgtin_info_row.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/utils/sscc_input_mode.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_input_parser.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_validators.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

class SsccDetailCodeSection extends StatelessWidget {
  const SsccDetailCodeSection({
    super.key,
    required this.isReadOnly,
    required this.ssccInputMode,
    required this.ssccCodeController,
    required this.extensionDigitController,
    required this.issuingGln,
    required this.issuingGlnError,
    required this.sscc,
    required this.glnPickerCatalog,
    required this.onIssuingGlnChanged,
    required this.onInputModeChanged,
    required this.onGenerateSsccCode,
    required this.onScanSsccCode,
    required this.onClearSsccCode,
    required this.setFieldError,
    required this.onSyncExtensionDigitFromSscc,
    required this.onManualSsccCodeChanged,
  });

  final bool isReadOnly;
  final SsccInputMode ssccInputMode;
  final TextEditingController ssccCodeController;
  final TextEditingController extensionDigitController;
  final GLN? issuingGln;
  final String? issuingGlnError;
  final SSCC? sscc;
  final List<GLN> glnPickerCatalog;
  final ValueChanged<GLN?> onIssuingGlnChanged;
  final ValueChanged<SsccInputMode> onInputModeChanged;
  final VoidCallback onGenerateSsccCode;
  final VoidCallback onScanSsccCode;
  final VoidCallback onClearSsccCode;
  final void Function(String fieldName, String? error) setFieldError;
  final ValueChanged<String> onSyncExtensionDigitFromSscc;
  final VoidCallback onManualSsccCodeChanged;

  @override
  Widget build(BuildContext context) {
    final isManual = ssccInputMode == SsccInputMode.manual;
    final isScan = ssccInputMode == SsccInputMode.scan;

    Widget? ssccSuffixIcon;
    String ssccHelperText;
    String ssccHintText;

    if (!isReadOnly) {
      if (ssccInputMode == SsccInputMode.generate) {
        ssccHelperText = 'Will be generated automatically';
        ssccHintText = 'Click Generate button →';
        ssccSuffixIcon = IconButton(
          icon: const TraqIcon(AppAssets.iconRefresh),
          tooltip: 'Generate SSCC Code',
          onPressed: onGenerateSsccCode,
        );
      } else if (isScan) {
        ssccHelperText = 'Tap the scan button to read a barcode';
        ssccHintText = 'Tap scan icon to scan →';
        ssccSuffixIcon = IconButton(
          icon: TraqIcon(AppAssets.iconQr),
          tooltip: 'Scan SSCC Barcode',
          onPressed: onScanSsccCode,
        );
      } else {
        ssccHelperText = 'Type 18 digits, paste GS1 (00)…, or tap scan';
        ssccHintText = 'e.g. 003762345678900001';
        ssccSuffixIcon = ListenableBuilder(
          listenable: ssccCodeController,
          builder: (context, _) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: TraqIcon(AppAssets.iconQr),
                  tooltip: 'Scan SSCC Barcode',
                  onPressed: onScanSsccCode,
                ),
                if (ssccCodeController.text.isNotEmpty)
                  IconButton(
                    icon: TraqIcon(AppAssets.iconX),
                    tooltip: 'Clear',
                    onPressed: onClearSsccCode,
                  ),
              ],
            );
          },
        );
      }
    } else {
      ssccHelperText = '';
      ssccHintText = '';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SSCC Identification',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Enter the GLN of the location that will create/issue this SSCC for GS1 traceability',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16.0),
            if (isReadOnly)
              SgtinInfoRow(
                'Issuing GLN (Location Creating This SSCC)',
                issuingGln != null
                    ? '${issuingGln!.glnCode} – ${issuingGln!.locationName}'
                    : (sscc?.gs1CompanyPrefix != null
                        ? 'GS1 Company Prefix: ${sscc!.gs1CompanyPrefix}'
                        : null),
              )
            else
              GLNSelector(
                label: 'Issuing GLN (Location Creating This SSCC)',
                hintText: 'Search and select issuing location',
                initialValue: issuingGln,
                pickerCatalog: glnPickerCatalog.isEmpty ? null : glnPickerCatalog,
                isRequired: true,
                errorText: issuingGlnError,
                onChanged: onIssuingGlnChanged,
              ),
            if (!isReadOnly) ...[
              const SizedBox(height: 16.0),
              SegmentedButton<SsccInputMode>(
                segments: const [
                  ButtonSegment(
                    value: SsccInputMode.generate,
                    label: Text('Generate'),
                    icon: TraqIcon(AppAssets.iconRefresh, size: 16),
                  ),
                  ButtonSegment(
                    value: SsccInputMode.scan,
                    label: Text('Scan'),
                    icon: TraqIcon(AppAssets.iconQr, size: 16),
                  ),
                  ButtonSegment(
                    value: SsccInputMode.manual,
                    label: Text('Manual'),
                    icon: TraqIcon(AppAssets.iconEdit, size: 16),
                  ),
                ],
                selected: {ssccInputMode},
                onSelectionChanged: (selection) {
                  onInputModeChanged(selection.first);
                },
              ),
            ],
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: ValidatedTextField(
                    controller: extensionDigitController,
                    decoration: InputDecoration(
                      labelText: SsccUiConstants.requiredFieldLabel(
                        SsccUiConstants.labelExtensionDigitField,
                      ),
                      helperText: 'Logistic variants (0-9)',
                      border: OutlineInputBorder(),
                    ),
                    readOnly:
                        isReadOnly || ssccInputMode != SsccInputMode.generate,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final err = validateExtensionDigit(value);
                      setFieldError('extensionDigit', err);
                      return err;
                    },
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  flex: 3,
                  child: ListenableBuilder(
                    listenable: ssccCodeController,
                    builder: (context, _) {
                      return ValidatedTextField(
                        controller: ssccCodeController,
                        decoration: InputDecoration(
                          labelText: SsccUiConstants.requiredFieldLabel(
                            SsccUiConstants.labelSsccCodeField,
                          ),
                          helperText: ssccHelperText,
                          hintText: ssccHintText,
                          border: const OutlineInputBorder(),
                          suffixIcon: ssccSuffixIcon,
                          filled: true,
                          fillColor: ssccCodeController.text.isEmpty
                              ? Colors.grey.shade100
                              : (ssccCodeController.text.length == 18
                                  ? Colors.green.shade50
                                  : Colors.red.shade50),
                        ),
                        readOnly: isReadOnly || !isManual,
                        keyboardType: TextInputType.text,
                        onChanged: isManual
                            ? (value) => _handleManualSsccCodeChange(
                                  value: value,
                                  ssccCodeController: ssccCodeController,
                                  onSyncExtensionDigitFromSscc:
                                      onSyncExtensionDigitFromSscc,
                                  onManualSsccCodeChanged:
                                      onManualSsccCodeChanged,
                                )
                            : null,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            if (ssccInputMode == SsccInputMode.generate) {
                              return 'Please generate an SSCC code';
                            } else if (isScan) {
                              return 'Please scan an SSCC barcode';
                            } else {
                              return 'Please enter an SSCC code';
                            }
                          }
                          return validateSsccCode(value);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void _handleManualSsccCodeChange({
  required String value,
  required TextEditingController ssccCodeController,
  required ValueChanged<String> onSyncExtensionDigitFromSscc,
  required VoidCallback onManualSsccCodeChanged,
}) {
  final trimmed = value.trim();
  final digitsOnly = trimmed.replaceAll(RegExp(r'\D'), '');
  final structured = _looksLikeStructuredSsccInput(trimmed);

  final String nextText;
  if (structured) {
    nextText = SsccInputParser.parseToSsccCode(trimmed) ?? trimmed;
  } else if (digitsOnly.length > 18) {
    nextText = SsccInputParser.parseToSsccCode(trimmed) ??
        digitsOnly.substring(digitsOnly.length - 18);
  } else {
    nextText = digitsOnly;
  }

  if (nextText != value) {
    ssccCodeController.value = TextEditingValue(
      text: nextText,
      selection: TextSelection.collapsed(offset: nextText.length),
    );
  }

  onSyncExtensionDigitFromSscc(nextText);
  onManualSsccCodeChanged();
}

bool _looksLikeStructuredSsccInput(String trimmed) {
  if (Gs1CanonicalIdentifier.isSscc(trimmed)) return true;
  if (trimmed.contains('(00)')) return true;
  return RegExp(r'^00\d').hasMatch(trimmed.replaceAll(RegExp(r'[\s\u00A0]'), ''));
}