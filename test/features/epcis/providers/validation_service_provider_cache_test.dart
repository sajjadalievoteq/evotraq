import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/features/epcis/providers/validation_service_provider.dart';
import 'package:traqtrace_app/features/epcis/models/object_event.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:traqtrace_app/features/epcis/services/validation_service.dart';

import 'validation_service_provider_cache_test.mocks.dart';

// Generate mock classes
@GenerateMocks([ValidationService])
void main() {
  late ValidationCubit cubit;
  late MockValidationService mockValidationService;
  final appConfig = AppConfig(
    apiBaseUrl: 'https://api.test.com',
    appName: 'TraqTrace Test',
    appVersion: '1.0.0',
  );
  
  setUp(() {
    mockValidationService = MockValidationService();
    cubit = ValidationCubit(
      validationService: mockValidationService,
      appConfig: appConfig,
    );
  });
  
  group('ValidationCubit Cache Tests', () {
    test('should return cached validation result on subsequent calls', () async {
      // Setup a test event
      final event = ObjectEvent(
        eventId: 'test-event-id-1',
        recordTime: DateTime.now(),
        action: 'ADD',
        businessStep: 'urn:epcglobal:cbv:bizstep:commissioning',
        disposition: 'urn:epcglobal:cbv:disp:active',
        eventTime: DateTime.now(),
        eventTimeZone: '+00:00',
      );
      
      // Define mock behavior - validation service will be called once
      final mockResult = {'valid': true, 'validationErrors': []};
      when(mockValidationService.validateObjectEventModel(any))
          .thenAnswer((_) async => mockResult);
      
      // First validation call (should hit the service)
      final result1 = await cubit.validateObjectEvent(event);
      
      // Second validation call with same event (should use cache)
      final result2 = await cubit.validateObjectEvent(event);
      
      // Verify validation service was only called once
      verify(mockValidationService.validateObjectEventModel(any)).called(1);
      
      // Both results should be true
      expect(result1, true);
      expect(result2, true);
      
      // Cache hit rate should be positive
      expect(cubit.cacheHitRate > 0, true);
    });
    
    test('should clear cache when requested', () async {
      // Setup test events
      final event1 = ObjectEvent(
        eventId: 'test-event-id-1',
        recordTime: DateTime.now(),
        action: 'ADD',
        eventTime: DateTime.now(),
        eventTimeZone: '+00:00',
      );
      
      final event2 = ObjectEvent(
        eventId: 'test-event-id-2',
        recordTime: DateTime.now(),
        action: 'OBSERVE',
        eventTime: DateTime.now(),
        eventTimeZone: '+00:00',
      );
      
      // Define mock behavior
      when(mockValidationService.validateObjectEventModel(any))
          .thenAnswer((_) async => {'valid': true, 'validationErrors': []});
      
      // Call validation once for each event to populate cache
      await cubit.validateObjectEvent(event1);
      await cubit.validateObjectEvent(event2);
      
      // Clear the cache
      cubit.clearCache();
      
      // Call validation again - service should be called again
      await cubit.validateObjectEvent(event1);
      
      // Verify service was called twice for event1 (once before clearing cache, once after)
      verify(mockValidationService.validateObjectEventModel(any)).called(3); // 2 initially + 1 after clear
      
      // Cache hit rate should be reset to 0 after clearing
      expect(cubit.cacheHitRate, 0);
    });
  });
  
  group('ValidationCubit Batch Validation Tests', () {
    test('should process events in batches', () async {
      // Create multiple events
      final events = List.generate(
        12, 
        (i) => ObjectEvent(
          eventId: 'test-event-id-$i',
          recordTime: DateTime.now(),
          action: 'ADD',
          epcList: ['urn:epc:id:sgtin:0614141.107346.$i'],
          eventTime: DateTime.now(),
          eventTimeZone: '+00:00',
        )
      );
      
      // Define mock behavior - service should return valid for all events
      when(mockValidationService.validateObjectEventModel(any))
          .thenAnswer((_) async => {'valid': true, 'validationErrors': []});
      
      // Process batch
      final results = await cubit.validateObjectEventBatch(events);
      
      // Should have one result per event
      expect(results.length, 12);
      
      // All results should be valid
      expect(results.every((r) => r['valid'] == true), true);
    });
  });
}
