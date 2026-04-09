import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/features/epcis/models/transaction_event.dart';
import 'package:traqtrace_app/features/epcis/providers/transaction_document_provider.dart';
import 'package:traqtrace_app/features/epcis/services/transaction_document_service.dart';

// Mock the service manually since we don't have mockito set up
class MockTransactionDocumentService implements TransactionDocumentService {
  // Create mock responses for each method
  List<TransactionEvent> mockTransactionEvents = [];
  Map<String, bool> validDocuments = {};
  Map<String, Map<String, dynamic>> documentStatusMap = {};
  Map<String, Map<String, List<String>>> relatedDocsMap = {};
  Map<String, bool> documentLinkResults = {};
  Map<String, Map<String, String>?> originalDocuments = {};
  String? lastErrorMessage;

  @override
  Future<List<TransactionEvent>> getTransactionEventsByDocument(String type, String id) async {
    if (id == '99999') {
      throw Exception('Network error');
    }
    return mockTransactionEvents;
  }

  @override
  Future<bool> isDocumentReferenceValid(String type, String id) async {
    return validDocuments[id] ?? validDocuments['$type:$id'] ?? false;
  }

  @override
  Future<Map<String, dynamic>> getDocumentStatus(String type, String id) async {
    return documentStatusMap[id] ?? documentStatusMap['$type:$id'] ?? {};
  }

  @override
  Future<Map<String, List<String>>> getRelatedDocuments(String type, String id) async {
    return relatedDocsMap[id] ?? relatedDocsMap['$type:$id'] ?? {};
  }

  @override
  Future<bool> createDocumentLink(String sourceType, String sourceId, 
      String targetType, String targetId, String relationshipType) async {
    return documentLinkResults['$sourceId:$targetId:$relationshipType'] ?? 
           documentLinkResults['$sourceType:$sourceId:$targetType:$targetId:$relationshipType'] ?? false;
  }

  @override
  Future<Map<String, String>?> getOriginalDocumentForEPC(String epc, {String? type}) async {
    return originalDocuments[epc];
  }
}

void main() {
  late TransactionDocumentProvider provider;
  late MockTransactionDocumentService mockService;
  final appConfig = AppConfig(
    apiBaseUrl: 'https://api.test.com',
    appName: 'TraqTrace Test',
    appVersion: '1.0.0',
  );

  setUp(() {
    mockService = MockTransactionDocumentService();
    provider = TransactionDocumentProvider(
      service: mockService,
      appConfig: appConfig,
    );
  });

  group('TransactionDocumentProvider Tests', () {
    test('getTransactionEventsForDocument should update events list', () async {
      // Arrange
      final dateTime1 = DateTime(2025, 7, 1, 10, 0, 0);
      final dateTime2 = DateTime(2025, 7, 1, 11, 0, 0);
      
      final mockEvents = [
        TransactionEvent(
          id: '1',
          eventTime: dateTime1,
          action: 'ADD',
          bizTransactionList: {'urn:epcglobal:cbv:btt:inv': '12345'},
        ),
        TransactionEvent(
          id: '2',
          eventTime: dateTime2,
          action: 'OBSERVE',
          bizTransactionList: {'urn:epcglobal:cbv:btt:inv': '12345'},
        ),
      ];
      
      // Set up mock response
      mockService.mockTransactionEvents = mockEvents;

      // Act
      await provider.getTransactionEventsForDocument('invoice', '12345');

      // Assert
      expect(provider.events, equals(mockEvents));
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
    });
    
    test('validateDocumentReference should return correct value', () async {
      // Arrange
      mockService.validDocuments = {
        'urn:epcglobal:cbv:btt:inv:12345': true,
        'urn:epcglobal:cbv:btt:inv:invalid': false
      };

      // Act & Assert
      expect(await provider.validateDocumentReference('invoice', '12345'), isTrue);
      expect(await provider.validateDocumentReference('invoice', 'invalid'), isFalse);
    });
    
    test('getDocumentStatus should update status', () async {
      // Arrange
      final mockStatus = {
        'status': 'ACTIVE',
        'created': '2025-07-01T10:00:00Z',
        'lastUpdated': '2025-07-01T11:00:00Z'
      };
      
      mockService.documentStatusMap = {'urn:epcglobal:cbv:btt:inv:12345': mockStatus};

      // Act
      await provider.getDocumentStatus('invoice', '12345');

      // Assert
      expect(provider.documentStatus, equals(mockStatus));
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
    });
    
    test('getRelatedDocuments should update related documents', () async {
      // Arrange
      final mockRelatedDocs = {
        'replaces': ['invoice:11111', 'invoice:22222'],
        'references': ['order:33333']
      };
      
      mockService.relatedDocsMap = {'urn:epcglobal:cbv:btt:inv:12345': mockRelatedDocs};

      // Act
      await provider.getRelatedDocuments('invoice', '12345');

      // Assert
      expect(provider.relatedDocuments, equals(mockRelatedDocs));
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
    });
    
    test('createDocumentLink should return correct value', () async {
      // Arrange
      mockService.documentLinkResults = {
        'urn:epcglobal:cbv:btt:inv:12345:urn:epcglobal:cbv:btt:po:67890:references': true
      };

      // Act & Assert
      expect(await provider.createDocumentLink(
        'invoice', '12345', 'po', '67890', 'references'), isTrue);
    });
    
    test('findOriginalDocumentForEPC should return document info', () async {
      // Arrange
      final mockDocument = {'type': 'invoice', 'id': '12345'};
      final epc = 'urn:epc:id:sgtin:0614141.107346.2017';
      
      mockService.originalDocuments = {epc: mockDocument};

      // Act
      final result = await provider.findOriginalDocumentForEPC(epc);

      // Assert
      expect(result, equals(mockDocument));
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
    });
    
    test('error handling should set error message', () async {
      // No need to arrange anything as the mock is set up to throw
      // for invoice 99999 in the MockTransactionDocumentService class

      // Act
      await provider.getTransactionEventsForDocument('invoice', '99999');

      // Assert
      expect(provider.events, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.error, contains('Exception: Network error'));
    });
    
    test('clearError should clear error state', () async {
      // Act - cause an error
      await provider.getTransactionEventsForDocument('invoice', '99999');
      expect(provider.error, isNotNull);
      
      // Clear the error
      provider.clearError();

      // Assert
      expect(provider.error, isNull);
    });
  });
}
