// API paths, query keys, JSON keys, and user-facing error copy for GLN-related services.

/// Master-data GLN REST API (prefix after [DioService.baseUrl]).
abstract final class GlnMasterDataApiConsts {
  static const String prefix = '/master-data/glns';
  static const String search = '$prefix/search';
  static const String searchAdvanced = '$prefix/search/advanced';
  static const String expiredLicenses = '$prefix/expired-licenses';
  static const String deriveIdentification = '$prefix/derive-identification';
  static const String codeSegment = 'code';

  static String byCodePath(String code) => '$prefix/$codeSegment/$code';
  static String parentChildrenPath(String parentGlnCode) =>
      '$prefix/parent/$parentGlnCode/children';
  static String validatePath(String glnCode) => '$prefix/validate/$glnCode';
}

/// GLN tobacco extension API (`/tobacco/gln`).
abstract final class GlnTobaccoExtensionApiConsts {
  static const String prefix = '/tobacco/gln';
  static const String search = '$prefix/search';
  static const String codeSegment = 'code';
  static const String glnSubPath = 'gln';
  static const String euTpdRegistered = '$prefix/eu-tpd-registered';
  static const String pactActRegistered = '$prefix/pact-act-registered';
  static const String uiIssuers = '$prefix/ui-issuers';
  static const String manufacturingFacilities = '$prefix/manufacturing-facilities';
  static const String firstRetailOutlets = '$prefix/first-retail-outlets';
  static const String bondedWarehouses = '$prefix/bonded-warehouses';
  static const String aeoCertified = '$prefix/aeo-certified';

  static String byGlnCodePath(String glnCode) => '$prefix/$codeSegment/$glnCode';
  static String byIdPath(int id) => '$prefix/$id';
  static String deleteByGlnIdPath(int glnId) => '$prefix/$glnSubPath/$glnId';
  static String existsPath(int glnId) => '$prefix/$glnSubPath/$glnId/exists';
  static String euEconomicOperatorPath(String eoId) =>
      '$prefix/eu-economic-operator/$eoId';
}

/// Shared HTTP / JSON keys for GLN services.
abstract final class GlnApiHttpConsts {
  static const String contentTypeJson = 'application/json';
  static const String bearerPrefix = 'Bearer ';
  static const String authorizationHeader = 'Authorization';
  static const String contentTypeHeader = 'Content-Type';
  static const String jsonKeyContent = 'content';
  static const String jsonKeyValid = 'valid';
  static const String jsonKeyIsValid = 'isValid';
  static const String jsonKeyGlnCode = 'glnCode';
}

/// Exception and log messages for [GLNService] and extension clients.
abstract final class GlnApiMessages {
  static const String noAuthToken = 'No authentication token found';
  static const String unexpectedListFormat =
      'Unexpected response format: GLN data not found in response';
  static const String unexpectedSearchFormat =
      'Unexpected response format: GLN data not found in search response';
  static const String unexpectedExpiredLicensesFormat =
      'Unexpected response format: GLN data not found in expired licenses response';
  static const String unexpectedChildGlnsFormat =
      'Unexpected response format: GLN data not found in child GLNs response';
  static const String authFailedLoginAgain =
      'Authentication failed: Please log in again';
  static const String authTokenInvalidOrExpired =
      'Authentication error: Token might be invalid or expired';

  static String failedToLoadGlns(Object? statusMessage) =>
      'Failed to load GLNs: $statusMessage';
  static String failedToGetGln(Object? statusMessage) =>
      'Failed to get GLN: $statusMessage';
  static String failedToGetGlnByCode(Object? statusMessage) =>
      'Failed to get GLN by code: $statusMessage';
  static String failedToCreateGln(Object? statusMessage) =>
      'Failed to create GLN: $statusMessage';
  static String failedToUpdateGln(Object? statusMessage) =>
      'Failed to update GLN: $statusMessage';
  static String failedToSearchGlns(Object? statusMessage) =>
      'Failed to search GLNs: $statusMessage';
  static String failedExpiredLicenses(Object? statusMessage) =>
      'Failed to get GLNs with expired licenses: $statusMessage';
  static String failedChildGlns(Object? statusMessage) =>
      'Failed to get child GLNs: $statusMessage';
  static String failedValidateGln(Object? statusMessage) =>
      'Failed to validate GLN code: $statusMessage';
  static String failedDeriveIdentification(Object? statusMessage) =>
      'Failed to derive GLN identification: $statusMessage';
}

abstract final class GlnTobaccoExtensionMessages {
  static String createFailed(int? code) =>
      'Failed to create GLN tobacco extension: $code';
  static String saveFailed(int? code) => 'Failed to save GLN tobacco extension: $code';
  static String fetchFailed(int? code) => 'Failed to fetch GLN tobacco extension: $code';
  static const String createRequiresGlnCodeOrId =
      'Either glnCode or glnId must be provided to create an extension';
  static String updateFailed(int? code) => 'Failed to update GLN tobacco extension: $code';
  static String deleteFailed(int? code) => 'Failed to delete GLN tobacco extension: $code';
  static String existsCheckFailed(int? code) =>
      'Failed to check GLN tobacco extension: $code';
  static String euTpdFailed(int? code) => 'Failed to fetch EU TPD registered: $code';
  static String pactActFailed(int? code) =>
      'Failed to fetch PACT Act registered: $code';
  static String uiIssuersFailed(int? code) => 'Failed to fetch UI issuers: $code';
  static String manufacturingFailed(int? code) =>
      'Failed to fetch manufacturing facilities: $code';
  static String retailOutletsFailed(int? code) =>
      'Failed to fetch first retail outlets: $code';
  static String bondedFailed(int? code) => 'Failed to fetch bonded warehouses: $code';
  static String aeoFailed(int? code) => 'Failed to fetch AEO certified: $code';
  static String euEoFailed(int? code) => 'Failed to fetch by EU EO ID: $code';
  static String searchFailed(int? code) => 'Failed to search GLN tobacco extensions: $code';
}
