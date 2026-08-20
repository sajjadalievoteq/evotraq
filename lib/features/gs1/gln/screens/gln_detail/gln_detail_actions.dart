import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_presenter.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_pharmaceutical_extension_model.dart';
import 'package:traqtrace_app/features/gs1/gln/screens/gln_detail/gln_detail_screen.dart';
import 'package:traqtrace_app/features/gs1/gln/screens/gln_detail/utils/gln_location_type_mapper.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_field_validators.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_format.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_ui_constants.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_extension_actions.dart';

extension GlnDetailActions on GLNDetailScreenState {
  Future<void> refresh() async {
    if (widget.glnId != null) {
      glnCubit?.fetchGLNById(widget.glnId!);
    }
  }

  void _applyGlnToLocalState(GLN g) {
    licenseValidFrom = g.licenseValidFrom;
    licenseExpiry = g.licenseExpiry;
    effectiveFrom = g.effectiveFrom;
    effectiveTo = g.effectiveTo;
    nonReuseUntil = g.nonReuseUntil;
    coordinates = g.coordinates;
  }

  void _populateFromGln(GLN? g) {
    if (g == null) {
      clearGlnFieldTexts();

      operatingStatus = 'ACTIVE';
      industryClassification = 'HEALTHCARE';
      glnSource = 'SELF_ALLOCATED';
      mobility = 'FIXED';
      digitalAddressType = 'URL';
      locationTypeLabel = 'Other';
      glnTypes = ['FIXED_PHYSICAL'];
      licenseValidFrom = null;
      licenseExpiry = null;
      effectiveFrom = null;
      effectiveTo = null;
      nonReuseUntil = null;
      coordinates = null;
      return;
    }

    seedGlnFieldTexts(
      glnCode: g.glnCode,
      gs1CompanyPrefix: g.gs1CompanyPrefix ?? '',
      locationReferenceDigits: g.locationReferenceDigits ?? '',
      checkDigit: g.checkDigit ?? '',
      parentGlnCode: g.parentGln?.glnCode ?? '',
      glnExtensionComponent: g.glnExtensionComponent ?? '',
      locationName: g.locationName,
      addressLine1: g.addressLine1,
      addressLine2: g.addressLine2 ?? '',
      city: g.city,
      stateProvince: g.stateProvince,
      postalCode: g.postalCode,
      country: g.country,
      mobileLocationIdentifier: g.mobileLocationIdentifier ?? '',
      registeredLegalName: g.registeredLegalName ?? '',
      tradingName: g.tradingName ?? '',
      leiCode: g.leiCode ?? '',
      taxRegistrationNumber: g.taxRegistrationNumber ?? '',
      countryOfIncorporationNumeric: g.countryOfIncorporationNumeric ?? '',
      website: g.website ?? '',
      contactName: g.contactName ?? '',
      contactEmail: g.contactEmail ?? '',
      contactPhone: g.contactPhone ?? '',
      digitalAddressValue: g.digitalAddressValue ?? '',
      supplyChainRoles: g.supplyChainRoles.join(', '),
      locationRoles: g.locationRoles.join(', '),
      licenseNumber: g.licenseNumber ?? '',
      licenseType: g.licenseType ?? '',
    );

    operatingStatus = (g.operatingStatus ?? 'ACTIVE').toUpperCase();
    industryClassification = g.industryClassification ?? 'HEALTHCARE';
    glnSource = g.glnSource ?? 'SELF_ALLOCATED';
    mobility = g.mobility ?? 'FIXED';
    digitalAddressType = g.digitalAddressType ?? 'URL';
    locationTypeLabel = GlnLocationTypeMapper.toDropdownLabel(g.locationType);
    glnTypes = g.glnTypes.isEmpty
        ? ['FIXED_PHYSICAL']
        : List<String>.from(g.glnTypes);

    _applyGlnToLocalState(g);
  }

  void maybeHydrateFromGln(GLN? g) {
    if (widget.glnId != null && g == null) {
      return;
    }
    final tag = widget.glnId == null ? 'create' : g!.glnCode;
    if (hydratedTag == tag) {
      return;
    }
    hydratedTag = tag;
    _populateFromGln(g);
    formFieldsHydrated = true;
    setState(() {});
  }

