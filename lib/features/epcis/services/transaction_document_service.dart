import 'package:traqtrace_app/features/epcis/models/transaction_event.dart';

/// Service for interacting with transaction document references
abstract class TransactionDocumentService {
  /// Get transaction events associated with a document reference
  Future<List<TransactionEvent>> getTransactionEventsByDocument(String type, String id);
  
  /// Check if a document reference is valid
  Future<bool> isDocumentReferenceValid(String type, String id);
  
  /// Get the status of a transaction document
  Future<Map<String, dynamic>> getDocumentStatus(String type, String id);
  
  /// Get related documents for a document reference
  Future<Map<String, List<String>>> getRelatedDocuments(String type, String id);
  
  /// Register a link between two document references
  Future<bool> createDocumentLink(String sourceType, String sourceId, 
                                String targetType, String targetId,
                                String relationshipType);
                                
  /// Find the original document for an EPC
  Future<Map<String, String>?> getOriginalDocumentForEPC(String epc, {String? type});
}
