import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/data/services/validation_service.dart';
import 'package:traqtrace_app/features/epcis/models/object_event.dart';
import 'package:traqtrace_app/features/epcis/providers/validation_service_provider.dart';


// Simple mock implementation of ValidationService for testing
class MockValidationService implements ValidationService {
  bool shouldSucceed = true;
  List<dynamic> validationErrors = [];
  String? error;

  @override
  Future<Map<String, dynamic>> validateEvent(Map<String, dynamic> eventData) async {
    return _getMockResponse();
  }

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
  Future<List<Map<String, dynamic>>> validateObjectEventBatch(List<ObjectEvent> events) async {
    return List.generate(events.length, (_) => _getMockResponse());
  }

  Map<String, dynamic> _getMockResponse() {
    if (error != null) {
      throw Exception(error);
    }
    return {
      'valid': shouldSucceed,
      'validationErrors': validationErrors,
    };
  }
}

void main() {
  late MockValidationService mockValidationService;
  late ValidationCubit cubit;
  final appConfig = AppConfig(
    apiBaseUrl: 'https://api.test.com',
    appName: 'TraqTrace Test',
    appVersion: '1.0.0',
  );
  
  setUp(() {
    mockValidationService = MockValidationService();
    cubit = ValidationCubit(
      validationService: mockValidationService,
    );
  });

  group('ValidationCubit Tests', () {
    test('validateObjectEvent should return true for valid event', () async {
      // Arrange
      mockValidationService.shouldSucceed = true;
      
      // Act
      final result = await cubit.validateObjectEvent(
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
      expect(cubit.isValid, true);
      expect(cubit.validationErrors, isEmpty);
    });
    
    test('validateObjectEvent should return false and set errors for invalid event', () async {
      // Arrange
      mockValidationService.shouldSucceed = false;
      mockValidationService.validationErrors = [
        {'field': 'action', 'message': 'Action is required'},
        {'field': 'businessStep', 'message': 'Business step is required'}
      ];
      
      // Act
      final result = await cubit.validateObjectEvent(
        ObjectEvent(
          eventId: 'test-event-id-2',
          recordTime: DateTime.now(),
          eventTime: DateTime.now(),
          eventTimeZone: '+00:00',
        )
      );
      
      // Assert
      expect(result, false);
      expect(cubit.isValid, false);
      expect(cubit.validationErrors.length, 2);
    });
    
    test('clearValidation should reset validation state', () async {
      // Arrange
      mockValidationService.shouldSucceed = false;
      mockValidationService.validationErrors = [{'field': 'test', 'message': 'Error 1'}];
      await cubit.validateObjectEvent(
        ObjectEvent(
          eventId: 'test-event-id-3',
          recordTime: DateTime.now(),
          eventTime: DateTime.now(),
          eventTimeZone: '+00:00',
        )
      );
      
      // Act
      cubit.clearValidation();
      
      // Assert
      expect(cubit.isValid, false); // Default state is not valid
      expect(cubit.state.lastValidationResult, isNull);
      expect(cubit.validationErrors, isEmpty);
    });
    
    test('Error state should be handled properly', () async {
      // Arrange
      mockValidationService.shouldSucceed = false;
      mockValidationService.error = 'Connection error';
      
      // Act
      final result = await cubit.validateObjectEvent(
        ObjectEvent(
          eventId: 'test-event-id-4',
          recordTime: DateTime.now(),
          eventTime: DateTime.now(),
          eventTimeZone: '+00:00',
        )
      );
      
      // Assert
      expect(result, false);
      expect(cubit.state.error, contains('Connection error'));
    });
  });
}
