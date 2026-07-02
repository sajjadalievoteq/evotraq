import 'package:traqtrace_app/features/operations/shared/utils/operation_event_time_codec.dart';

class CancelShippingRequest {
  const CancelShippingRequest({
    required this.epcs,
    required this.sourceGLN,
    required this.destinationGLN,
    required this.cancelReason,
    this.originalShippingReference,
    this.comments,
    this.eventTime,
    this.eventTimeZoneOffset,
  });

  final List<String> epcs;
  final String sourceGLN;
  final String destinationGLN;
  final String cancelReason;
  final String? originalShippingReference;
  final String? comments;
  final DateTime? eventTime;
  final String? eventTimeZoneOffset;

  Map<String, dynamic> toJson() {
    final eventFields = OperationEventTimeCodec.fieldsForRequest(eventTime);
    return {
      'epcs': epcs,
      'sourceGLN': sourceGLN,
      'destinationGLN': destinationGLN,
      'cancelReason': cancelReason,
      if (originalShippingReference != null &&
          originalShippingReference!.isNotEmpty)
        'originalShippingReference': originalShippingReference,
      if (comments != null && comments!.isNotEmpty) 'comments': comments,
      'eventTime': eventFields['eventTime'],
      'eventTimeZoneOffset':
          eventTimeZoneOffset ?? eventFields['eventTimeZoneOffset'],
    };
  }
}
