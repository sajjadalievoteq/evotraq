import 'package:traqtrace_app/features/gs1/models/gln_model.dart';

/// Service interface for GLN (Global Location Number) operations
abstract class GLNService {
  /// Get all GLNs with optional pagination
  Future<List<GLN>> getAllGLNs({int? page, int? size});
  
  /// Get a specific GLN by its GLN code (previously called ID)
  Future<GLN> getGLNById(String glnCode);
  
  /// Get a GLN by its GLN code
  Future<GLN> getGLNByCode(String glnCode);
  
  /// Create a new GLN
  Future<GLN> createGLN(GLN gln);
  
  /// Update an existing GLN using its GLN code as identifier
  Future<GLN> updateGLN(String glnCode, GLN gln);
  
  /// Delete a GLN using its GLN code as identifier
  Future<bool> deleteGLN(String glnCode);
  
  /// Search GLNs based on criteria
  Future<List<GLN>> searchGLNs({
    String? searchTerm,
    String? locationType,
    bool? active,
    int? page,
    int? size,
  });

  /// Advanced search GLNs with comprehensive filtering
  Future<Map<String, dynamic>> searchGLNsAdvanced({
    String? search,
    String? glnCode,
    String? name,
    String? address,
    String? licenseNo,
    String? contactEmail,
    String? contactName,
    bool? active,
    String? locationType,
    int page = 0,
    int size = 20,
    String sortBy = 'name',
    String direction = 'ASC',
  });
  
  /// Get GLNs with expired licenses
  Future<List<GLN>> getExpiredLicenseGLNs();
  
  /// Get child GLNs of a parent GLN
  Future<List<GLN>> getChildGLNs(String parentGlnCode);
  
  /// Validate a GLN code
  Future<bool> validateGLNCode(String glnCode);
}