import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_model.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_field_validators.dart';






mixin GtinDetailScreenFields {
  static final DateFormat _dateFmt = DateFormat('yyyy-MM-dd');
  static final DateFormat _dateTimeNoOffsetFmt =
      DateFormat('yyyy-MM-dd / HH:mm:ss');

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

  
  TextEditingController get gtinCodeController => _c('gtinCode');

  
  TextEditingController get brandNameController => _c('brandName');
  TextEditingController get manufacturerController => _c('manufacturer');
  TextEditingController get unitDescriptorController => _c('unitDescriptor');
  TextEditingController get packSizeController => _c('packSize');
  String? productStatus;

  
  TextEditingController get registrationNumberController =>
      _c('registrationNumber');
  TextEditingController get registrationDateDisplayController =>
      _c('registrationDateDisplay');
  TextEditingController get expirationDateDisplayController =>
      _c('expirationDateDisplay');
  DateTime? registrationDate;
  DateTime? expirationDate;

  
  TextEditingController get functionalNameController => _c('functionalName');
  TextEditingController get tradeItemDescriptionController =>
      _c('tradeItemDescription');
  TextEditingController get gpcBrickCodeController => _c('gpcBrickCode');
  TextEditingController get targetMarketCountryController =>
      _c('targetMarketCountry');

  
  TextEditingController get nextLowerLevelGtinController =>
      _c('nextLowerLevelGtin');
  TextEditingController get nextLowerLevelQuantityController =>
      _c('nextLowerLevelQuantity');
  TextEditingController get quantityOfChildrenController =>
      _c('quantityOfChildren');
  TextEditingController get totalQtyNextLowerController =>
      _c('totalQtyNextLower');
  TextEditingController get launchDateDisplayController =>
      _c('launchDateDisplay');
  DateTime? launchDate;
  bool isBaseUnit = false;
  bool isConsumerUnit = false;
  bool isOrderableUnit = false;
  bool isDespatchUnit = false;
  bool isInvoiceUnit = false;
  bool isVariableUnit = false;

  
  TextEditingController get netContentController => _c('netContent');
  TextEditingController get netContentUomController => _c('netContentUom');
  TextEditingController get grossWeightController => _c('grossWeight');
  TextEditingController get grossWeightUomController => _c('grossWeightUom');
  TextEditingController get heightController => _c('height');
  TextEditingController get widthController => _c('width');
  TextEditingController get depthController => _c('depth');
  TextEditingController get dimUomController => _c('dimUom');

  
  TextEditingController get countryOfOriginController => _c('countryOfOrigin');

  
  TextEditingController get informationProviderNameController =>
      _c('informationProviderName');
  GLN? informationProviderGln;
  GLN? manufacturerGln;

  
  TextEditingController get effectiveDateDisplayController =>
      _c('effectiveDateDisplay');
  TextEditingController get startAvailDateDisplayController =>
      _c('startAvailDateDisplay');
  TextEditingController get endAvailDateDisplayController =>
      _c('endAvailDateDisplay');
  TextEditingController get publicationDateDisplayController =>
      _c('publicationDateDisplay');
  String? tradeItemStatus;
  DateTime? effectiveDate;
  DateTime? startAvailDate;
  DateTime? endAvailDate;
  DateTime? publicationDate;

  
  String? hasBatchNumberIndicator;
  String? hasSerialNumberIndicator;

  
  TextEditingController get createdByController => _c('createdBy');
  TextEditingController get updatedByController => _c('updatedBy');

  void initGtinDetailFields({required bool isUpdate}) {
    productStatus = 'ACTIVE';
    tradeItemStatus = isUpdate ? 'CHN' : 'ADD';
    if (!isUpdate) {
      effectiveDate = DateTime.now();
      _setSeedOrController(
        'effectiveDateDisplay',
        formatDateTimeWithOffset(effectiveDate!),
      );
    }
    hasBatchNumberIndicator = 'REQUESTED_BY_LAW';
    hasSerialNumberIndicator = 'REQUESTED_BY_LAW';
  }

  void disposeGtinDetailFields() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _controllers.clear();
    _seedTexts.clear();
  }

  String formatDateTimeWithOffset(DateTime dt) {
    final local = dt.toLocal();
    final base = _dateTimeNoOffsetFmt.format(local);
    final off = local.timeZoneOffset;
    final sign = off.isNegative ? '-' : '+';
    final abs = off.abs();
    final hh = abs.inHours.toString().padLeft(2, '0');
    final mm = (abs.inMinutes % 60).toString().padLeft(2, '0');
    return '$base$sign$hh:$mm';
  }

  String formatDate(DateTime dt) => _dateFmt.format(dt.toLocal());

  void hydrateGtinDetailFields(GTIN gtin, {required String? docUnitDescriptor}) {
    _setSeedOrController('gtinCode', gtin.gtinCode);
    _setSeedOrController('brandName', gtin.productName);
    _setSeedOrController('manufacturer', gtin.manufacturer ?? '');
    _setSeedOrController('unitDescriptor', docUnitDescriptor ?? '');
    _setSeedOrController('packSize', gtin.packSize?.toString() ?? '');
    productStatus = gtin.status?.toUpperCase() ?? 'ACTIVE';

    _setSeedOrController('registrationNumber', gtin.registrationNumber ?? '');
    registrationDate = gtin.registrationDate;
    expirationDate = gtin.expirationDate;
    _setSeedOrController(
      'registrationDateDisplay',
      registrationDate == null ? '' : formatDate(registrationDate!),
    );
    _setSeedOrController(
      'expirationDateDisplay',
      expirationDate == null ? '' : formatDate(expirationDate!),
    );

    _setSeedOrController('functionalName', gtin.functionalName ?? '');
    _setSeedOrController(
      'tradeItemDescription',
      gtin.tradeItemDescription ?? '',
    );
    _setSeedOrController('gpcBrickCode', gtin.gpcBrickCode ?? '');
    _setSeedOrController('targetMarketCountry', gtin.targetMarketCountry ?? '');

    _setSeedOrController('nextLowerLevelGtin', gtin.nextLowerLevelGtin ?? '');
    _setSeedOrController(
      'nextLowerLevelQuantity',
      gtin.nextLowerLevelQuantity?.toString() ?? '',
    );
    _setSeedOrController(
      'quantityOfChildren',
      gtin.quantityOfChildren?.toString() ?? '',
    );
    _setSeedOrController(
      'totalQtyNextLower',
      gtin.totalQtyNextLower?.toString() ?? '',
    );
    launchDate = gtin.launchDate;
    _setSeedOrController(
      'launchDateDisplay',
      launchDate == null ? '' : formatDate(launchDate!),
    );
    isBaseUnit = gtin.isBaseUnit ?? false;
    isConsumerUnit = gtin.isConsumerUnit ?? false;
    isOrderableUnit = gtin.isOrderableUnit ?? false;
    isDespatchUnit = gtin.isDespatchUnit ?? false;
    isInvoiceUnit = gtin.isInvoiceUnit ?? false;
    isVariableUnit = gtin.isVariableUnit ?? false;

    _setSeedOrController(
      'netContent',
      gtin.netContentValue?.toString() ?? '',
    );
    _setSeedOrController('netContentUom', gtin.netContentUom ?? '');
    _setSeedOrController(
      'grossWeight',
      gtin.grossWeightValue?.toString() ?? '',
    );
    _setSeedOrController('grossWeightUom', gtin.grossWeightUom ?? '');
    _setSeedOrController('height', gtin.heightValue?.toString() ?? '');
    _setSeedOrController('width', gtin.widthValue?.toString() ?? '');
    _setSeedOrController('depth', gtin.depthValue?.toString() ?? '');
    _setSeedOrController('dimUom', gtin.dimUom ?? '');

    _setSeedOrController('countryOfOrigin', gtin.countryOfOrigin ?? '');

    _setSeedOrController(
      'informationProviderName',
      gtin.informationProviderName ?? '',
    );
    informationProviderGln = _glnFromCode(gtin.informationProviderGln);
    manufacturerGln = _glnFromCode(gtin.manufacturerGln);

    tradeItemStatus = gtin.tradeItemStatus ?? tradeItemStatus;
    if (gtin.effectiveDate != null) {
      effectiveDate = gtin.effectiveDate;
      _setSeedOrController(
        'effectiveDateDisplay',
        formatDateTimeWithOffset(gtin.effectiveDate!),
      );
    }
    startAvailDate = gtin.startAvailDate;
    _setSeedOrController(
      'startAvailDateDisplay',
      startAvailDate == null ? '' : formatDateTimeWithOffset(startAvailDate!),
    );
    endAvailDate = gtin.endAvailDate;
    _setSeedOrController(
      'endAvailDateDisplay',
      endAvailDate == null ? '' : formatDateTimeWithOffset(endAvailDate!),
    );
    publicationDate = gtin.publicationDate;
    _setSeedOrController(
      'publicationDateDisplay',
      publicationDate == null ? '' : formatDate(publicationDate!),
    );

    hasBatchNumberIndicator =
        gtin.hasBatchNumberIndicator ?? 'REQUESTED_BY_LAW';
    hasSerialNumberIndicator =
        gtin.hasSerialNumberIndicator ?? 'REQUESTED_BY_LAW';

    _setSeedOrController('createdBy', gtin.createdBy ?? '');
    _setSeedOrController('updatedBy', gtin.updatedBy ?? '');
  }

  GLN? _glnFromCode(String? code) {
    if (code == null || code.trim().isEmpty) return null;
    return GLN.fromCode(code.trim());
  }

  String? _trimOrNull(String s) {
    final t = s.trim();
    return t.isEmpty ? null : t;
  }

  int? _intOrNullText(String s) =>
      s.trim().isEmpty ? null : int.tryParse(s.trim());

  double? _doubleOrNullText(String s) =>
      s.trim().isEmpty ? null : double.tryParse(s.trim());

  
  String? validateGtinFieldsForSave({required bool isReadOnly}) {
    if (isReadOnly) return null;
    return GtinFieldValidators.validateProductName(_text('brandName')) ??
        GtinFieldValidators.validateManufacturer(_text('manufacturer')) ??
        GtinFieldValidators.validateUnitDescriptor(
          _text('unitDescriptor').isEmpty ? null : _text('unitDescriptor'),
        );
  }

  GTIN buildGtinFromFields({required String gtinCode}) {
    final ud = _text('unitDescriptor').trim();
    return GTIN(
      gtinCode: gtinCode,
      productName: _text('brandName'),
      manufacturer: _text('manufacturer').trim(),
      unitDescriptor: ud.isEmpty ? null : ud,
      packagingLevel: ud.isEmpty
          ? null
          : GtinFieldValidators.mapUnitDescriptorToBackendPackagingLevel(ud),
      packSize: _intOrNullText(_text('packSize')),
      status: productStatus ?? 'ACTIVE',
      registrationNumber: _trimOrNull(_text('registrationNumber')),
      registrationDate: registrationDate,
      expirationDate: expirationDate,
      functionalName: _trimOrNull(_text('functionalName')),
      tradeItemDescription: _trimOrNull(_text('tradeItemDescription')),
      gpcBrickCode: _trimOrNull(_text('gpcBrickCode')),
      targetMarketCountry: _trimOrNull(_text('targetMarketCountry')),
      nextLowerLevelGtin: _trimOrNull(_text('nextLowerLevelGtin')),
      nextLowerLevelQuantity: _intOrNullText(_text('nextLowerLevelQuantity')),
      quantityOfChildren: _intOrNullText(_text('quantityOfChildren')),
      totalQtyNextLower: _intOrNullText(_text('totalQtyNextLower')),
      launchDate: launchDate,
      isBaseUnit: isBaseUnit,
      isConsumerUnit: isConsumerUnit,
      isOrderableUnit: isOrderableUnit,
      isDespatchUnit: isDespatchUnit,
      isInvoiceUnit: isInvoiceUnit,
      isVariableUnit: isVariableUnit,
      netContentValue: _doubleOrNullText(_text('netContent')),
      netContentUom: _trimOrNull(_text('netContentUom')),
      grossWeightValue: _doubleOrNullText(_text('grossWeight')),
      grossWeightUom: _trimOrNull(_text('grossWeightUom')),
      heightValue: _doubleOrNullText(_text('height')),
      widthValue: _doubleOrNullText(_text('width')),
      depthValue: _doubleOrNullText(_text('depth')),
      dimUom: _trimOrNull(_text('dimUom')),
      countryOfOrigin: _trimOrNull(_text('countryOfOrigin')),
      informationProviderGln: informationProviderGln?.glnCode,
      informationProviderName: _trimOrNull(_text('informationProviderName')),
      manufacturerGln: manufacturerGln?.glnCode,
      tradeItemStatus: tradeItemStatus,
      effectiveDate: effectiveDate,
      startAvailDate: startAvailDate,
      endAvailDate: endAvailDate,
      publicationDate: publicationDate,
      hasBatchNumberIndicator: hasBatchNumberIndicator,
      hasSerialNumberIndicator: hasSerialNumberIndicator,
      createdBy: _trimOrNull(_text('createdBy')),
      updatedBy: _trimOrNull(_text('updatedBy')),
    );
  }

  
  int get allocatedGtinControllerCount => _controllers.length;
}
