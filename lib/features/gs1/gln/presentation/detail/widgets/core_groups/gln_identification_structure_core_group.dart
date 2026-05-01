import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/features/gs1/gln/presentation/detail/widgets/gln_detail_form_types.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_field_validators.dart';
import 'package:traqtrace_app/features/gs1/widgets/gtin_validated_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';

/// GS1 identification: GLN, GCP / reference / check digit, parent, AI 254.
class GlnIdentificationStructureCoreGroup extends StatelessWidget {
  const GlnIdentificationStructureCoreGroup({
    super.key,
    required this.setFieldError,
    required this.readOnly,
    required this.glnCodeController,
    required this.gs1CompanyPrefixController,
    required this.locationReferenceDigitsController,
    required this.checkDigitController,
    required this.parentGlnCodeController,
    required this.glnExtensionComponentController,
  });

  final GlnFormSetFieldError setFieldError;
  final bool readOnly;

  final TextEditingController glnCodeController;
  final TextEditingController gs1CompanyPrefixController;
  final TextEditingController locationReferenceDigitsController;
  final TextEditingController checkDigitController;
  final TextEditingController parentGlnCodeController;
  final TextEditingController glnExtensionComponentController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Identification & structure'),
        GtinValidatedField(
          controller: glnCodeController,
          fieldName: 'glnCode',
          label: 'GLN (13 digits)',
          hintText: 'Enter 13-digit GLN',
          readOnly: readOnly,
          setFieldError: setFieldError,
          keyboardType: TextInputType.number,
          maxLength: 13,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: GlnFieldValidators.validateGlnCode,
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: GtinValidatedField(
                controller: gs1CompanyPrefixController,
                fieldName: 'gs1CompanyPrefix',
                label: 'GS1 Company Prefix',
                helperText: 'Optional — informational / derived',
                readOnly: readOnly,
                setFieldError: setFieldError,
                validator: GlnFieldValidators.validateGs1CompanyPrefixOptional,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GtinValidatedField(
                controller: locationReferenceDigitsController,
                fieldName: 'locationReferenceDigits',
                label: 'Location reference',
                helperText: 'Optional',
                readOnly: readOnly,
                setFieldError: setFieldError,
                validator: GlnFieldValidators.validateLocationReferenceOptional,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GtinValidatedField(
                controller: checkDigitController,
                fieldName: 'checkDigit',
                label: 'Check digit',
                helperText: 'Optional',
                readOnly: readOnly,
                setFieldError: setFieldError,
                validator: GlnFieldValidators.validateCheckDigitOptional,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GtinValidatedField(
          controller: parentGlnCodeController,
          fieldName: 'parentGlnCode',
          label: 'Parent GLN',
          hintText: '13-digit parent (e.g. legal entity for a function)',
          readOnly: readOnly,
          setFieldError: setFieldError,
          keyboardType: TextInputType.number,
          maxLength: 13,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: GlnFieldValidators.validateParentGlnOptional,
        ),
        const SizedBox(height: 12),
        GtinValidatedField(
          controller: glnExtensionComponentController,
          fieldName: 'glnExtensionComponent',
          label: 'GLN extension component (AI 254)',
          helperText:
              'Internal sub-location — max 20 chars; pairs with physical GLN',
          readOnly: readOnly,
          setFieldError: setFieldError,
          validator: GlnFieldValidators.validateGlnExtensionComponentOptional,
        ),
      ],
    );
  }
}
