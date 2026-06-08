/// API constants for [SSCCService].

abstract final class SsccServiceConstants {

  static const String pathBase = '/identifiers/ssccs';



  static const String pathSearchAdvanced = '$pathBase/search/advanced';

  static const String pathValidate = '$pathBase/validate';

  static const String pathGenerate = '$pathBase/generate';

  static const String pathSearch = '$pathBase/search';

  static const String pathCompany = '$pathBase/company';

  static String pathCompanyPrefix(String prefix) =>
      '$pathBase/company-prefix/$prefix';



  static String pathById(String id) => '$pathBase/$id';

  static String pathByCode(String code) => '$pathBase/code/$code';

  static String pathHierarchy(String code) => '$pathBase/$code/hierarchy';

  static String pathStatus(String id) => '$pathBase/$id/status';

  static String pathTransitions(String id) => '$pathBase/$id/transitions';

  static String pathAggregation(String id) => '$pathBase/$id/aggregation';

  static String pathDisaggregate(int linkId) =>
      '$pathBase/aggregation/$linkId/disaggregate';

  static String pathAggregationByCode(String code) =>
      '$pathBase/code/$code/aggregation';

  static String pathContainerType(String type) => '$pathBase/container-type/$type';

  static String pathContainerStatus(String status) =>

      '$pathBase/status/$status';

  static String pathSourceLocation(String gln) =>

      '$pathBase/source-location/$gln';

  static String pathDestinationLocation(String gln) =>

      '$pathBase/destination-location/$gln';

  static const String pathPackedBetween = '$pathBase/packed-between';

  static const String pathShippedBetween = '$pathBase/shipped-between';



  static const String headerContentType = 'Content-Type';

  static const String headerAuthorization = 'Authorization';

  static const String contentTypeJson = 'application/json';



  /// Content-type-only header — auth is injected transparently by [DioService].
  static const Map<String, String> jsonHeaders = {
    headerContentType: contentTypeJson,
  };



  static const int statusOk = 200;

  static const int statusCreated = 201;

  static const int statusNoContent = 204;



  static const int defaultPage = 0;

  static const int defaultSize = 20;

  static const String defaultSortBy = 'createdAt';

  static const String defaultSortDirection = 'DESC';



  static const String qPage = 'page';

  static const String qSize = 'size';

  static const String qSortBy = 'sortBy';

  static const String qDirection = 'direction';

  static const String qSsccCode = 'ssccCode';

  static const String qContainerType = 'containerType';

  static const String qContainerStatus = 'containerStatus';

  static const String qSourceLocationName = 'sourceLocationName';

  static const String qDestinationLocationName = 'destinationLocationName';

  static const String qGs1CompanyPrefix = 'gs1CompanyPrefix';



  static const String rContent = 'content';

  static const String rTotalElements = 'totalElements';

  static const String rTotalPages = 'totalPages';

  static const String rNumber = 'number';

  static const String rLast = 'last';

  static const String rIsValid = 'isValid';

  static const String rAvailableTransitions = 'availableTransitions';



  static const String errNoToken = 'No authentication token found';

}

