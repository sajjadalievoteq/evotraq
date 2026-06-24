import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/utils/sscc_tobacco_constants.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_date_field.dart';

class SsccTobaccoExportImportSection extends StatelessWidget {
  const SsccTobaccoExportImportSection({
    super.key,
    required this.isEditing,
    required this.customsDeclarationNumberController,
    required this.customsDeclarationDate,
    required this.onCustomsDeclarationDateTap,
    required this.exportLicenseNumberController,
    required this.importPermitNumberController,
    required this.countryOfOrigin,
    required this.onCountryOfOriginChanged,
    required this.countryOfDestination,
    required this.onCountryOfDestinationChanged,
  });

  final bool isEditing;
  final TextEditingController customsDeclarationNumberController;
  final DateTime? customsDeclarationDate;
  final VoidCallback? onCustomsDeclarationDateTap;
  final TextEditingController exportLicenseNumberController;
  final TextEditingController importPermitNumberController;
  final String? countryOfOrigin;
  final ValueChanged<String?> onCountryOfOriginChanged;
  final String? countryOfDestination;
  final ValueChanged<String?> onCountryOfDestinationChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Export/Import Documentation',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: customsDeclarationNumberController,
                decoration: const InputDecoration(
                  labelText: 'Customs Declaration Number',
                  border: OutlineInputBorder(),
                ),
                enabled: isEditing,
                maxLength: 100,
                inputFormatters: [LengthLimitingTextInputFormatter(100)],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Gs1DatePickerField(
                label: 'Customs Declaration Date',
                value: customsDeclarationDate,
                emptyValueLabel: 'Not set (optional)',
                onTap: onCustomsDeclarationDateTap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: exportLicenseNumberController,
          decoration: const InputDecoration(
            labelText: 'Export License Number',
            border: OutlineInputBorder(),
          ),
          enabled: isEditing,
          maxLength: 100,
          inputFormatters: [LengthLimitingTextInputFormatter(100)],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: importPermitNumberController,
          decoration: const InputDecoration(
            labelText: 'Import Permit Number',
            border: OutlineInputBorder(),
          ),
          enabled: isEditing,
          maxLength: 100,
          inputFormatters: [LengthLimitingTextInputFormatter(100)],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: countryOfOrigin,
                decoration: const InputDecoration(
                  labelText: 'Country of Origin',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Select Country'),
                  ),
                  ...ssccTobaccoCountryOptions.entries.map((e) => DropdownMenuItem(
                        value: e.key,
                        child: Text('${e.key} - ${e.value}'),
                      )),
                ],
                onChanged: isEditing ? onCountryOfOriginChanged : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: countryOfDestination,
                decoration: const InputDecoration(
                  labelText: 'Country of Destination',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Select Country'),
                  ),
                  ...ssccTobaccoCountryOptions.entries.map((e) => DropdownMenuItem(
                        value: e.key,
                        child: Text('${e.key} - ${e.value}'),
                      )),
                ],
                onChanged: isEditing ? onCountryOfDestinationChanged : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
