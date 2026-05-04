import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_field_validators.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/widgets/gtin_validated_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';

/// Location name, mobility, postal address.
class GlnLocationAddressCoreGroup extends StatelessWidget {
  const GlnLocationAddressCoreGroup({
    super.key,
    this.showFieldSkeleton = false,
    required this.setFieldError,
    required this.readOnly,
    required this.locationNameController,
    required this.mobility,
    required this.onMobilityChanged,
    required this.mobileLocationIdentifierController,
    required this.addressLine1Controller,
    required this.addressLine2Controller,
    required this.cityController,
    required this.stateProvinceController,
    required this.postalCodeController,
    required this.countryController,
  });

  final bool showFieldSkeleton;
  final GlnFormSetFieldError setFieldError;
  final bool readOnly;

  final TextEditingController locationNameController;
  final String mobility;
  final ValueChanged<String?> onMobilityChanged;
  final TextEditingController mobileLocationIdentifierController;
  final TextEditingController addressLine1Controller;
  final TextEditingController addressLine2Controller;
  final TextEditingController cityController;
  final TextEditingController stateProvinceController;
  final TextEditingController postalCodeController;
  final TextEditingController countryController;

  @override
  Widget build(BuildContext context) {
    final isEditing = !readOnly;
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel(GlnUiConstants.sectionLocationAddress),
        GtinValidatedField(
          controller: locationNameController,
          fieldName: 'locationName',
          label: GlnUiConstants.labelLocationNameRequired,
          readOnly: readOnly,
          setFieldError: setFieldError,
          validator: GlnFieldValidators.validateLocationNameRequired,
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                key: ValueKey(mobility),
                initialValue: mobility,
                decoration: const InputDecoration(
                  labelText: GlnUiConstants.labelFixedVsMobile,
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: GlnUiConstants.mobilityFixed,
                    child: Text(GlnUiConstants.mobilityFixed),
                  ),
                  DropdownMenuItem(
                    value: GlnUiConstants.mobilityMobile,
                    child: Text(GlnUiConstants.mobilityMobile),
                  ),
                ],
                onChanged: isEditing ? onMobilityChanged : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GtinValidatedField(
                controller: mobileLocationIdentifierController,
                fieldName: 'mobileLocationIdentifier',
                label: GlnUiConstants.labelMobileLocationId,
                helperText: GlnUiConstants.helperMobileLocationId,
                readOnly: readOnly,
                setFieldError: setFieldError,
                validator: GlnFieldValidators.validateMobileLocationIdOptional,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GtinValidatedField(
          controller: addressLine1Controller,
          fieldName: 'addressLine1',
          label: GlnUiConstants.labelAddressLine1,
          readOnly: readOnly,
          setFieldError: setFieldError,
          validator: GlnFieldValidators.validateAddressLine1Required,
        ),
        const SizedBox(height: 12),
        GtinValidatedField(
          controller: addressLine2Controller,
          fieldName: 'addressLine2',
          label: GlnUiConstants.labelAddressLine2,
          readOnly: readOnly,
          setFieldError: setFieldError,
          validator: GlnFieldValidators.validateAddressLine2Optional,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GtinValidatedField(
                controller: cityController,
                fieldName: 'city',
                label: GlnUiConstants.labelCityRequired,
                readOnly: readOnly,
                setFieldError: setFieldError,
                validator: GlnFieldValidators.validateCityRequired,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GtinValidatedField(
                controller: stateProvinceController,
                fieldName: 'stateProvince',
                label: GlnUiConstants.labelStateProvince,
                readOnly: readOnly,
                setFieldError: setFieldError,
                validator: GlnFieldValidators.validateStateProvinceRequired,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: GtinValidatedField(
                controller: postalCodeController,
                fieldName: 'postalCode',
                label: GlnUiConstants.labelPostalCode,
                readOnly: readOnly,
                setFieldError: setFieldError,
                validator: GlnFieldValidators.validatePostalCodeRequired,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: GtinValidatedField(
                controller: countryController,
                fieldName: 'country',
                label: GlnUiConstants.labelCountryRequired,
                readOnly: readOnly,
                setFieldError: setFieldError,
                validator: GlnFieldValidators.validateCountryRequired,
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
          const SectionLabel(GlnUiConstants.sectionLocationAddress),
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
              Expanded(flex: 1, child: GtinSkeletonOutlineField(color: c, height: 56)),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: GtinSkeletonOutlineField(color: c, height: 56)),
            ],
          ),
        ],
      ),
    );
  }
}
