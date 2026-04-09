import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/features/epcis/models/object_event.dart';
import 'package:traqtrace_app/features/epcis/providers/validation_service_provider.dart';
import 'package:traqtrace_app/features/epcis/services/validation_service.dart';

// Simple mock implementation of ValidationService for testing
class MockValidationService implements ValidationService {
  bool shouldSucceed = true;
  List<dynamic> validationErrors = [];
  String? error;

  @override
  Future<Map<String, dynamic>> validateObjectEvent(Map<String, dynamic> eventData) async {
    return _getMockResponse();
  }
  
  @override
  Future<Map<String, dynamic>> validateObjectEventModel(ObjectEvent event) async {
    return _getMockResponse();
  }
  
  @override
  Future<Map<String, dynamic>> validateAggregationEvent(Map<String, dynamic> eventData) async {
    return _getMockResponse();
  }
  
  @override
  Future<Map<String, dynamic>> validateAggregationEventModel(dynamic event) async {
    return _getMockResponse();
  }
  
  @override
  Future<Map<String, dynamic>> validateTransactionEvent(Map<String, dynamic> eventData) async {
    return _getMockResponse();
  }
  
  @override
  Future<Map<String, dynamic>> validateTransactionEventModel(dynamic event) async {
    return _getMockResponse();
  }
  
  @override
  Future<Map<String, dynamic>> validateTransformationEvent(Map<String, dynamic> eventData) async {
    return _getMockResponse();
  }
  
  @override
  Future<Map<String, dynamic>> validateTransformationEventModel(dynamic event) async {
    return _getMockResponse();
  }
  
  @override
  Future<Map<String, dynamic>> validateEvent(Map<String, dynamic> eventData) async {
    return _getMockResponse();
  }
  
  Map<String, dynamic> _getMockResponse() {
    if (shouldSucceed) {
      return {
        'valid': true,
        'validationErrors': []
      };
    } else if (error != null) {
      return {
        'valid': false,
        'error': error
      };
    } else {
      return {
        'valid': false,
        'validationErrors': validationErrors
      };
    }
  }
}

void main() {
  late MockValidationService mockValidationService;
  late ValidationServiceProvider provider;
  final appConfig = AppConfig(
    apiBaseUrl: 'https://api.test.com',
    appName: 'TraqTrace Test',
    appVersion: '1.0.0',
  );
  
  setUp(() {
    mockValidationService = MockValidationService();
    provider = ValidationServiceProvider(
      validationService: mockValidationService,
      appConfig: appConfig,
    );
  });

  group('ValidationServiceProvider Tests', () {
    test('validateObjectEvent should return true for valid event', () async {
      // Arrange
      mockValidationService.shouldSucceed = true;
      
      // Act
      final result = await provider.validateObjectEvent(
        ObjectEvent(
          eventId: 'test-event-id-1',
          recordTime: DateTime.now(),
          action: 'ADD',
          businessStep: 'urn:epcglobal:cbv:bizstep:commissioning',
          disposition: 'urn:epcglobal:cbv:disp:active',
          eventTime: DateTime.now(),
          eventTimeZone: '+00:00',
        )
      );
      
      // Assert
      expect(result, true);
      expect(provider.isValid, true);
      expect(provider.validationErrors, isEmpty);
    });
    
    test('validateObjectEvent should return false and set errors for invalid event', () async {
      // Arrange
      mockValidationService.shouldSucceed = false;
      mockValidationService.validationErrors = [
        'Action is required',
        'Business step is required'
      ];
      
      // Act
      final result = await provider.validateObjectEvent(
        ObjectEvent(
          eventId: 'test-event-id-2',
          recordTime: DateTime.now(),
          eventTime: DateTime.now(),
          eventTimeZone: '+00:00',
        )
      );
      
      // Assert
      expect(result, false);
      expect(provider.isValid, false);
      expect(provider.validationErrors.length, 2);
      expect(provider.validationErrors[0], 'Action is required');
    });
    
    test('clearValidation should reset validation state', () async {
      // Arrange
      mockValidationService.shouldSucceed = false;
      mockValidationService.validationErrors = ['Error 1'];
      await provider.validateObjectEvent(
        ObjectEvent(
          eventId: 'test-event-id-3',
          recordTime: DateTime.now(),
          eventTime: DateTime.now(),
          eventTimeZone: '+00:00',
        )
      );
      
      // Act
      provider.clearValidation();
      
      // Assert
      expect(provider.isValid, false); // Default state is not valid
      expect(provider.lastValidationResult, isNull);
      expect(provider.validationErrors, isEmpty);
    });
    
    test('Error state should be handled properly', () async {
      // Arrange
      mockValidationService.shouldSucceed = false;
      mockValidationService.error = 'Connection error';
      
      // Act
      final result = await provider.validateObjectEvent(
        ObjectEvent(
          eventId: 'test-event-id-4',
          recordTime: DateTime.now(),
          eventTime: DateTime.now(),
          eventTimeZone: '+00:00',
        )
      );
      
      // Assert
      expect(result, false);
      expect(provider.error, 'Connection error');
    });
  });
}
