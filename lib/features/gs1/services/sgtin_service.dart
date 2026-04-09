import 'package:traqtrace_app/features/gs1/models/sgtin_model.dart';

/// Service interface for managing SGTINs (Serialized Global Trade Item Numbers)
abstract class SGTINService {  /// Retrieves a specific SGTIN by its ID
  Future<SGTIN> getSGTINById(String id);
  
  /// Retrieves a specific SGTIN by its serial number
  Future<SGTIN> getSGTINBySerialNumber(String serialNumber);
  
  /// Get all SGTINs with optional pagination
  Future<List<SGTIN>> getAllSGTINs({int page = 0, int size = 20});
  
  /// Creates a new SGTIN
  Future<SGTIN> createSGTIN(SGTIN sgtin);
    /// Updates an existing SGTIN
  Future<SGTIN> updateSGTIN(String id, SGTIN sgtin);
  
  /// Deletes an SGTIN by ID
  Future<void> deleteSGTIN(String id);
  
  /// Find SGTINs by GTIN code
  Future<List<SGTIN>> findSGTINsByGTIN(String gtinCode);
  
  /// Find SGTINs by batch/lot number
  Future<List<SGTIN>> findSGTINsByBatchLotNumber(String batchLotNumber);
  
  /// Find SGTINs by status
  Future<List<SGTIN>> findSGTINsByStatus(ItemStatus status);
  
  /// Find SGTINs by location GLN
  Future<List<SGTIN>> findSGTINsByLocation(String glnCode);
  
  /// Find SGTINs by SSCC container
  Future<List<SGTIN>> findSGTINsBySSCC(String ssccCode);
  
  /// Find SGTINs expiring before a specific date
  Future<List<SGTIN>> findSGTINsExpiringBefore(DateTime date);
  
  /// Find SGTINs by regulatory market
  Future<List<SGTIN>> findSGTINsByRegulatoryMarket(String regulatoryMarket);
  
  /// Search SGTINs by multiple criteria with pagination
  Future<List<SGTIN>> searchSGTINs({
    int? gtinId,
    String? batchLotNumber,
    ItemStatus? status,
    int? locationId,
    int page = 0,
    int size = 20,
  });

  /// Advanced search SGTINs with detailed filtering
  Future<Map<String, dynamic>> searchSGTINsAdvanced({
    String? gtinCode,
    String? serialNumber,
    String? batchLotNumber,
    ItemStatus? status,
    String? locationName,
    int page = 0,
    int size = 20,
    String sortBy = 'createdAt',
    String sortDirection = 'DESC',
  });
  
  /// Update the status of an SGTIN
  Future<SGTIN> updateSGTINStatus(String serialNumber, ItemStatus newStatus);
  
  /// Assign an SGTIN to a location
  Future<SGTIN> assignSGTINToLocation(String serialNumber, String glnCode);
  
  /// Pack an SGTIN into an SSCC container
  Future<SGTIN> packSGTINIntoSSCC(String serialNumber, String ssccCode);
  
  /// Generate a valid serial number for a GTIN
  Future<String> generateSerialNumber(String gtinCode, {bool randomized = true});
  
  /// Validate a combination of GTIN and serial number
  Future<bool> validateSGTIN(String gtinCode, String serialNumber);
  
  /// Count SGTINs by GTIN and status
  Future<int> countSGTINsByGTINAndStatus(String gtinCode, ItemStatus status);
  
  /// Commission multiple SGTINs with the same details
  Future<List<SGTIN>> commissionMultipleSGTINs({
    required String gtinCode,
    required int quantity,
    required String batchLotNumber,
    required DateTime expiryDate,
    String? currentLocation,
  });
  
  /// Decommission an SGTIN with a reason
  Future<SGTIN> decommissionSGTIN(String serialNumber, String reason);
}