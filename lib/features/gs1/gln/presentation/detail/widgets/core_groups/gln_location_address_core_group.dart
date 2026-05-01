import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gln/presentation/detail/widgets/gln_detail_form_types.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_field_validators.dart';
import 'package:traqtrace_app/features/gs1/widgets/gtin_validated_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';

/// Location name, mobility, postal address.
class GlnLocationAddressCoreGroup extends StatelessWidget {
  const GlnLocationAddressCoreGroup({
    super.key,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Location & address'),
        GtinValidatedField(
          controller: locationNameController,
          fieldName: 'locationName',
          label: 'Location name',
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
                value: mobility,
                decoration: const InputDecoration(
                  labelText: 'Fixed vs mobile',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'FIXED', child: Text('FIXED')),
                  DropdownMenuItem(value: 'MOBILE', child: Text('MOBILE')),
                ],
                onChanged: isEditing ? onMobilityChanged : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GtinValidatedField(
                controller: mobileLocationIdentifierController,
                fieldName: 'mobileLocationIdentifier',
                label: 'Mobile location ID',
                helperText: 'Vehicle reg, IMO, tail number…',
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
          label: 'Address line 1',
          readOnly: readOnly,
          setFieldError: setFieldError,
          validator: GlnFieldValidators.validateAddressLine1Required,
        ),
        const SizedBox(height: 12),
        GtinValidatedField(
          controller: addressLine2Controller,
          fieldName: 'addressLine2',
          label: 'Address line 2',
          readOnly: readOnly,
          setFieldError: setFieldError,
          validator: (_) => null,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GtinValidatedField(
                controller: cityController,
                fieldName: 'city',
                label: 'City',
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
                label: 'State / province',
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
                label: 'Postal code',
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
                label: 'Country',
                readOnly: readOnly,
                setFieldError: setFieldError,
                validator: GlnFieldValidators.validateCountryRequired,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
