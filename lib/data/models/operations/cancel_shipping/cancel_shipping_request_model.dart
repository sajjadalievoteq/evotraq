import 'package:traqtrace_app/data/models/operations/shared/operation_gln_display.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_event_time_codec.dart';

class CancelShippingRequest {
  const CancelShippingRequest({
    required this.epcs,
    required this.sourceGLN,
    required this.destinationGLN,
    this.sourceLocation,
    this.destinationLocation,
    required this.cancelReason,
    required this.actingGln,
    this.originalShippingReference,
    this.comments,
    this.eventTime,
    this.eventTimeZoneOffset,
  });

  final List<String> epcs;
  final String sourceGLN;
  final String destinationGLN;
  final OperationGlnDisplay? sourceLocation;
  final OperationGlnDisplay? destinationLocation;
  final String cancelReason;
  /// Shipper / source GLN authorizing the cancel (CX-7).
  final String actingGln;
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
      if (sourceLocation != null) 'sourceLocation': sourceLocation!.toJson(),
      if (destinationLocation != null)
        'destinationLocation': destinationLocation!.toJson(),
      'cancelReason': cancelReason,
      'actingGln': actingGln,
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
