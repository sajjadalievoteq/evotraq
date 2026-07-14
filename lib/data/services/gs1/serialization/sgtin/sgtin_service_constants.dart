abstract final class SgtinServiceConstants {
  static const String pathBase = '/identifiers/sgtins';

  static const String pathBatch          = '$pathBase/batch';
  static const String pathStatus         = '$pathBase/status';
  static const String pathExpiring       = '$pathBase/expiring';
  static const String pathMarket         = '$pathBase/market';
  static const String pathSearch         = '$pathBase/search';
  static const String pathSearchAdvanced = '$pathBase/search/advanced';
  static const String pathValidate       = '$pathBase/validate';
  static const String pathCommission     = '$pathBase/commission-multiple';

  static String pathById(String id)                 => '$pathBase/$id';
  static const String pathBySerial                  = '$pathBase/serial';
  static const String pathByEpc                     = '$pathBase/epc';
  static const String pathByGtin                    = '$pathBase/gtin';
  static String pathByLocation(String gln)          => '$pathBase/location/$gln';
  static String pathBySscc(String sscc)             => '$pathBase/sscc/$sscc';
  static String pathCount(String gtin)              => '$pathBase/count/$gtin';
  static String pathGenerateSerial(String gtin)     => '$pathBase/generate-serial/$gtin';
  static const String pathItemStatus                = '$pathBase/serial/status';
  static String pathItemLocation(String sn)         => '$pathBase/$sn/location';
  static String pathItemPack(String sn)             => '$pathBase/$sn/pack';
  static const String pathItemDecommission          = '$pathBase/serial/decommission';
  static String pathItemTransitions(String id)       => '$pathBase/$id/transitions';

  static const String qEpcUri         = 'epcUri';
  static const String qGtin           = 'gtin';
  static const String qBatchLot       = 'batchLot';

  static const String headerContentType    = 'Content-Type';
  static const String headerAuthorization  = 'Authorization';
  static const String contentTypeJson      = 'application/json';

  static Map<String, String> authHeaders(String token) => {
    headerContentType:   contentTypeJson,
    headerAuthorization: 'Bearer $token',
  };

  static const int statusOk        = 200;
  static const int statusCreated   = 201;
  static const int statusNoContent = 204;
  static const int statusBadRequest = 400;
  static const int statusNotFound  = 404;
  static const int statusConflict  = 409;

  static const int    defaultPage          = 0;
  static const int    defaultSize          = 20;
  static const String defaultSortBy        = 'createdAt';
  static const String defaultSortDirection = 'DESC';

  static const String qPage           = 'page';
  static const String qSize           = 'size';
  static const String qSortBy         = 'sortBy';
  static const String qDirection      = 'direction';
  static const String qBatchLotNumber = 'batchLotNumber';
  static const String qStatus         = 'status';
  static const String qLocationId     = 'locationId';
  static const String qGtinId         = 'gtinId';
  static const String qGtinCode       = 'gtinCode';
  static const String qSerialNumber   = 'serialNumber';
  static const String qLocationName   = 'locationName';
  static const String qDate           = 'date';
  static const String qMarket         = 'market';
  static const String qRandomized     = 'randomized';

  static const String rContent       = 'content';
  static const String rTotalElements = 'totalElements';
  static const String rTotalPages    = 'totalPages';
  static const String rNumber        = 'number';
  static const String rSize          = 'size';
  static const String rFirst         = 'first';
  static const String rLast          = 'last';
  static const String rSerialNumber  = 'serialNumber';
  static const String rValid         = 'valid';
  static const String rCount         = 'count';
  static const String rMessage       = 'message';

  static const String bStatus          = 'status';
  static const String bGlnCode         = 'glnCode';
  static const String bSsccCode        = 'ssccCode';
  static const String bGtinCode        = 'gtinCode';
  static const String bSerialNumber    = 'serialNumber';
  static const String bQuantity        = 'quantity';
  static const String bBatchLotNumber  = 'batchLotNumber';
  static const String bExpiryDate      = 'expiryDate';
  static const String bCurrentLocation = 'currentLocation';
  static const String bReason          = 'reason';

  static const String errNoToken         = 'No authentication token found';
  static const String errLoadById        = 'Failed to load SGTIN';
  static const String errLoadBySerial    = 'Failed to load SGTIN by serial number';
  static const String errLoadAll         = 'Failed to load SGTINs';
  static const String errCreate          = 'Failed to create SGTIN';
  static const String errUpdate          = 'Failed to update SGTIN';
  static const String errDelete          = 'Failed to delete SGTIN';
  static const String errFindByGtin      = 'Failed to find SGTINs by GTIN';
  static const String errFindByBatch     = 'Failed to find SGTINs by batch/lot';
  static const String errFindByStatus    = 'Failed to find SGTINs by status';
  static const String errFindByLocation  = 'Failed to find SGTINs by location';
  static const String errFindBySscc      = 'Failed to find SGTINs by SSCC';
  static const String errFindExpiring    = 'Failed to find expiring SGTINs';
  static const String errFindByMarket    = 'Failed to find SGTINs by market';
  static const String errSearch          = 'Failed to search SGTINs';
  static const String errUpdateStatus    = 'Failed to update SGTIN status';
  static const String errAssignLocation  = 'Failed to assign SGTIN to location';
  static const String errPack            = 'Failed to pack SGTIN';
  static const String errGenSerial       = 'Failed to generate serial number';
  static const String errValidate        = 'Failed to validate SGTIN';
  static const String errCount           = 'Failed to count SGTINs';
  static const String errCommission      = 'Failed to commission SGTINs';
  static const String errDecommission    = 'Failed to decommission SGTIN';
  static const String errGetTransitions  = 'Failed to get available transitions';
  static const String errGtinNotFound    =
      'GTIN code not found in the system. Please use a valid GTIN.';
  static const String errDuplicateSerial =
      'Serial number already exists. Please use a different serial number.';
  static const String errInvalidData     =
      'Invalid SGTIN data. Please check all fields.';
}
