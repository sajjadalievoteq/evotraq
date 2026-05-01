import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gln/presentation/detail/widgets/gln_detail_form_types.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_field_validators.dart';
import 'package:traqtrace_app/features/gs1/widgets/gtin_country_code_picker_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/gtin_validated_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';

/// Registered name, trading name, LEI, tax ID, incorporation, website.
class GlnLegalEntityCoreGroup extends StatelessWidget {
  const GlnLegalEntityCoreGroup({
    super.key,
    required this.setFieldError,
    required this.readOnly,
    required this.registeredLegalNameController,
    required this.tradingNameController,
    required this.leiCodeController,
    required this.taxRegistrationNumberController,
    required this.countryOfIncorporationNumericController,
    required this.websiteController,
  });

  final GlnFormSetFieldError setFieldError;
  final bool readOnly;

  final TextEditingController registeredLegalNameController;
  final TextEditingController tradingNameController;
  final TextEditingController leiCodeController;
  final TextEditingController taxRegistrationNumberController;
  final TextEditingController countryOfIncorporationNumericController;
  final TextEditingController websiteController;

  @override
  Widget build(BuildContext context) {
    final enabled = !readOnly;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Legal entity attributes'),
        GtinValidatedField(
          controller: registeredLegalNameController,
          fieldName: 'registeredLegalName',
          label: 'Registered legal name',
          readOnly: readOnly,
          setFieldError: setFieldError,
          validator: GlnFieldValidators.validateRegisteredLegalNameOptional,
        ),
        const SizedBox(height: 12),
        GtinValidatedField(
          controller: tradingNameController,
          fieldName: 'tradingName',
          label: 'Trading / brand name',
          readOnly: readOnly,
          setFieldError: setFieldError,
          validator: GlnFieldValidators.validateTradingNameOptional,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GtinValidatedField(
                controller: leiCodeController,
                fieldName: 'leiCode',
                label: 'LEI (20 chars)',
                readOnly: readOnly,
                setFieldError: setFieldError,
                validator: GlnFieldValidators.validateLeiOptional,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GtinValidatedField(
                controller: taxRegistrationNumberController,
                fieldName: 'taxRegistrationNumber',
                label: 'Tax / VAT registration',
                readOnly: readOnly,
                setFieldError: setFieldError,
                validator: GlnFieldValidators.validateTaxRegistrationOptional,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: GtinCountryCodePickerField(
                controller: countryOfIncorporationNumericController,
                labelText: 'Country of incorporation (ISO 3166-1 numeric)',
                helperText: 'Tap to choose (stores numeric code, e.g. 784)',
                enabled: enabled,
                validator: GlnFieldValidators.validateCountryOfIncorporationOptional,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GtinValidatedField(
                controller: websiteController,
                fieldName: 'website',
                label: 'Website',
                readOnly: readOnly,
                setFieldError: setFieldError,
                validator: GlnFieldValidators.validateHttpsUrlOptional,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
