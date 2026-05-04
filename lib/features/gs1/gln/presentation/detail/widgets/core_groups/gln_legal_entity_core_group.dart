import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_field_validators.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/widgets/gtin_country_code_picker_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/gtin_validated_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';

/// Registered name, trading name, LEI, tax ID, incorporation, website.
class GlnLegalEntityCoreGroup extends StatelessWidget {
  const GlnLegalEntityCoreGroup({
    super.key,
    this.showFieldSkeleton = false,
    required this.setFieldError,
    required this.readOnly,
    required this.registeredLegalNameController,
    required this.tradingNameController,
    required this.leiCodeController,
    required this.taxRegistrationNumberController,
    required this.countryOfIncorporationNumericController,
    required this.websiteController,
  });

  final bool showFieldSkeleton;
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
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel(GlnUiConstants.sectionLegalEntity),
        GtinValidatedField(
          controller: registeredLegalNameController,
          fieldName: 'registeredLegalName',
          label: GlnUiConstants.labelRegisteredLegalName,
          readOnly: readOnly,
          setFieldError: setFieldError,
          validator: GlnFieldValidators.validateRegisteredLegalNameOptional,
        ),
        const SizedBox(height: 12),
        GtinValidatedField(
          controller: tradingNameController,
          fieldName: 'tradingName',
          label: GlnUiConstants.labelTradingName,
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
                label: GlnUiConstants.labelLei,
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
                label: GlnUiConstants.labelTaxVat,
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
                labelText: GlnUiConstants.labelCountryIncorporationNumeric,
                helperText: GlnUiConstants.helperCountryIncorporationNumeric,
                enabled: enabled,
                validator: GlnFieldValidators.validateCountryOfIncorporationOptional,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GtinValidatedField(
                controller: websiteController,
                fieldName: 'website',
                label: GlnUiConstants.labelWebsite,
                readOnly: readOnly,
                setFieldError: setFieldError,
                validator: GlnFieldValidators.validateHttpsUrlOptional,
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
          const SectionLabel(GlnUiConstants.sectionLegalEntity),
          GtinSkeletonOutlineField(color: c, height: 56),
          const SizedBox(height: 12),
          GtinSkeletonOutlineField(color: c, height: 56),
          const SizedBox(height: 12),
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
