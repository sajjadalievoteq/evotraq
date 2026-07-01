import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_field_validators.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_country_code_picker_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_validated_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';

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
        Gs1ValidatedField(
          controller: registeredLegalNameController,
          fieldName: 'registeredLegalName',
          label: GlnUiConstants.labelRegisteredLegalName,
          readOnly: readOnly,
          setFieldError: setFieldError,
          validator: GlnFieldValidators.validateRegisteredLegalNameOptional,
        ),
        const SizedBox(height: 12),
        Gs1ValidatedField(
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
              child: Gs1ValidatedField(
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
              child: Gs1ValidatedField(
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
                validator:
                    GlnFieldValidators.validateCountryOfIncorporationOptional,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Gs1ValidatedField(
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

    return Gs1GroupCard(
      title: GlnUiConstants.sectionLegalEntity,
      outlineColor: Theme.of(context).colorScheme.outlineVariant,
      showFieldSkeleton: showFieldSkeleton,
      skeletonBuilder: (c) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 4),
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
      child: body,
    );
  }
}
