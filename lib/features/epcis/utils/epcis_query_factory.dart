import 'package:traqtrace_app/features/epcis/models/epcis_query_parameters_dto.dart';

/// Factory class for creating common EPCIS query parameters
class EPCISQueryFactory {
  /// Create a query for events by time range
  static EPCISQueryParametersDTO createTimeRangeQuery(
    DateTime startTime,
    DateTime endTime, {
    int? limit,
    int? offset,
    String? orderBy,
    String? orderDirection,
  }) {
    return EPCISQueryParametersDTO(
      startTime: startTime,
      endTime: endTime,
      limit: limit,
      offset: offset,
      orderBy: orderBy,
      orderDirection: orderDirection,
    );
  }

  /// Create a query for events by EPC
  static EPCISQueryParametersDTO createEPCQuery(
    String epc, {
    DateTime? startTime,
    DateTime? endTime,
    int? limit,
    int? offset,
  }) {
    return EPCISQueryParametersDTO(
      epcs: [epc],
      startTime: startTime,
      endTime: endTime,
      limit: limit,
      offset: offset,
    );
  }

  /// Create a query for events by business step
  static EPCISQueryParametersDTO createBusinessStepQuery(
    String businessStep, {
    DateTime? startTime,
    DateTime? endTime,
    int? limit,
    int? offset,
  }) {
    return EPCISQueryParametersDTO(
      businessSteps: [businessStep],
      startTime: startTime,
      endTime: endTime,
      limit: limit,
      offset: offset,
    );
  }

  /// Create a query for events by disposition
  static EPCISQueryParametersDTO createDispositionQuery(
    String disposition, {
    DateTime? startTime,
    DateTime? endTime,
    int? limit,
    int? offset,
  }) {
    return EPCISQueryParametersDTO(
      dispositions: [disposition],
      startTime: startTime,
      endTime: endTime,
      limit: limit,
      offset: offset,
    );
  }

  /// Create a query for events by location
  static EPCISQueryParametersDTO createLocationQuery(
    String locationGLN,
    bool isReadPoint, {
    DateTime? startTime,
    DateTime? endTime,
    int? limit,
    int? offset,
  }) {
    return EPCISQueryParametersDTO(
      readPoints: isReadPoint ? [locationGLN] : null,
      businessLocations: !isReadPoint ? [locationGLN] : null,
      startTime: startTime,
      endTime: endTime,
      limit: limit,
      offset: offset,
    );
  }

  /// Create a complex query with multiple parameters
  static EPCISQueryParametersDTO createComplexQuery({
    List<String>? epcs,
    List<String>? businessSteps,
    List<String>? dispositions,
    List<String>? readPoints,
    List<String>? businessLocations,
    List<String>? eventTypes,
    DateTime? startTime,
    DateTime? endTime,
    int? limit,
    int? offset,
    String? orderBy,
    String? orderDirection,
  }) {
    return EPCISQueryParametersDTO(
      epcs: epcs,
      businessSteps: businessSteps,
      dispositions: dispositions,
      readPoints: readPoints,
      businessLocations: businessLocations,
      eventTypes: eventTypes,
      startTime: startTime,
      endTime: endTime,
      limit: limit,
      offset: offset,
      orderBy: orderBy,
      orderDirection: orderDirection,
    );
  }
}
