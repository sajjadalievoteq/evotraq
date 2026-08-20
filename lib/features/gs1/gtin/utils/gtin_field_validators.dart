import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_core_validators.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_product_validators.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_indicator_location_validators.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_regulatory_validators.dart';

abstract final class GtinFieldValidators {
  static final validateGtinCode = GtinCoreValidators.validateGtinCode;
  static final validateGtinCodeOptional =
      GtinCoreValidators.validateGtinCodeOptional;
  static final isGtinCodeValid = GtinCoreValidators.isGtinCodeValid;
  static final canonicalGtin14FromInput =
      GtinCoreValidators.canonicalGtin14FromInput;
  static final validGtinChipsData = GtinCoreValidators.validGtinChipsData;
  static final validateProductName = GtinCoreValidators.validateProductName;
  static final validateManufacturer = GtinCoreValidators.validateManufacturer;
  static final validatePackSizeOptionalInt =
      GtinCoreValidators.validatePackSizeOptionalInt;
  static final productNameRequired = GtinCoreValidators.productNameRequired;
  static final manufacturerRequired = GtinCoreValidators.manufacturerRequired;
  static final packSizeOptionalInt = GtinCoreValidators.packSizeOptionalInt;
  static final validateBrandName = GtinProductValidators.validateBrandName;
  static final validateFunctionalName =
      GtinProductValidators.validateFunctionalName;
  static final validateTradeItemDescription =
      GtinProductValidators.validateTradeItemDescription;
  static final validateGpcBrickCode =
      GtinProductValidators.validateGpcBrickCode;
  static final validateIso3166Numeric3 =
      GtinProductValidators.validateIso3166Numeric3;
  static final validateTargetMarketCountry =
      GtinProductValidators.validateTargetMarketCountry;
  static final validateCountryOfOrigin =
      GtinProductValidators.validateCountryOfOrigin;
  static final validateNetContentValueRequired =
      GtinProductValidators.validateNetContentValueRequired;
  static final validateUomCode3Required =
      GtinProductValidators.validateUomCode3Required;
  static final validateNetContentUomRequired =
      GtinProductValidators.validateNetContentUomRequired;
  static final validateOptionalDecimalNonNegative =
      GtinProductValidators.validateOptionalDecimalNonNegative;
  static final validateOptionalDecimalPositive =
      GtinProductValidators.validateOptionalDecimalPositive;
  static final validateGrossWeightValue =
      GtinProductValidators.validateGrossWeightValue;
  static final validateGrossWeightUom =
      GtinProductValidators.validateGrossWeightUom;
  static final validateHeightValue = GtinProductValidators.validateHeightValue;
  static final validateWidthValue = GtinProductValidators.validateWidthValue;
  static final validateDepthValue = GtinProductValidators.validateDepthValue;
  static final validateDimUom = GtinProductValidators.validateDimUom;
  static final validateQuantityOfChildren =
      GtinProductValidators.validateQuantityOfChildren;
  static final validateTotalQtyNextLower =
      GtinProductValidators.validateTotalQtyNextLower;
  static final validateQuantityOfChildrenConditional =
      GtinProductValidators.validateQuantityOfChildrenConditional;
  static final validateTotalQtyNextLowerConditional =
      GtinProductValidators.validateTotalQtyNextLowerConditional;
  static final validateNextLowerLevelGtinConditional =
      GtinProductValidators.validateNextLowerLevelGtinConditional;
  static final validateNextLowerLevelQuantityConditional =
      GtinProductValidators.validateNextLowerLevelQuantityConditional;
  static final validateHasBatchNumberIndicator =
      GtinIndicatorLocationValidators.validateHasBatchNumberIndicator;
  static final validateHasSerialNumberIndicator =
      GtinIndicatorLocationValidators.validateHasSerialNumberIndicator;
  static final validateTradeItemRoleFlags =
      GtinIndicatorLocationValidators.validateTradeItemRoleFlags;
  static final validatePackagingType =
      GtinIndicatorLocationValidators.validatePackagingType;
  static final validateUnitOfMeasureTradeItem =
      GtinIndicatorLocationValidators.validateUnitOfMeasureTradeItem;
  static final validateParentGtin =
      GtinIndicatorLocationValidators.validateParentGtin;
  static final validateQuantityPerParent =
      GtinIndicatorLocationValidators.validateQuantityPerParent;
  static final validateGln13 = GtinIndicatorLocationValidators.validateGln13;
  static final validateInformationProviderGln =
      GtinIndicatorLocationValidators.validateInformationProviderGln;
  static final validateManufacturerGln =
      GtinIndicatorLocationValidators.validateManufacturerGln;
  static final validateInformationProviderName =
      GtinIndicatorLocationValidators.validateInformationProviderName;
  static final validateCreatedBy =
      GtinIndicatorLocationValidators.validateCreatedBy;
  static final validateUpdatedBy =
      GtinIndicatorLocationValidators.validateUpdatedBy;
  static final validateTradeItemStatus =
      GtinIndicatorLocationValidators.validateTradeItemStatus;
  static final validateProductStatus =
      GtinIndicatorLocationValidators.validateProductStatus;
  static final validateMarketingAuthorizationNumber =
      GtinRegulatoryValidators.validateMarketingAuthorizationNumber;
  static final validateGs1CompanyPrefixLengthHelper =
      GtinRegulatoryValidators.validateGs1CompanyPrefixLengthHelper;
  static final validateGs1CompanyPrefix =
      GtinRegulatoryValidators.validateGs1CompanyPrefix;
  static final validateItemReference =
      GtinRegulatoryValidators.validateItemReference;
  static final validateAuthorizationValidityFromDate =
      GtinRegulatoryValidators.validateAuthorizationValidityFromDate;
  static final validateAuthorizationValidityToDate =
      GtinRegulatoryValidators.validateAuthorizationValidityToDate;
  static final mapUnitDescriptorToBackendPackagingLevel =
      GtinRegulatoryValidators.mapUnitDescriptorToBackendPackagingLevel;
  static final validateUnitDescriptor =
      GtinRegulatoryValidators.validateUnitDescriptor;
}