  List<String> _splitRoles(String? raw) {
    if (raw == null || raw.trim().isEmpty) return [];
    return raw
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  Future<void> pickDate(
    ValueChanged<DateTime?> onPick,
    DateTime? current,
  ) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 30),
    );
    if (picked != null) {
      onPick(picked);
    }
  }

  Future<void> submitForm() async {
    if (widget.awaitingListSelection) return;
    if (glnTypes.isEmpty) {
      setState(() {
        glnTypesErrorText = GlnUiConstants.errorSelectGlnType;
      });
      context.showError(GlnUiConstants.errorFixForm);
      return;
    }
    setState(() => glnTypesErrorText = null);

    if (!forceMountAllSections) {
      setState(() => forceMountAllSections = true);
      await Future<void>.delayed(Duration.zero);
      if (!mounted) return;
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;
    }

    if (!(formKey.currentState?.validate() ?? false)) {
      context.showError(GlnUiConstants.errorFixForm);
      return;
    }

    final glnCode = GlnFormat.stripGlnInput(glnFieldText('glnCode'));
    final locationName = glnFieldText('locationName');
    final addressLine1 = glnFieldText('addressLine1');
    final city = glnFieldText('city');
    final stateProvince = glnFieldText('stateProvince');
    final postalCode = glnFieldText('postalCode');
    final country = glnFieldText('country');

    final isValid = validationCubit.validateAllFields({
      'glnCode': {
        'value': glnCode,
        'validator': GlnFieldValidators.validateGlnCode,
      },
      'locationName': {
        'value': locationName,
        'validator': GlnFieldValidators.validateLocationNameRequired,
      },
      'addressLine1': {
        'value': addressLine1,
        'validator': GlnFieldValidators.validateAddressLine1Required,
      },
      'city': {
        'value': city,
        'validator': GlnFieldValidators.validateCityRequired,
      },
      'stateProvince': {
        'value': stateProvince,
        'validator': GlnFieldValidators.validateStateProvinceRequired,
      },
      'postalCode': {
        'value': postalCode,
        'validator': GlnFieldValidators.validatePostalCodeRequired,
      },
      'country': {
        'value': country,
        'validator': GlnFieldValidators.validateCountryRequired,
      },
    });

    if (!isValid) return;

    final normalizedOperatingStatus = operatingStatus.toUpperCase();
    final active = normalizedOperatingStatus == 'ACTIVE';

    final parentRaw = GlnFormat.stripGlnInput(glnFieldText('parentGlnCode'));
    final parentGln = parentRaw.length == 13 ? GLN.fromCode(parentRaw) : null;

    GLNPharmaceuticalExtension? pharmaceuticalExtension;
    final pharmaSt = pharmaExtensionKey.currentState;
    if (pharmaSt != null && pharmaSt.hasData) {
      pharmaceuticalExtension = pharmaSt.buildExtension(
        glnId: null,
        glnCode: glnCode,
      );
    }

    final gln = GLN(
      glnCode: glnCode,
      locationName: locationName,
      addressLine1: addressLine1,
      addressLine2: nonEmptyOrNull(glnFieldText('addressLine2')),
      city: city,
      stateProvince: stateProvince,
      postalCode: postalCode,
      country: country,
      contactName: nonEmptyOrNull(glnFieldText('contactName')),
      contactEmail: nonEmptyOrNull(glnFieldText('contactEmail')),
      contactPhone: nonEmptyOrNull(glnFieldText('contactPhone')),
      locationType: GlnLocationTypeMapper.parseDropdown(locationTypeLabel),
      parentGln: parentGln,
      licenseNumber: nonEmptyOrNull(glnFieldText('licenseNumber')),
      licenseType: nonEmptyOrNull(glnFieldText('licenseType')),
      licenseValidFrom: licenseValidFrom,
      licenseExpiry: licenseExpiry,
      active: active,
      coordinates: coordinates,
      operatingStatus: operatingStatus,
      effectiveFrom: effectiveFrom,
      effectiveTo: effectiveTo,
      nonReuseUntil: nonReuseUntil,
      gs1CompanyPrefix: nonEmptyOrNull(glnFieldText('gs1CompanyPrefix')),
      locationReferenceDigits: nonEmptyOrNull(
        glnFieldText('locationReferenceDigits'),
      ),
      checkDigit: nonEmptyOrNull(glnFieldText('checkDigit')),
      registeredLegalName: nonEmptyOrNull(glnFieldText('registeredLegalName')),
      tradingName: nonEmptyOrNull(glnFieldText('tradingName')),
      leiCode: nonEmptyOrNull(glnFieldText('leiCode')),
      taxRegistrationNumber: nonEmptyOrNull(
        glnFieldText('taxRegistrationNumber'),
      ),
      countryOfIncorporationNumeric: nonEmptyOrNull(
        glnFieldText('countryOfIncorporationNumeric').trim(),
      ),
      website: nonEmptyOrNull(glnFieldText('website')),
      digitalAddressType: digitalAddressType,
      digitalAddressValue: nonEmptyOrNull(glnFieldText('digitalAddressValue')),
      glnExtensionComponent: nonEmptyOrNull(
        glnFieldText('glnExtensionComponent'),
      ),
      industryClassification: industryClassification,
      glnSource: glnSource,
      mobility: mobility,
      mobileLocationIdentifier: nonEmptyOrNull(
        glnFieldText('mobileLocationIdentifier'),
      ),
      glnTypes: List<String>.from(glnTypes),
      supplyChainRoles: _splitRoles(glnFieldText('supplyChainRoles')),
      locationRoles: _splitRoles(glnFieldText('locationRoles')),
      pharmaceuticalExtension: pharmaceuticalExtension,
    );

    setState(() => hasSubmittedForm = true);

    final cubit = glnCubit;
    if (cubit == null) {
      return;
    }
    if (widget.glnId != null) {
      cubit.updateGLN(widget.glnId!, gln);
    } else {
      cubit.createGLN(gln);
    }
  }
}
