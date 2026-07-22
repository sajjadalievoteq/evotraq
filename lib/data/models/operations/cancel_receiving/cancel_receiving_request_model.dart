import 'package:traqtrace_app/data/models/operations/shared/operation_gln_display.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_event_time_codec.dart';

class CancelReceivingRequest {
  const CancelReceivingRequest({
    required this.epcs,
    required this.sourceGLN,
    required this.receivingGLN,
    this.sourceLocation,
    this.receivingLocation,
    required this.cancelReason,
    required this.actingGln,
    this.originalReceivingReference,
    this.comments,
    this.eventTime,
    this.eventTimeZoneOffset,
  });

  final List<String> epcs;
  final String sourceGLN;
  final String receivingGLN;
  final OperationGlnDisplay? sourceLocation;
  final OperationGlnDisplay? receivingLocation;
  final String cancelReason;
  
  final String actingGln;
  final String? originalReceivingReference;
  final String? comments;
  final DateTime? eventTime;
  final String? eventTimeZoneOffset;

  Map<String, dynamic> toJson() {
    final eventFields = OperationEventTimeCodec.fieldsForRequest(eventTime);
    return {
      'epcs': epcs,
      'sourceGLN': sourceGLN,
      'receivingGLN': receivingGLN,
      if (sourceLocation != null) 'sourceLocation': sourceLocation!.toJson(),
      if (receivingLocation != null)
        'receivingLocation': receivingLocation!.toJson(),
      'cancelReason': cancelReason,
      'actingGln': actingGln,
      if (originalReceivingReference != null &&
          originalReceivingReference!.isNotEmpty)
        'originalReceivingReference': originalReceivingReference,
      if (comments != null && comments!.isNotEmpty) 'comments': comments,
      'eventTime': eventFields['eventTime'],
      'eventTimeZoneOffset':
          eventTimeZoneOffset ?? eventFields['eventTimeZoneOffset'],
    };
  }
}
