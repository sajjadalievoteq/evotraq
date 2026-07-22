import 'package:flutter/material.dart';



mixin GlnDetailScreenFields {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _seedTexts = {};

  TextEditingController _c(String key) => _controllers[key] ??=
      TextEditingController(text: _seedTexts[key] ?? '');

  String _text(String key) =>
      _controllers[key]?.text ?? _seedTexts[key] ?? '';

  void _setSeedOrController(String key, String value) {
    _seedTexts[key] = value;
    final existing = _controllers[key];
    if (existing != null) {
      existing.text = value;
    }
  }

  void _clearField(String key) {
    _seedTexts[key] = '';
    _controllers[key]?.clear();
  }

  void disposeGlnDetailFields() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _controllers.clear();
    _seedTexts.clear();
  }

  int get allocatedGlnControllerCount => _controllers.length;

  TextEditingController get glnCodeController => _c('glnCode');
  TextEditingController get gs1CompanyPrefixController =>
      _c('gs1CompanyPrefix');
  TextEditingController get locationReferenceDigitsController =>
      _c('locationReferenceDigits');
  TextEditingController get checkDigitController => _c('checkDigit');
  TextEditingController get parentGlnCodeController => _c('parentGlnCode');
  TextEditingController get glnExtensionComponentController =>
      _c('glnExtensionComponent');
  TextEditingController get locationNameController => _c('locationName');
  TextEditingController get addressLine1Controller => _c('addressLine1');
  TextEditingController get addressLine2Controller => _c('addressLine2');
  TextEditingController get cityController => _c('city');
  TextEditingController get stateProvinceController => _c('stateProvince');
  TextEditingController get postalCodeController => _c('postalCode');
  TextEditingController get countryController => _c('country');
  TextEditingController get mobileLocationIdentifierController =>
      _c('mobileLocationIdentifier');
  TextEditingController get registeredLegalNameController =>
      _c('registeredLegalName');
  TextEditingController get tradingNameController => _c('tradingName');
  TextEditingController get leiCodeController => _c('leiCode');
  TextEditingController get taxRegistrationNumberController =>
      _c('taxRegistrationNumber');
  TextEditingController get countryOfIncorporationNumericController =>
      _c('countryOfIncorporationNumeric');
  TextEditingController get websiteController => _c('website');
  TextEditingController get contactNameController => _c('contactName');
  TextEditingController get contactEmailController => _c('contactEmail');
  TextEditingController get contactPhoneController => _c('contactPhone');
  TextEditingController get digitalAddressValueController =>
      _c('digitalAddressValue');
  TextEditingController get supplyChainRolesController =>
      _c('supplyChainRoles');
  TextEditingController get locationRolesController => _c('locationRoles');
  TextEditingController get licenseNumberController => _c('licenseNumber');
  TextEditingController get licenseTypeController => _c('licenseType');

  void seedGlnFieldTexts({
    required String glnCode,
    required String gs1CompanyPrefix,
    required String locationReferenceDigits,
    required String checkDigit,
    required String parentGlnCode,
    required String glnExtensionComponent,
    required String locationName,
    required String addressLine1,
    required String addressLine2,
    required String city,
    required String stateProvince,
    required String postalCode,
    required String country,
    required String mobileLocationIdentifier,
    required String registeredLegalName,
    required String tradingName,
    required String leiCode,
    required String taxRegistrationNumber,
    required String countryOfIncorporationNumeric,
    required String website,
    required String contactName,
    required String contactEmail,
    required String contactPhone,
    required String digitalAddressValue,
    required String supplyChainRoles,
    required String locationRoles,
    required String licenseNumber,
    required String licenseType,
  }) {
    _setSeedOrController('glnCode', glnCode);
    _setSeedOrController('gs1CompanyPrefix', gs1CompanyPrefix);
    _setSeedOrController('locationReferenceDigits', locationReferenceDigits);
    _setSeedOrController('checkDigit', checkDigit);
    _setSeedOrController('parentGlnCode', parentGlnCode);
    _setSeedOrController('glnExtensionComponent', glnExtensionComponent);
    _setSeedOrController('locationName', locationName);
    _setSeedOrController('addressLine1', addressLine1);
    _setSeedOrController('addressLine2', addressLine2);
    _setSeedOrController('city', city);
    _setSeedOrController('stateProvince', stateProvince);
    _setSeedOrController('postalCode', postalCode);
    _setSeedOrController('country', country);
    _setSeedOrController('mobileLocationIdentifier', mobileLocationIdentifier);
    _setSeedOrController('registeredLegalName', registeredLegalName);
    _setSeedOrController('tradingName', tradingName);
    _setSeedOrController('leiCode', leiCode);
    _setSeedOrController('taxRegistrationNumber', taxRegistrationNumber);
    _setSeedOrController(
      'countryOfIncorporationNumeric',
      countryOfIncorporationNumeric,
    );
    _setSeedOrController('website', website);
    _setSeedOrController('contactName', contactName);
    _setSeedOrController('contactEmail', contactEmail);
    _setSeedOrController('contactPhone', contactPhone);
    _setSeedOrController('digitalAddressValue', digitalAddressValue);
    _setSeedOrController('supplyChainRoles', supplyChainRoles);
    _setSeedOrController('locationRoles', locationRoles);
    _setSeedOrController('licenseNumber', licenseNumber);
    _setSeedOrController('licenseType', licenseType);
  }

  void clearGlnFieldTexts() {
    for (final key in [
      'glnCode',
      'gs1CompanyPrefix',
      'locationReferenceDigits',
      'checkDigit',
      'parentGlnCode',
      'glnExtensionComponent',
      'locationName',
      'addressLine1',
      'addressLine2',
      'city',
      'stateProvince',
      'postalCode',
      'country',
      'mobileLocationIdentifier',
      'registeredLegalName',
      'tradingName',
      'leiCode',
      'taxRegistrationNumber',
      'countryOfIncorporationNumeric',
      'website',
      'contactName',
      'contactEmail',
      'contactPhone',
      'digitalAddressValue',
      'supplyChainRoles',
      'locationRoles',
      'licenseNumber',
      'licenseType',
    ]) {
      _clearField(key);
    }
  }

  
  String glnFieldText(String key) => _text(key);
}
