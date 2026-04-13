import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/features/epcis/models/transaction_event.dart';
import 'package:traqtrace_app/data/services/transaction_document_service.dart';

class TransactionDocumentState extends Equatable {
  final bool isLoading;
  final String? error;
  final List<TransactionEvent> events;
  final Map<String, dynamic> documentStatus;
  final Map<String, List<String>> relatedDocuments;

  const TransactionDocumentState({
    required this.isLoading,
    required this.error,
    required this.events,
    required this.documentStatus,
    required this.relatedDocuments,
  });

  factory TransactionDocumentState.initial() => const TransactionDocumentState(
    isLoading: false,
    error: null,
    events: [],
    documentStatus: {},
    relatedDocuments: {},
  );

  TransactionDocumentState copyWith({
    bool? isLoading,
    String? error,
    List<TransactionEvent>? events,
    Map<String, dynamic>? documentStatus,
    Map<String, List<String>>? relatedDocuments,
    bool clearError = false,
  }) {
    return TransactionDocumentState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      events: events ?? this.events,
      documentStatus: documentStatus ?? this.documentStatus,
      relatedDocuments: relatedDocuments ?? this.relatedDocuments,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    error,
    events,
    documentStatus,
    relatedDocuments,
  ];
}

class TransactionDocumentCubit extends Cubit<TransactionDocumentState> {
  final TransactionDocumentService _service;

  TransactionDocumentCubit({
    TransactionDocumentService? service,
    required AppConfig appConfig,
  }) : _service =
           service ??
           TransactionDocumentService(
             httpClient: getIt<http.Client>(),
             tokenManager: getIt<TokenManager>(),
             appConfig: appConfig,
           ),
       super(TransactionDocumentState.initial());

  /// Get transaction events for a document
  Future<void> getTransactionEventsForDocument(String type, String id) async {
    try {
      emit(state.copyWith(isLoading: true, clearError: true, events: const []));
      // Standardize the document type to ensure proper URN format
      final standardType = standardizeDocumentType(type);

      // Log for debugging purposes
      logDocumentTypeDebug(type, standardType);
      print('Searching for document: Type="$standardType", ID="$id"');
      print(
        'API URL: ${_service.toString()}/transaction-documents/$standardType/$id/events',
      );

      var events = await _service.getTransactionEventsByDocument(
        standardType,
        id,
      );
      print('Found ${events.length} events');

      if (events.isEmpty) {
        // Try with just the short type as a fallback (for legacy data)
        final shortType = type.toLowerCase();
        print('No events found, trying fallback with short type: "$shortType"');

        try {
          final fallbackEvents = await _service.getTransactionEventsByDocument(
            shortType,
            id,
          );
          if (fallbackEvents.isNotEmpty) {
            print('Found ${fallbackEvents.length} events using fallback type');
            events = fallbackEvents;
          }
        } catch (fallbackError) {
          print('Fallback search failed: $fallbackError');
          // Ignore fallback errors, we'll go with the original result
        }
      }

      emit(state.copyWith(isLoading: false, events: events));
    } catch (e) {
      final message = 'Error searching for document: ${e.toString()}';
      print(message);
      emit(state.copyWith(isLoading: false, error: message));
    }
  }

  /// Check if a document reference is valid
  Future<bool> validateDocumentReference(String type, String id) async {
    try {
      emit(state.copyWith(isLoading: true, clearError: true));
      // Standardize the document type to ensure proper URN format
      final standardType = standardizeDocumentType(type);
      final isValid = await _service.isDocumentReferenceValid(standardType, id);
      emit(state.copyWith(isLoading: false));
      return isValid;
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
      return false;
    }
  }

  /// Get document status
  Future<void> getDocumentStatus(String type, String id) async {
    try {
      emit(
        state.copyWith(
          isLoading: true,
          clearError: true,
          documentStatus: const {},
        ),
      );
      // Standardize the document type to ensure proper URN format
      final standardType = standardizeDocumentType(type);
      final status = await _service.getDocumentStatus(standardType, id);
      emit(state.copyWith(isLoading: false, documentStatus: status));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// Get related documents
  Future<void> getRelatedDocuments(String type, String id) async {
    try {
      emit(
        state.copyWith(
          isLoading: true,
          clearError: true,
          relatedDocuments: const {},
        ),
      );
      // Standardize the document type to ensure proper URN format
      final standardType = standardizeDocumentType(type);
      final related = await _service.getRelatedDocuments(standardType, id);
      emit(state.copyWith(isLoading: false, relatedDocuments: related));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// Create a link between documents
  Future<bool> createDocumentLink(
    String sourceType,
    String sourceId,
    String targetType,
    String targetId,
    String relationshipType,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, clearError: true));
      // Standardize both document types to ensure proper URN format
      final standardSourceType = standardizeDocumentType(sourceType);
      final standardTargetType = standardizeDocumentType(targetType);

      final result = await _service.createDocumentLink(
        standardSourceType,
        sourceId,
        standardTargetType,
        targetId,
        relationshipType,
      );
      emit(state.copyWith(isLoading: false));
      return result;
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
      return false;
    }
  }

  /// Find original document for an EPC
  Future<Map<String, String>?> findOriginalDocumentForEPC(
    String epc, {
    String? type,
  }) async {
    try {
      emit(state.copyWith(isLoading: true, clearError: true));
      // Standardize document type if provided
      String? standardType;
      if (type != null && type.isNotEmpty) {
        standardType = standardizeDocumentType(type);
      }

      final result = await _service.getOriginalDocumentForEPC(
        epc,
        type: standardType,
      );
      emit(state.copyWith(isLoading: false));
      return result;
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
      return null;
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
    final standardizedType =
        typeMap[lowerType] ?? 'urn:epcglobal:cbv:btt:$type';

    // Debug logging for document type mapping
    logDocumentTypeDebug(type, standardizedType);

    return standardizedType;
  }

  /// Clear any error message
  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  /// Debug function to log document details to console for troubleshooting
  void logDocumentTypeDebug(String input, String standardized) {
    print('Document Type Debug:');
    print('  Input type: "$input"');
    print('  Standardized: "$standardized"');
  }
}
