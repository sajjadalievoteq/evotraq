import 'package:traqtrace_app/data/models/operations/shared/operation_gln_display.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_event_time_codec.dart';

class DecommissioningRequest {
  DecommissioningRequest({
    required this.epcs,
    required this.locationGLN,
    this.operationLocation,
    required this.disposition,
    this.reason,
    this.comments,
    this.eventTime,
    this.eventTimeZoneOffset,
  });

  List<String> epcs;
  String locationGLN;
  OperationGlnDisplay? operationLocation;
  String disposition;
  String? reason;
  String? comments;
  DateTime? eventTime;
  String? eventTimeZoneOffset;

  Map<String, dynamic> toJson() {
    final eventFields = OperationEventTimeCodec.fieldsForRequest(eventTime);
    return {
      'epcs': epcs,
      'locationGLN': locationGLN,
      if (operationLocation != null)
        'operationLocation': operationLocation!.toJson(),
      'disposition': disposition,
      if (reason != null && reason!.isNotEmpty) 'reason': reason,
      if (comments != null && comments!.isNotEmpty) 'comments': comments,
      'eventTime': eventFields['eventTime'],
      'eventTimeZoneOffset':
          eventTimeZoneOffset ?? eventFields['eventTimeZoneOffset'],
    };
  }

  factory DecommissioningRequest.fromJson(Map<String, dynamic> json) {
    return DecommissioningRequest(
      epcs: (json['epcs'] as List? ?? const [])
          .map((e) => e.toString())
          .toList(),
      locationGLN: (json['locationGLN'] ?? '').toString(),
      disposition: (json['disposition'] ?? '').toString(),
      reason: json['reason']?.toString(),
      comments: json['comments']?.toString(),
      eventTime: json['eventTime'] != null
          ? DateTime.tryParse(json['eventTime'].toString())
          : null,
      eventTimeZoneOffset: json['eventTimeZoneOffset']?.toString(),
    );
  }
}
