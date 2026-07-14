import 'package:equatable/equatable.dart';
import 'package:traqtrace_app/core/utils/cbv_display_utils.dart';
import 'package:traqtrace_app/data/models/epcis/geospatial_coordinates.dart';

enum JourneyStepStatus { completed, inProgress, pending, failed }

class JourneyStep extends Equatable {
  const JourneyStep({
    required this.eventId,
    required this.eventType,
    required this.businessStep,
    required this.businessStepLabel,
    required this.disposition,
    required this.dispositionLabel,
    required this.eventTime,
    this.recordTime,
    this.locationGLN,
    this.locationName,
    this.locationAddress,
    this.coordinates,
    this.action,
    this.parentId,
    this.childEpcs,
    this.ilmd,
    this.status = JourneyStepStatus.completed,
  });

  final String eventId;
  final String eventType;
  final String businessStep;
  final String businessStepLabel;
  final String disposition;
  final String dispositionLabel;
  final DateTime eventTime;
  final DateTime? recordTime;
  final String? locationGLN;
  final String? locationName;
  final String? locationAddress;
  final GeospatialCoordinates? coordinates;
  final String? action;
  final String? parentId;
  final List<String>? childEpcs;
  final Map<String, dynamic>? ilmd;
  final JourneyStepStatus status;

  JourneyStep copyWith({
    String? eventId,
    String? eventType,
    String? businessStep,
    String? businessStepLabel,
    String? disposition,
    String? dispositionLabel,
    DateTime? eventTime,
    DateTime? recordTime,
    String? locationGLN,
    String? locationName,
    String? locationAddress,
    GeospatialCoordinates? coordinates,
    String? action,
    String? parentId,
    List<String>? childEpcs,
    Map<String, dynamic>? ilmd,
    JourneyStepStatus? status,
  }) {
    return JourneyStep(
      eventId: eventId ?? this.eventId,
      eventType: eventType ?? this.eventType,
      businessStep: businessStep ?? this.businessStep,
      businessStepLabel: businessStepLabel ?? this.businessStepLabel,
      disposition: disposition ?? this.disposition,
      dispositionLabel: dispositionLabel ?? this.dispositionLabel,
      eventTime: eventTime ?? this.eventTime,
      recordTime: recordTime ?? this.recordTime,
      locationGLN: locationGLN ?? this.locationGLN,
      locationName: locationName ?? this.locationName,
      locationAddress: locationAddress ?? this.locationAddress,
      coordinates: coordinates ?? this.coordinates,
      action: action ?? this.action,
      parentId: parentId ?? this.parentId,
      childEpcs: childEpcs ?? this.childEpcs,
      ilmd: ilmd ?? this.ilmd,
      status: status ?? this.status,
    );
  }

  factory JourneyStep.fromEventJson(Map<String, dynamic> json) {
    return JourneyStep(
      eventId: json['eventId'] ?? json['id'] ?? '',
      eventType: json['eventType'] ?? _inferEventType(json),
      businessStep: json['businessStep'] ?? '',
      businessStepLabel: CbvDisplayUtils.displayBizStep(json['businessStep']),
      disposition: json['disposition'] ?? '',
      dispositionLabel: CbvDisplayUtils.displayDisposition(json['disposition']),
      eventTime: json['eventTime'] != null
          ? DateTime.parse(json['eventTime'].toString())
          : DateTime.now(),
      recordTime: json['recordTime'] != null
          ? DateTime.parse(json['recordTime'].toString())
          : null,
      locationGLN: json['businessLocation']?.toString(),
      locationName: json['businessLocationName'],
      locationAddress: json['businessLocationAddress'],
      action: json['action'],
      parentId: json['parentID'],
      childEpcs: json['childEPCs'] != null
          ? List<String>.from(json['childEPCs'])
          : null,
      ilmd: json['ilmd'] as Map<String, dynamic>?,
      status: JourneyStepStatus.completed,
    );
  }

  factory JourneyStep.fromBackendStepJson(Map<String, dynamic> json) {
    final businessStep = json['businessStep']?.toString() ?? '';
    final disposition = json['disposition']?.toString() ?? '';
    return JourneyStep(
      eventId: json['eventId']?.toString() ?? '',
      eventType: json['eventType']?.toString() ?? 'ObjectEvent',
      businessStep: businessStep,
      businessStepLabel: CbvDisplayUtils.displayBizStep(businessStep),
      disposition: disposition,
      dispositionLabel: CbvDisplayUtils.displayDisposition(disposition),
      eventTime: json['eventTime'] != null
          ? DateTime.parse(json['eventTime'].toString())
          : DateTime.now(),
      recordTime: json['recordTime'] != null
          ? DateTime.parse(json['recordTime'].toString())
          : null,
      locationGLN: json['locationGLN']?.toString(),
      locationName: json['locationName']?.toString(),
      locationAddress: json['locationAddress']?.toString(),
      coordinates: json['coordinates'] is Map
          ? GeospatialCoordinates.fromJson(
              Map<String, dynamic>.from(json['coordinates'] as Map),
            )
          : null,
      action: json['action']?.toString(),
      parentId: json['parentEpc']?.toString(),
      childEpcs: json['epcs'] != null
          ? List<String>.from(json['epcs'] as List)
          : null,
      ilmd: json['ilmd'] != null
          ? Map<String, dynamic>.from(json['ilmd'] as Map)
          : null,
      status: JourneyStepStatus.completed,
    );
  }

  static String _inferEventType(Map<String, dynamic> json) {
    if (json['parentID'] != null || json['childEPCs'] != null) {
      return 'AggregationEvent';
    }
    if (json['inputEPCList'] != null || json['outputEPCList'] != null) {
      return 'TransformationEvent';
    }
    if (json['bizTransactionList'] != null) return 'TransactionEvent';
    return 'ObjectEvent';
  }

  @override
  List<Object?> get props => [
        eventId,
        eventType,
        businessStep,
        disposition,
        eventTime,
        locationGLN,
        coordinates,
        status,
      ];
}
