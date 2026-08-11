import 'package:traqtrace_app/core/utils/gs1/check_digit_utils.dart';

import 'gtin_format.dart';

part 'gtin_core_validators.dart';
part 'gtin_product_validators.dart';
part 'gtin_indicator_location_validators.dart';
part 'gtin_regulatory_validators.dart';

abstract final class GtinFieldValidators {
  static final validateGtinCode = _GtinCoreValidators.validateGtinCode;
  static final validateGtinCodeOptional =
      _GtinCoreValidators.validateGtinCodeOptional;
  static final isGtinCodeValid = _GtinCoreValidators.isGtinCodeValid;
  static final canonicalGtin14FromInput =
      _GtinCoreValidators.canonicalGtin14FromInput;
  static final validGtinChipsData = _GtinCoreValidators.validGtinChipsData;
  static final validateProductName = _GtinCoreValidators.validateProductName;
  static final validateManufacturer = _GtinCoreValidators.validateManufacturer;
  static final validatePackSizeOptionalInt =
      _GtinCoreValidators.validatePackSizeOptionalInt;
  static final productNameRequired = _GtinCoreValidators.productNameRequired;
  static final manufacturerRequired = _GtinCoreValidators.manufacturerRequired;
  static final packSizeOptionalInt = _GtinCoreValidators.packSizeOptionalInt;
  static final validateBrandName = _GtinProductValidators.validateBrandName;
  static final validateFunctionalName =
      _GtinProductValidators.validateFunctionalName;
  static final validateTradeItemDescription =
      _GtinProductValidators.validateTradeItemDescription;
  static final validateGpcBrickCode =
      _GtinProductValidators.validateGpcBrickCode;
  static final validateIso3166Numeric3 =
      _GtinProductValidators.validateIso3166Numeric3;
  static final validateTargetMarketCountry =
      _GtinProductValidators.validateTargetMarketCountry;
  static final validateCountryOfOrigin =
      _GtinProductValidators.validateCountryOfOrigin;
  static final validateNetContentValueRequired =
      _GtinProductValidators.validateNetContentValueRequired;
  static final validateUomCode3Required =
      _GtinProductValidators.validateUomCode3Required;
  static final validateNetContentUomRequired =
      _GtinProductValidators.validateNetContentUomRequired;
  static final validateOptionalDecimalNonNegative =
      _GtinProductValidators.validateOptionalDecimalNonNegative;
  static final validateOptionalDecimalPositive =
      _GtinProductValidators.validateOptionalDecimalPositive;
  static final validateGrossWeightValue =
      _GtinProductValidators.validateGrossWeightValue;
  static final validateGrossWeightUom =
      _GtinProductValidators.validateGrossWeightUom;
  static final validateHeightValue = _GtinProductValidators.validateHeightValue;
  static final validateWidthValue = _GtinProductValidators.validateWidthValue;
  static final validateDepthValue = _GtinProductValidators.validateDepthValue;
  static final validateDimUom = _GtinProductValidators.validateDimUom;
  static final validateQuantityOfChildren =
      _GtinProductValidators.validateQuantityOfChildren;
  static final validateTotalQtyNextLower =
      _GtinProductValidators.validateTotalQtyNextLower;
  static final validateQuantityOfChildrenConditional =
      _GtinProductValidators.validateQuantityOfChildrenConditional;
  static final validateTotalQtyNextLowerConditional =
      _GtinProductValidators.validateTotalQtyNextLowerConditional;
  static final validateNextLowerLevelGtinConditional =
      _GtinProductValidators.validateNextLowerLevelGtinConditional;
  static final validateNextLowerLevelQuantityConditional =
      _GtinProductValidators.validateNextLowerLevelQuantityConditional;
  static final validateHasBatchNumberIndicator =
      _GtinIndicatorLocationValidators.validateHasBatchNumberIndicator;
  static final validateHasSerialNumberIndicator =
      _GtinIndicatorLocationValidators.validateHasSerialNumberIndicator;
  static final validateTradeItemRoleFlags =
      _GtinIndicatorLocationValidators.validateTradeItemRoleFlags;
  static final validatePackagingType =
      _GtinIndicatorLocationValidators.validatePackagingType;
  static final validateUnitOfMeasureTradeItem =
      _GtinIndicatorLocationValidators.validateUnitOfMeasureTradeItem;
  static final validateParentGtin =
      _GtinIndicatorLocationValidators.validateParentGtin;
  static final validateQuantityPerParent =
      _GtinIndicatorLocationValidators.validateQuantityPerParent;
  static final validateGln13 = _GtinIndicatorLocationValidators.validateGln13;
  static final validateInformationProviderGln =
      _GtinIndicatorLocationValidators.validateInformationProviderGln;
  static final validateManufacturerGln =
      _GtinIndicatorLocationValidators.validateManufacturerGln;
  static final validateInformationProviderName =
      _GtinIndicatorLocationValidators.validateInformationProviderName;
  static final validateCreatedBy =
      _GtinIndicatorLocationValidators.validateCreatedBy;
  static final validateUpdatedBy =
      _GtinIndicatorLocationValidators.validateUpdatedBy;
  static final validateTradeItemStatus =
      _GtinIndicatorLocationValidators.validateTradeItemStatus;
  static final validateProductStatus =
      _GtinIndicatorLocationValidators.validateProductStatus;
  static final validateMarketingAuthorizationNumber =
      _GtinRegulatoryValidators.validateMarketingAuthorizationNumber;
  static final validateGs1CompanyPrefixLengthHelper =
      _GtinRegulatoryValidators.validateGs1CompanyPrefixLengthHelper;
  static final validateGs1CompanyPrefix =
      _GtinRegulatoryValidators.validateGs1CompanyPrefix;
  static final validateItemReference =
      _GtinRegulatoryValidators.validateItemReference;
  static final validateAuthorizationValidityFromDate =
      _GtinRegulatoryValidators.validateAuthorizationValidityFromDate;
  static final validateAuthorizationValidityToDate =
      _GtinRegulatoryValidators.validateAuthorizationValidityToDate;
  static final mapUnitDescriptorToBackendPackagingLevel =
      _GtinRegulatoryValidators.mapUnitDescriptorToBackendPackagingLevel;
  static final validateUnitDescriptor =
      _GtinRegulatoryValidators.validateUnitDescriptor;
}

typedef GtinCodeChipsData = ({
  String structureLabel,
  String indicatorDigit,
  String canonical14,
  String checkDigit,
});
