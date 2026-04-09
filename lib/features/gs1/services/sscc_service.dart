// filepath: c:\Code\traqTrace\frontend\traqtrace_app\lib\features\gs1\services\sscc_service.dart
import 'package:traqtrace_app/features/gs1/models/sscc_model.dart';

/// Service interface for managing SSCC (Serial Shipping Container Code) operations
abstract class SSCCService {
  /// Create a new SSCC
  Future<SSCC> createSSCC(SSCC sscc);
  
  /// Get an SSCC by its ID
  Future<SSCC> getSSCCById(String id); // Changed from int to String for UUID
  
  /// Get an SSCC by its code
  Future<SSCC> getSSCCByCode(String ssccCode);
  
  /// Get all SSCCs (with optional pagination)
  Future<List<SSCC>> getAllSSCCs({int page = 0, int size = 20});
  
  /// Update an SSCC
  Future<SSCC> updateSSCC(String id, SSCC ssccDetails); // Changed from int to String for UUID
  
  /// Delete an SSCC
  Future<void> deleteSSCC(String id); // Changed from int to String for UUID
  
  /// Find SSCCs by container type
  Future<List<SSCC>> findSSCCsByContainerType(ContainerType containerType);
  
  /// Find SSCCs by container status
  Future<List<SSCC>> findSSCCsByContainerStatus(ContainerStatus containerStatus);
  
  /// Find SSCCs by source location
  Future<List<SSCC>> findSSCCsBySourceLocation(String sourceGlnCode);
  
  /// Find SSCCs by destination location
  Future<List<SSCC>> findSSCCsByDestinationLocation(String destinationGlnCode);
  
  /// Find SSCCs packed between a date range
  Future<List<SSCC>> findSSCCsPackedBetween(DateTime startDate, DateTime endDate);
  
  /// Find SSCCs shipped between a date range
  Future<List<SSCC>> findSSCCsShippedBetween(DateTime startDate, DateTime endDate);
  
  /// Find child SSCCs for a parent SSCC
  Future<List<SSCC>> findChildSSCCs(String parentSsccCode);
  
  /// Find SSCCs by GS1 company prefix
  Future<List<SSCC>> findSSCCsByGs1CompanyPrefix(String gs1CompanyPrefix);
  
  /// Search SSCCs by multiple criteria
  Future<List<SSCC>> searchSSCCs({
    ContainerType? containerType,
    ContainerStatus? containerStatus,
    String? sourceLocationId, // Changed from int to String for UUID
    String? destinationLocationId, // Changed from int to String for UUID
  });
  
  /// Update the status of an SSCC
  Future<SSCC> updateSSCCStatus(String id, ContainerStatus newStatus); // Changed to accept ID instead of code
  
  /// Validate an SSCC code
  Future<bool> validateSSCCCode(String ssccCode);
  
  /// Generate a valid SSCC code with specified company prefix and extension digit
  Future<String> generateSSCCCode(String gs1CompanyPrefix, String extensionDigit);
  
  /// Extract GS1 Company Prefix from a GLN code
  Future<String> extractCompanyPrefixFromGLN(String glnCode);

  /// Advanced search SSCCs with detailed filtering
  Future<Map<String, dynamic>> searchSSCCsAdvanced({
    String? ssccCode,
    String? containerType,
    String? containerStatus,
    String? sourceLocationName,
    String? destinationLocationName,
    String? gs1CompanyPrefix,
    int page = 0,
    int size = 20,
    String sortBy = 'ssccCode',
    String direction = 'ASC',
  });
}