import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_date_field.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_field_validators.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/widgets/gtin_validated_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';

class GlnLicenseCoreGroup extends StatelessWidget {
  const GlnLicenseCoreGroup({
    super.key,
    this.showFieldSkeleton = false,
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

  final bool showFieldSkeleton;
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
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel(GlnUiConstants.sectionLicense),
        Row(
          children: [
            Expanded(
              child: Gs1DatePickerField(
                label: GlnUiConstants.labelLicenseValidFrom,
                value: licenseValidFrom,
                onTap: isEditing ? onPickLicenseValidFrom : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Gs1DatePickerField(
                label: GlnUiConstants.labelLicenseValidUntil,
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
                label: GlnUiConstants.labelLicenseNumber,
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
                label: GlnUiConstants.labelLicenseType,
                readOnly: readOnly,
                setFieldError: setFieldError,
                validator: GlnFieldValidators.validateLicenseTypeOptional,
              ),
            ),
          ],
        ),
      ],
    );

    return GtinFieldSkeletonMask(
      show: showFieldSkeleton,
      child: body,
      skeletonBuilder: (c) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionLabel(GlnUiConstants.sectionLicense),
          Row(
            children: [
              Expanded(child: GtinSkeletonOutlineField(color: c, height: 56)),
              const SizedBox(width: 12),
              Expanded(child: GtinSkeletonOutlineField(color: c, height: 56)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: GtinSkeletonOutlineField(color: c, height: 56)),
              const SizedBox(width: 12),
              Expanded(child: GtinSkeletonOutlineField(color: c, height: 56)),
            ],
          ),
        ],
      ),
    );
  }
}
