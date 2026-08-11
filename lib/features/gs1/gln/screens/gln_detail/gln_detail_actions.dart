part of 'gln_detail_screen.dart';

extension GlnDetailActions on _GLNDetailScreenState {
  Future<void> _refresh() async {
    if (widget.glnId != null) {
      _glnCubit?.fetchGLNById(widget.glnId!);
    }
  }

  void _applyGlnToLocalState(GLN g) {
    _licenseValidFrom = g.licenseValidFrom;
    _licenseExpiry = g.licenseExpiry;
    _effectiveFrom = g.effectiveFrom;
    _effectiveTo = g.effectiveTo;
    _nonReuseUntil = g.nonReuseUntil;
    _coordinates = g.coordinates;
  }

  void _populateFromGln(GLN? g) {
    if (g == null) {
      clearGlnFieldTexts();

      _operatingStatus = 'ACTIVE';
      _industryClassification = 'HEALTHCARE';
      _glnSource = 'SELF_ALLOCATED';
      _mobility = 'FIXED';
      _digitalAddressType = 'URL';
      _locationTypeLabel = 'Other';
      _glnTypes = ['FIXED_PHYSICAL'];
      _licenseValidFrom = null;
      _licenseExpiry = null;
      _effectiveFrom = null;
      _effectiveTo = null;
      _nonReuseUntil = null;
      _coordinates = null;
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

    _operatingStatus = (g.operatingStatus ?? 'ACTIVE').toUpperCase();
    _industryClassification = g.industryClassification ?? 'HEALTHCARE';
    _glnSource = g.glnSource ?? 'SELF_ALLOCATED';
    _mobility = g.mobility ?? 'FIXED';
    _digitalAddressType = g.digitalAddressType ?? 'URL';
    _locationTypeLabel = GlnLocationTypeMapper.toDropdownLabel(g.locationType);
    _glnTypes = g.glnTypes.isEmpty
        ? ['FIXED_PHYSICAL']
        : List<String>.from(g.glnTypes);

    _applyGlnToLocalState(g);
  }

  void _maybeHydrateFromGln(GLN? g) {
    if (widget.glnId != null && g == null) {
      return;
    }
    final tag = widget.glnId == null ? 'create' : g!.glnCode;
    if (_hydratedTag == tag) {
      return;
    }
    _hydratedTag = tag;
    _populateFromGln(g);
    _formFieldsHydrated = true;
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

  Future<void> _pickDate(
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

  Future<void> _submitForm() async {
    if (widget.awaitingListSelection) return;
    if (_glnTypes.isEmpty) {
      setState(() {
        _glnTypesErrorText = GlnUiConstants.errorSelectGlnType;
      });
      context.showError(GlnUiConstants.errorFixForm);
      return;
    }
    setState(() => _glnTypesErrorText = null);

    if (!_forceMountAllSections) {
      setState(() => _forceMountAllSections = true);
      await Future<void>.delayed(Duration.zero);
      if (!mounted) return;
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
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

    final isValid = _validationCubit.validateAllFields({
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

    final operatingStatus = _operatingStatus.toUpperCase();
    final active = operatingStatus == 'ACTIVE';

    final parentRaw = GlnFormat.stripGlnInput(glnFieldText('parentGlnCode'));
    final parentGln = parentRaw.length == 13 ? GLN.fromCode(parentRaw) : null;

    GLNPharmaceuticalExtension? pharmaceuticalExtension;
    final pharmaSt = _pharmaExtensionKey.currentState;
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
      addressLine2: _nonEmptyOrNull(glnFieldText('addressLine2')),
      city: city,
      stateProvince: stateProvince,
      postalCode: postalCode,
      country: country,
      contactName: _nonEmptyOrNull(glnFieldText('contactName')),
      contactEmail: _nonEmptyOrNull(glnFieldText('contactEmail')),
      contactPhone: _nonEmptyOrNull(glnFieldText('contactPhone')),
      locationType: GlnLocationTypeMapper.parseDropdown(_locationTypeLabel),
      parentGln: parentGln,
      licenseNumber: _nonEmptyOrNull(glnFieldText('licenseNumber')),
      licenseType: _nonEmptyOrNull(glnFieldText('licenseType')),
      licenseValidFrom: _licenseValidFrom,
      licenseExpiry: _licenseExpiry,
      active: active,
      coordinates: _coordinates,
      operatingStatus: operatingStatus,
      effectiveFrom: _effectiveFrom,
      effectiveTo: _effectiveTo,
      nonReuseUntil: _nonReuseUntil,
      gs1CompanyPrefix: _nonEmptyOrNull(glnFieldText('gs1CompanyPrefix')),
      locationReferenceDigits: _nonEmptyOrNull(
        glnFieldText('locationReferenceDigits'),
      ),
      checkDigit: _nonEmptyOrNull(glnFieldText('checkDigit')),
      registeredLegalName: _nonEmptyOrNull(glnFieldText('registeredLegalName')),
      tradingName: _nonEmptyOrNull(glnFieldText('tradingName')),
      leiCode: _nonEmptyOrNull(glnFieldText('leiCode')),
      taxRegistrationNumber: _nonEmptyOrNull(
        glnFieldText('taxRegistrationNumber'),
      ),
      countryOfIncorporationNumeric: _nonEmptyOrNull(
        glnFieldText('countryOfIncorporationNumeric').trim(),
      ),
      website: _nonEmptyOrNull(glnFieldText('website')),
      digitalAddressType: _digitalAddressType,
      digitalAddressValue: _nonEmptyOrNull(glnFieldText('digitalAddressValue')),
      glnExtensionComponent: _nonEmptyOrNull(
        glnFieldText('glnExtensionComponent'),
      ),
      industryClassification: _industryClassification,
      glnSource: _glnSource,
      mobility: _mobility,
      mobileLocationIdentifier: _nonEmptyOrNull(
        glnFieldText('mobileLocationIdentifier'),
      ),
      glnTypes: List<String>.from(_glnTypes),
      supplyChainRoles: _splitRoles(glnFieldText('supplyChainRoles')),
      locationRoles: _splitRoles(glnFieldText('locationRoles')),
      pharmaceuticalExtension: pharmaceuticalExtension,
    );

    setState(() => _hasSubmittedForm = true);

    final cubit = _glnCubit;
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
