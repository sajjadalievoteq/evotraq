import 'package:traqtrace_app/features/gs1/models/gtin_model.dart';

/// Service interface for managing GTINs (Global Trade Item Numbers)
abstract class GTINService {
  /// Retrieves a specific GTIN by its code
  Future<GTIN> getGTIN(String gtinCode);
  
  /// Lists GTINs with optional filtering parameters
  Future<List<GTIN>> getGTINs({
    String? search,
    String? manufacturer,
    String? status,
    int page = 0,
    int size = 20,
  });

  /// Advanced search GTINs with comprehensive filtering
  Future<Map<String, dynamic>> searchGTINsAdvanced({
    String? search,
    String? productName,
    String? gtinCode,
    String? manufacturer,
    String? status,
    String? packagingLevel,
    String? registrationDateFrom,
    String? registrationDateTo,
    int page = 0,
    int size = 20,
    String sortBy = 'productName',
    String direction = 'ASC',
  });
  
  /// Creates a new GTIN
  Future<GTIN> createGTIN(GTIN gtin);
  
  /// Updates an existing GTIN
  Future<GTIN> updateGTIN(GTIN gtin);
  
  /// Updates the status of a GTIN
  Future<void> updateGTINStatus(String gtinCode, String status);
  
  /// Validates the GTIN format and check digit
  Future<bool> validateGTIN(String gtinCode);
}