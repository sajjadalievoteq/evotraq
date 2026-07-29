
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
