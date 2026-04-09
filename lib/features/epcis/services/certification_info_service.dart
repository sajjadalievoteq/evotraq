import 'package:traqtrace_app/features/epcis/models/certification_info.dart';

/// Service interface for CertificationInfo operations
abstract class CertificationInfoService {
  /// Get all certification information records
  /// 
  /// Returns a list of all certification information records
  Future<List<CertificationInfo>> getAllCertifications();
  
  /// Get paginated certification information
  /// 
  /// [page] is the page number (0-indexed)
  /// [size] is the number of records per page
  /// Returns a page of certification information records
  Future<Map<String, dynamic>> getAllCertificationsPaginated(int page, int size);
  
  /// Get a certification record by ID
  /// 
  /// [id] is the certification record ID
  /// Returns the certification record or throws an exception if not found
  Future<CertificationInfo> getCertificationById(String id);
  
  /// Create a new certification record
  /// 
  /// [certificationInfo] is the certification record to create
  /// Returns the created certification record
  Future<CertificationInfo> createCertification(CertificationInfo certificationInfo);
  
  /// Update an existing certification record
  /// 
  /// [id] is the ID of the certification record to update
  /// [certificationInfo] contains the updated data
  /// Returns the updated certification record
  Future<CertificationInfo> updateCertification(String id, CertificationInfo certificationInfo);
  
  /// Delete a certification record by ID
  /// 
  /// [id] is the ID of the certification record to delete
  Future<void> deleteCertification(String id);
  
  /// Get certification records by event ID
  /// 
  /// [eventId] is the ID of the EPCIS event
  /// Returns certification records associated with the event
  Future<List<CertificationInfo>> getCertificationsByEventId(String eventId);
  
  /// Get certification records by certification type
  /// 
  /// [type] is the type of certification (e.g., "Organic", "Fair Trade")
  /// Returns certification records of the specified type
  Future<List<CertificationInfo>> getCertificationsByType(String type);
  
  /// Get certification records by certification agency
  /// 
  /// [agency] is the certifying agency
  /// Returns certification records from the specified agency
  Future<List<CertificationInfo>> getCertificationsByAgency(String agency);
  
  /// Verify a certification by ID
  /// 
  /// [id] is the certification ID to verify
  /// Returns verification status information
  Future<Map<String, dynamic>> verifyCertification(String id);
}
