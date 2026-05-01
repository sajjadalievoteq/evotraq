import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gln/presentation/detail/widgets/gln_detail_date_field.dart';
import 'package:traqtrace_app/features/gs1/gln/presentation/detail/widgets/gln_detail_form_types.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_field_validators.dart';
import 'package:traqtrace_app/features/gs1/widgets/gtin_validated_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';

class GlnLicenseCoreGroup extends StatelessWidget {
  const GlnLicenseCoreGroup({
    super.key,
    required this.setFieldError,
    required this.readOnly,
    required this.isEditing,
    required this.licenseValidFrom,
    required this.licenseExpiry,
    required this.onPickLicenseValidFrom,
    required this.onPickLicenseExpiry,
    required this.licenseNumberController,
    required this.licenseTypeController,
  });

  final GlnFormSetFieldError setFieldError;
  final bool readOnly;
  final bool isEditing;
  final DateTime? licenseValidFrom;
  final DateTime? licenseExpiry;
  final VoidCallback onPickLicenseValidFrom;
  final VoidCallback onPickLicenseExpiry;
  final TextEditingController licenseNumberController;
  final TextEditingController licenseTypeController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('License'),
        Row(
          children: [
            Expanded(
              child: GlnDetailDateField(
                label: 'License valid from',
                value: licenseValidFrom,
                onTap: isEditing ? onPickLicenseValidFrom : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GlnDetailDateField(
                label: 'License valid until',
                value: licenseExpiry,
                onTap: isEditing ? onPickLicenseExpiry : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GtinValidatedField(
                controller: licenseNumberController,
                fieldName: 'licenseNumber',
                label: 'License number',
                readOnly: readOnly,
                setFieldError: setFieldError,
                validator: GlnFieldValidators.validateLicenseNumberOptional,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GtinValidatedField(
                controller: licenseTypeController,
                fieldName: 'licenseType',
                label: 'License type',
                readOnly: readOnly,
                setFieldError: setFieldError,
                validator: GlnFieldValidators.validateLicenseTypeOptional,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
