import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/data/services/validation_service.dart';
import 'package:traqtrace_app/features/epcis/models/object_event.dart';

import 'dart:convert';
import 'validation_service_test.mocks.dart';

@GenerateMocks([DioService])
void main() {
  late MockDioService mockDioService;
  late ValidationService validationService;

  setUp(() {
    mockDioService = MockDioService();
    validationService = ValidationService(
      dioService: mockDioService,
    );

    // Set up mock token response
    when(mockDioService.getAuthToken()).thenAnswer((_) async => 'test-token');
    when(mockDioService.baseUrl).thenReturn('http://test-api.com/api');
  });

  group('ValidationService Tests', () {
    test('validateObjectEvent should call correct endpoint', () async {
      // Arrange
      final testEventData = {
        'action': 'ADD',
        'businessStep': 'urn:epcglobal:cbv:bizstep:commissioning',
        'disposition': 'urn:epcglobal:cbv:disp:active',
        'epcList': ['urn:epc:id:sgtin:0614141.107346.1']
      };
      
      final mockResponse = {
        'valid': true,
        'validationErrors': []
      };
      
      when(mockDioService.post(
        argThat(contains('/validate/object-event')),
        data: anyNamed('data'),
        headers: anyNamed('headers'),
        responseType: anyNamed('responseType'),
        acceptAllStatusCodes: anyNamed('acceptAllStatusCodes'),
      )).thenAnswer((_) async => Response(
        requestOptions: RequestOptions(path: ''),
        data: jsonEncode(mockResponse),
        statusCode: 200,
      ));
      
      // Act
      final result = await validationService.validateObjectEvent(testEventData);
      
      // Assert
      expect(result['valid'], true);
      expect(result['validationErrors'], isEmpty);
      
      // Verify the correct endpoint was called
      verify(mockDioService.post(
        argThat(contains('/validate/object-event')),
        data: anyNamed('data'),
        headers: anyNamed('headers'),
        responseType: anyNamed('responseType'),
        acceptAllStatusCodes: anyNamed('acceptAllStatusCodes'),
      )).called(1);
    });

    test('validateObjectEventModel should process ObjectEvent model', () async {
      // Arrange
      final testEvent = ObjectEvent(
        eventId: 'test-event-id-1',
        recordTime: DateTime.now(),
        action: 'ADD',
        businessStep: 'urn:epcglobal:cbv:bizstep:commissioning',
        disposition: 'urn:epcglobal:cbv:disp:active',
        epcList: ['urn:epc:id:sgtin:0614141.107346.1'],
        eventTime: DateTime.now(),
        eventTimeZone: '+00:00',
      );
      
      final mockResponse = {
        'valid': true,
        'validationErrors': []
      };
      
      when(mockDioService.post(
        argThat(contains('/validate/object-event')),
        data: anyNamed('data'),
        headers: anyNamed('headers'),
        responseType: anyNamed('responseType'),
        acceptAllStatusCodes: anyNamed('acceptAllStatusCodes'),
      )).thenAnswer((_) async => Response(
        requestOptions: RequestOptions(path: ''),
        data: jsonEncode(mockResponse),
        statusCode: 200,
      ));
      
      // Act
      final result = await validationService.validateObjectEventModel(testEvent);
      
      // Assert
      expect(result['valid'], true);
      expect(result['validationErrors'], isEmpty);
    });

    test('validateAggregationEvent should call correct endpoint', () async {
      // Arrange
      final testEventData = {
        'action': 'ADD',
        'businessStep': 'urn:epcglobal:cbv:bizstep:packing',
        'disposition': 'urn:epcglobal:cbv:disp:in_progress',
        'parentID': 'urn:epc:id:sscc:0614141.1234567890',
        'childEPCs': ['urn:epc:id:sgtin:0614141.107346.1', 'urn:epc:id:sgtin:0614141.107346.2']
      };
      
      final mockResponse = {
        'valid': true,
        'validationErrors': []
      };
      
      when(mockDioService.post(
        argThat(contains('/validate/aggregation-event')),
        data: anyNamed('data'),
        headers: anyNamed('headers'),
        responseType: anyNamed('responseType'),
        acceptAllStatusCodes: anyNamed('acceptAllStatusCodes'),
      )).thenAnswer((_) async => Response(
        requestOptions: RequestOptions(path: ''),
        data: jsonEncode(mockResponse),
        statusCode: 200,
      ));
      
      // Act
      final result = await validationService.validateAggregationEvent(testEventData);
      
      // Assert
      expect(result['valid'], true);
      expect(result['validationErrors'], isEmpty);
      
      // Verify the correct endpoint was called
      verify(mockDioService.post(
        argThat(contains('/validate/aggregation-event')),
        data: anyNamed('data'),
        headers: anyNamed('headers'),
        responseType: anyNamed('responseType'),
        acceptAllStatusCodes: anyNamed('acceptAllStatusCodes'),
      )).called(1);
    });

    test('validateTransactionEvent should call correct endpoint', () async {
      // Arrange
      final testEventData = {
        'action': 'ADD',
        'businessStep': 'urn:epcglobal:cbv:bizstep:shipping',
        'disposition': 'urn:epcglobal:cbv:disp:in_transit',
        'bizTransactionList': [
          {'type': 'urn:epcglobal:cbv:btt:inv', 'id': '12345'}
        ],
        'epcList': ['urn:epc:id:sgtin:0614141.107346.1']
      };
      
      final mockResponse = {
        'valid': true,
        'validationErrors': []
      };
      
      when(mockDioService.post(
        argThat(contains('/validate/transaction-event')),
        data: anyNamed('data'),
        headers: anyNamed('headers'),
        responseType: anyNamed('responseType'),
        acceptAllStatusCodes: anyNamed('acceptAllStatusCodes'),
      )).thenAnswer((_) async => Response(
        requestOptions: RequestOptions(path: ''),
        data: jsonEncode(mockResponse),
        statusCode: 200,
      ));
      
      // Act
      final result = await validationService.validateTransactionEvent(testEventData);
      
      // Assert
      expect(result['valid'], true);
      expect(result['validationErrors'], isEmpty);
      
      // Verify the correct endpoint was called
      verify(mockDioService.post(
        argThat(contains('/validate/transaction-event')),
        data: anyNamed('data'),
        headers: anyNamed('headers'),
        responseType: anyNamed('responseType'),
        acceptAllStatusCodes: anyNamed('acceptAllStatusCodes'),
      )).called(1);
    });

    test('validateTransformationEvent should call correct endpoint', () async {
      // Arrange
      final testEventData = {
        'inputEPCList': ['urn:epc:id:sgtin:0614141.107346.1', 'urn:epc:id:sgtin:0614141.107346.2'],
        'outputEPCList': ['urn:epc:id:sgtin:0614141.107347.1'],
        'businessStep': 'urn:epcglobal:cbv:bizstep:commissioning',
        'disposition': 'urn:epcglobal:cbv:disp:active',
      };
      
      final mockResponse = {
        'valid': true,
        'validationErrors': []
      };
      
      when(mockDioService.post(
        argThat(contains('/validate/transformation-event')),
        data: anyNamed('data'),
        headers: anyNamed('headers'),
        responseType: anyNamed('responseType'),
        acceptAllStatusCodes: anyNamed('acceptAllStatusCodes'),
      )).thenAnswer((_) async => Response(
        requestOptions: RequestOptions(path: ''),
        data: jsonEncode(mockResponse),
        statusCode: 200,
      ));
      
      // Act
      final result = await validationService.validateTransformationEvent(testEventData);
      
      // Assert
      expect(result['valid'], true);
      expect(result['validationErrors'], isEmpty);
      
      // Verify the correct endpoint was called
      verify(mockDioService.post(
        argThat(contains('/validate/transformation-event')),
        data: anyNamed('data'),
        headers: anyNamed('headers'),
        responseType: anyNamed('responseType'),
        acceptAllStatusCodes: anyNamed('acceptAllStatusCodes'),
      )).called(1);
    });
    
    test('validateEvent should handle server errors', () async {
      // Arrange
      final testEventData = {
        'action': 'ADD',
        'businessStep': 'urn:epcglobal:cbv:bizstep:commissioning',
      };
      
      when(mockDioService.post(
        argThat(contains('/validate/event')),
        data: anyNamed('data'),
        headers: anyNamed('headers'),
        responseType: anyNamed('responseType'),
        acceptAllStatusCodes: anyNamed('acceptAllStatusCodes'),
      )).thenAnswer((_) async => Response(
        requestOptions: RequestOptions(path: ''),
        data: 'Server error',
        statusCode: 500,
      ));
      
      // Act
      final result = await validationService.validateEvent(testEventData);
      
      // Assert
      expect(result['valid'], false);
      expect(result.containsKey('error'), true);
    });
    
    test('validation should handle connection errors', () async {
      // Arrange
      final testEventData = {
        'action': 'ADD',
        'businessStep': 'urn:epcglobal:cbv:bizstep:commissioning',
      };
      
      when(mockDioService.post(
        argThat(contains('/validate/event')),
        data: anyNamed('data'),
        headers: anyNamed('headers'),
        responseType: anyNamed('responseType'),
        acceptAllStatusCodes: anyNamed('acceptAllStatusCodes'),
      )).thenThrow(DioException(requestOptions: RequestOptions(path: ''), message: 'Network error'));
      
      // Act
      final result = await validationService.validateEvent(testEventData);
      
      // Assert
      expect(result['valid'], false);
      expect(result.containsKey('error'), true);
      expect(result['error'].toString().contains('Network error'), true);
    });
  });
}

