




import 'dart:async' as _i3;

import 'package:mockito/mockito.dart' as _i1;
import 'package:traqtrace_app/data/models/epcis/aggregation_event.dart' as _i5;
import 'package:traqtrace_app/data/models/epcis/object_event.dart' as _i4;
import 'package:traqtrace_app/data/models/epcis/transaction_event.dart' as _i6;
import 'package:traqtrace_app/data/models/epcis/transformation_event.dart'
    as _i7;
import 'package:traqtrace_app/data/services/epcis/validation_service.dart'
    as _i2;



















class MockValidationService extends _i1.Mock implements _i2.ValidationService {
  MockValidationService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<Map<String, dynamic>> validateObjectEvent(
    Map<String, dynamic>? eventData,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#validateObjectEvent, [eventData]),
            returnValue: _i3.Future<Map<String, dynamic>>.value(
              <String, dynamic>{},
            ),
          )
          as _i3.Future<Map<String, dynamic>>);

  @override
  _i3.Future<Map<String, dynamic>> validateObjectEventModel(
    _i4.ObjectEvent? event,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#validateObjectEventModel, [event]),
            returnValue: _i3.Future<Map<String, dynamic>>.value(
              <String, dynamic>{},
            ),
          )
          as _i3.Future<Map<String, dynamic>>);

  @override
  _i3.Future<Map<String, dynamic>> validateAggregationEvent(
    Map<String, dynamic>? eventData,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#validateAggregationEvent, [eventData]),
            returnValue: _i3.Future<Map<String, dynamic>>.value(
              <String, dynamic>{},
            ),
          )
          as _i3.Future<Map<String, dynamic>>);

  @override
  _i3.Future<Map<String, dynamic>> validateAggregationEventModel(
    _i5.AggregationEvent? event,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#validateAggregationEventModel, [event]),
            returnValue: _i3.Future<Map<String, dynamic>>.value(
              <String, dynamic>{},
            ),
          )
          as _i3.Future<Map<String, dynamic>>);

  @override
  _i3.Future<Map<String, dynamic>> validateTransactionEvent(
    Map<String, dynamic>? eventData,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#validateTransactionEvent, [eventData]),
            returnValue: _i3.Future<Map<String, dynamic>>.value(
              <String, dynamic>{},
            ),
          )
          as _i3.Future<Map<String, dynamic>>);

  @override
  _i3.Future<Map<String, dynamic>> validateTransactionEventModel(
    _i6.TransactionEvent? event,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#validateTransactionEventModel, [event]),
            returnValue: _i3.Future<Map<String, dynamic>>.value(
              <String, dynamic>{},
            ),
          )
          as _i3.Future<Map<String, dynamic>>);

  @override
  _i3.Future<Map<String, dynamic>> validateTransformationEvent(
    Map<String, dynamic>? eventData,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#validateTransformationEvent, [eventData]),
            returnValue: _i3.Future<Map<String, dynamic>>.value(
              <String, dynamic>{},
            ),
          )
          as _i3.Future<Map<String, dynamic>>);

  @override
  _i3.Future<Map<String, dynamic>> validateTransformationEventModel(
    _i7.TransformationEvent? event,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#validateTransformationEventModel, [event]),
            returnValue: _i3.Future<Map<String, dynamic>>.value(
              <String, dynamic>{},
            ),
          )
          as _i3.Future<Map<String, dynamic>>);

  @override
  _i3.Future<Map<String, dynamic>> validateEvent(
    Map<String, dynamic>? eventData,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#validateEvent, [eventData]),
            returnValue: _i3.Future<Map<String, dynamic>>.value(
              <String, dynamic>{},
            ),
          )
          as _i3.Future<Map<String, dynamic>>);
}
