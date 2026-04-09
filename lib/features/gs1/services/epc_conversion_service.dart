/// Interface for EPC conversion services
abstract class EPCConversionService {
  /// Converts a GTIN and serial number to an SGTIN EPC URI
  Future<String> convertSGTINToEPC(String gtin, String serial);
  
  /// Converts an SSCC to an SSCC EPC URI
  Future<String> convertSSCCToEPC(String sscc);
  
  /// Converts an SGTIN EPC URI to a GTIN
  Future<String> convertEPCToGTIN(String epcUri);
  
  /// Converts an SSCC EPC URI to an SSCC
  Future<String> convertEPCToSSCC(String epcUri);
  
  /// Converts a GLN and optional extension to a GLN EPC URI
  Future<String> convertGLNToEPC(String gln, String? extension);
  
  /// Converts a GLN EPC URI to a GLN
  Future<String> convertEPCToGLN(String epcUri);
  
  /// Extracts the serial number from an SGTIN EPC URI
  Future<String> extractSerialNumberFromEPC(String epcUri);
  
  /// Validates if a given string is a valid EPC URI
  Future<bool> isValidEPC(String epcUri);

  /// Converts a GTIN to a class-level EPC URI
  Future<String> convertGTINToClassEPC(String gtin);

  /// Converts a GS1 element string to an EPC URI
  Future<String> convertGS1ElementStringToEPC(String elementString);

  /// Converts an EPC URI to a GS1 element string
  Future<String> convertEPCToElementString(String epcUri);

  /// Determines the EPC type from an EPC URI
  Future<String?> getEPCType(String epcUri);

  /// Checks if an EPC URI is a class-level identifier
  Future<bool> isClassLevelEPC(String epcUri);

  /// Checks if an EPC URI is an instance-level identifier
  Future<bool> isInstanceLevelEPC(String epcUri);

  /// Converts a list of SGTIN EPC URIs to GTIN/Serial pairs
  Future<List<Map<String, String>>> convertEPCListToSGTINs(List<String> epcList);

  /// Converts a list of GTIN/Serial pairs to SGTIN EPC URIs
  Future<List<String>> convertSGTINsToEPCList(List<Map<String, String>> gtinSerialPairs);

  /// Converts an SGTIN EPC URI to both GTIN and serial as a map
  Future<Map<String, String>> convertEPCToSGTIN(String epcUri);
}