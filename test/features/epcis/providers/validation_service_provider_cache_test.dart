import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/data/services/epcis/validation_service.dart';
import 'package:traqtrace_app/features/epcis/providers/validation_service_provider.dart';
import 'package:traqtrace_app/data/models/epcis/object_event.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'validation_service_provider_cache_test.mocks.dart';


@GenerateMocks([ValidationService])
void main() {
  late ValidationCubit cubit;
  late MockValidationService mockValidationService;
  
  setUp(() {
    mockValidationService = MockValidationService();
    cubit = ValidationCubit(
      validationService: mockValidationService,
    );
  });
  
  group('ValidationCubit Cache Tests', () {
    test('should return cached validation result on subsequent calls', () async {
      
      final event = ObjectEvent(
        eventId: 'test-event-id-1',
        recordTime: DateTime.now(),
        action: 'ADD',
        businessStep: 'urn:epcglobal:cbv:bizstep:commissioning',
        disposition: 'urn:epcglobal:cbv:disp:active',
        eventTime: DateTime.now(),
        eventTimeZone: '+00:00',
      );
      
      
      final mockResult = {'valid': true, 'validationErrors': []};
      when(mockValidationService.validateObjectEventModel(any))
          .thenAnswer((_) async => mockResult);
      
      
      final result1 = await cubit.validateObjectEvent(event);
      
      
      final result2 = await cubit.validateObjectEvent(event);
      
      
      verify(mockValidationService.validateObjectEventModel(any)).called(1);
      
      
      expect(result1, true);
      expect(result2, true);
      
      
      expect(cubit.cacheHitRate > 0, true);
    });
    
    test('should clear cache when requested', () async {
      
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
      
      
      when(mockValidationService.validateObjectEventModel(any))
          .thenAnswer((_) async => {'valid': true, 'validationErrors': []});
      
      
      await cubit.validateObjectEvent(event1);
      await cubit.validateObjectEvent(event2);
      
      
      cubit.clearCache();
      
      
      await cubit.validateObjectEvent(event1);
      
      
      verify(mockValidationService.validateObjectEventModel(any)).called(3); 
      
      
      expect(cubit.cacheHitRate, 0);
    });
  });
  
  group('ValidationCubit Batch Validation Tests', () {
    test('should process events in batches', () async {
      
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
      
      
      when(mockValidationService.validateObjectEventModel(any))
          .thenAnswer((_) async => {'valid': true, 'validationErrors': []});
      
      
      final results = await cubit.validateObjectEventBatch(events);
      
      
      expect(results.length, 12);
      
      
      expect(results.every((r) => r['valid'] == true), true);
    });
  });
}
