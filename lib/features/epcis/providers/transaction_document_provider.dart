import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/features/epcis/models/transaction_event.dart';
import 'package:traqtrace_app/features/epcis/services/transaction_document_service.dart';
import 'package:traqtrace_app/features/epcis/services/transaction_document_service_impl.dart';

/// Provider for transaction document operations
class TransactionDocumentProvider extends ChangeNotifier {
  final TransactionDocumentService _service;
  
  bool _isLoading = false;
  String? _error;
  List<TransactionEvent> _events = [];
  Map<String, dynamic> _documentStatus = {};
  Map<String, List<String>> _relatedDocuments = {};
  
  /// Constructor
  TransactionDocumentProvider({
    TransactionDocumentService? service,
    http.Client? httpClient,
    TokenManager? tokenManager,
    required AppConfig appConfig,
  }) : _service = service ?? TransactionDocumentServiceImpl(
            httpClient: httpClient ?? http.Client(),
            tokenManager: tokenManager ?? TokenManager(),
            appConfig: appConfig,
          );

  /// Is loading state
  bool get isLoading => _isLoading;
  
  /// Error message if any
  String? get error => _error;
  
  /// Transaction events for a document
  List<TransactionEvent> get events => _events;
  
  /// Document status
  Map<String, dynamic> get documentStatus => _documentStatus;
  
  /// Related documents
  Map<String, List<String>> get relatedDocuments => _relatedDocuments;
  
  /// Get transaction events for a document
  Future<void> getTransactionEventsForDocument(String type, String id) async {
    _setLoading(true);
    try {
      // Standardize the document type to ensure proper URN format
      final standardType = standardizeDocumentType(type);
      
      // Log for debugging purposes
      logDocumentTypeDebug(type, standardType);
      print('Searching for document: Type="$standardType", ID="$id"');
      print('API URL: ${_service.toString()}/transaction-documents/$standardType/$id/events');
      
      _events = await _service.getTransactionEventsByDocument(standardType, id);
      print('Found ${_events.length} events');
      
      if (_events.isEmpty) {
        // Try with just the short type as a fallback (for legacy data)
        final shortType = type.toLowerCase();
        print('No events found, trying fallback with short type: "$shortType"');
        
        try {
          final fallbackEvents = await _service.getTransactionEventsByDocument(shortType, id);
          if (fallbackEvents.isNotEmpty) {
            print('Found ${fallbackEvents.length} events using fallback type');
            _events = fallbackEvents;
          }
        } catch (fallbackError) {
          print('Fallback search failed: $fallbackError');
          // Ignore fallback errors, we'll go with the original result
        }
      }
      
      _error = null;
    } catch (e) {
      _error = 'Error searching for document: ${e.toString()}';
      print(_error);
    } finally {
      _setLoading(false);
    }
  }
  
  /// Check if a document reference is valid
  Future<bool> validateDocumentReference(String type, String id) async {
    _setLoading(true);
    try {
      // Standardize the document type to ensure proper URN format
      final standardType = standardizeDocumentType(type);
      final isValid = await _service.isDocumentReferenceValid(standardType, id);
      _error = null;
      return isValid;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Get document status
  Future<void> getDocumentStatus(String type, String id) async {
    _setLoading(true);
    try {
      // Standardize the document type to ensure proper URN format
      final standardType = standardizeDocumentType(type);
      _documentStatus = await _service.getDocumentStatus(standardType, id);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }
  
  /// Get related documents
  Future<void> getRelatedDocuments(String type, String id) async {
    _setLoading(true);
    try {
      // Standardize the document type to ensure proper URN format
      final standardType = standardizeDocumentType(type);
      _relatedDocuments = await _service.getRelatedDocuments(standardType, id);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }
  
  /// Create a link between documents
  Future<bool> createDocumentLink(String sourceType, String sourceId, 
                               String targetType, String targetId,
                               String relationshipType) async {
    _setLoading(true);
    try {
      // Standardize both document types to ensure proper URN format
      final standardSourceType = standardizeDocumentType(sourceType);
      final standardTargetType = standardizeDocumentType(targetType);
      
      final result = await _service.createDocumentLink(
        standardSourceType, sourceId, standardTargetType, targetId, relationshipType);
      _error = null;
      return result;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Find original document for an EPC
  Future<Map<String, String>?> findOriginalDocumentForEPC(String epc, {String? type}) async {
    _setLoading(true);
    try {
      // Standardize document type if provided
      String? standardType;
      if (type != null && type.isNotEmpty) {
        standardType = standardizeDocumentType(type);
      }
      
      final result = await _service.getOriginalDocumentForEPC(epc, type: standardType);
      _error = null;
      return result;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Map document type to standard URN format
  String standardizeDocumentType(String type) {
    // If already in URN format, return as is
    if (type.startsWith('urn:epcglobal:cbv:btt:')) {
      return type;
    }
    
    // Map common abbreviations and names to their URN format
    final Map<String, String> typeMap = {
      'inv': 'urn:epcglobal:cbv:btt:inv',
      'invoice': 'urn:epcglobal:cbv:btt:inv',
      'po': 'urn:epcglobal:cbv:btt:po',
      'purchase order': 'urn:epcglobal:cbv:btt:po',
      'desadv': 'urn:epcglobal:cbv:btt:desadv',
      'despatch advice': 'urn:epcglobal:cbv:btt:desadv',
      'shipping notice': 'urn:epcglobal:cbv:btt:desadv',
      'packing-list': 'urn:epcglobal:cbv:btt:packing-list',
      'packing list': 'urn:epcglobal:cbv:btt:packing-list',
      'receipt': 'urn:epcglobal:cbv:btt:receipt',
      'receiving advice': 'urn:epcglobal:cbv:btt:receipt',
      'bol': 'urn:epcglobal:cbv:btt:bol',
      'bill of lading': 'urn:epcglobal:cbv:btt:bol',
      'cert': 'urn:epcglobal:cbv:btt:cert',
      'certificate': 'urn:epcglobal:cbv:btt:cert',
      'pedigree': 'urn:epcglobal:cbv:btt:pedigree',
      'prodorder': 'urn:epcglobal:cbv:btt:prodorder',
      'production order': 'urn:epcglobal:cbv:btt:prodorder',
      'transdoc': 'urn:epcglobal:cbv:btt:transdoc',
      'transport document': 'urn:epcglobal:cbv:btt:transdoc',
      'customs': 'urn:epcglobal:cbv:btt:customs',
      'customs declaration': 'urn:epcglobal:cbv:btt:customs',
      'contract': 'urn:epcglobal:cbv:btt:contract',
    };
    
    // Try to map the input type to a standard URN (case insensitive)
    final lowerType = type.toLowerCase();
    final standardizedType = typeMap[lowerType] ?? 'urn:epcglobal:cbv:btt:$type';
    
    // Debug logging for document type mapping
    logDocumentTypeDebug(type, standardizedType);
    
    return standardizedType;
  }
  
  /// Clear any error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  /// Set loading state and notify listeners
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  /// Debug function to log document details to console for troubleshooting
  void logDocumentTypeDebug(String input, String standardized) {
    print('Document Type Debug:');
    print('  Input type: "$input"');
    print('  Standardized: "$standardized"');
  }
}
