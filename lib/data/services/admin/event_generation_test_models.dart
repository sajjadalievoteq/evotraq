class BulkGenerationResult {
  final String sessionId;
  final int generatedCount;
  final String status;
  final List<String> eventIds;
  final DateTime startTime;
  final DateTime? endTime;
  final Map<String, dynamic>? error;

  BulkGenerationResult({
    required this.sessionId,
    required this.generatedCount,
    required this.status,
    required this.eventIds,
    required this.startTime,
    this.endTime,
    this.error,
  });

  factory BulkGenerationResult.fromJson(Map<String, dynamic> json) {
    return BulkGenerationResult(
      sessionId: json['sessionId'],
      generatedCount: json['generatedCount'],
      status: json['status'],
      eventIds: List<String>.from(json['eventIds'] ?? []),
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      error: json['error'],
    );
  }
}

class SimulationSession {
  final String sessionId;
  final String type;
  final String status;
  final Map<String, dynamic> parameters;
  final DateTime startTime;
  final DateTime? endTime;

  SimulationSession({
    required this.sessionId,
    required this.type,
    required this.status,
    required this.parameters,
    required this.startTime,
    this.endTime,
  });

  factory SimulationSession.fromJson(Map<String, dynamic> json) {
    return SimulationSession(
      sessionId: json['sessionId'],
      type: json['type'],
      status: json['status'],
      parameters: Map<String, dynamic>.from(json['parameters']),
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
    );
  }
}

class SimulationResult {
  final String sessionId;
  final int totalEvents;
  final Map<String, int> eventCounts;
  final String status;
  final DateTime startTime;
  final DateTime endTime;
  final int durationMs;

  SimulationResult({
    required this.sessionId,
    required this.totalEvents,
    required this.eventCounts,
    required this.status,
    required this.startTime,
    required this.endTime,
    required this.durationMs,
  });

  factory SimulationResult.fromJson(Map<String, dynamic> json) {
    return SimulationResult(
      sessionId: json['sessionId'],
      totalEvents: json['totalEvents'],
      eventCounts: Map<String, int>.from(json['eventCounts']),
      status: json['status'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      durationMs: json['durationMs'],
    );
  }
}

class SimulationStatus {
  final String sessionId;
  final String status;
  final int currentEvents;
  final double progressPercentage;
  final DateTime? estimatedCompletion;
  final Map<String, dynamic>? currentMetrics;

  SimulationStatus({
    required this.sessionId,
    required this.status,
    required this.currentEvents,
    required this.progressPercentage,
    this.estimatedCompletion,
    this.currentMetrics,
  });

  factory SimulationStatus.fromJson(Map<String, dynamic> json) {
    return SimulationStatus(
      sessionId: json['sessionId'],
      status: json['status'],
      currentEvents: json['currentEvents'],
      progressPercentage: (json['progressPercentage'] as num).toDouble(),
      estimatedCompletion: json['estimatedCompletion'] != null
          ? DateTime.parse(json['estimatedCompletion'])
          : null,
      currentMetrics: json['currentMetrics'],
    );
  }
}

class RealTimeGenerationSession {
  final String sessionId;
  final String status;
  final int eventsPerSecond;
  final Map<String, dynamic> parameters;
  final DateTime startTime;

  RealTimeGenerationSession({
    required this.sessionId,
    required this.status,
    required this.eventsPerSecond,
    required this.parameters,
    required this.startTime,
  });

  factory RealTimeGenerationSession.fromJson(Map<String, dynamic> json) {
    return RealTimeGenerationSession(
      sessionId: json['sessionId'],
      status: json['status'],
      eventsPerSecond: json['eventsPerSecond'],
      parameters: Map<String, dynamic>.from(json['parameters']),
      startTime: DateTime.parse(json['startTime']),
    );
  }
}

class RealTimeGenerationResult {
  final String sessionId;
  final int totalEvents;
  final String status;
  final DateTime startTime;
  final DateTime endTime;
  final double averageEventsPerSecond;

  RealTimeGenerationResult({
    required this.sessionId,
    required this.totalEvents,
    required this.status,
    required this.startTime,
    required this.endTime,
    required this.averageEventsPerSecond,
  });

  factory RealTimeGenerationResult.fromJson(Map<String, dynamic> json) {
    return RealTimeGenerationResult(
      sessionId: json['sessionId'],
      totalEvents: json['totalEvents'],
      status: json['status'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      averageEventsPerSecond: (json['averageEventsPerSecond'] as num)
          .toDouble(),
    );
  }
}

class TimeCompressedSequenceResult {
  final String sequenceId;
  final int totalEvents;
  final double compressionRatio;
  final DateTime originalStartTime;
  final DateTime originalEndTime;
  final DateTime compressedStartTime;
  final DateTime compressedEndTime;
  final List<String> eventIds;

  TimeCompressedSequenceResult({
    required this.sequenceId,
    required this.totalEvents,
    required this.compressionRatio,
    required this.originalStartTime,
    required this.originalEndTime,
    required this.compressedStartTime,
    required this.compressedEndTime,
    required this.eventIds,
  });

  factory TimeCompressedSequenceResult.fromJson(Map<String, dynamic> json) {
    return TimeCompressedSequenceResult(
      sequenceId: json['sequenceId'],
      totalEvents: json['totalEvents'],
      compressionRatio: (json['compressionRatio'] as num).toDouble(),
      originalStartTime: DateTime.parse(json['originalStartTime']),
      originalEndTime: DateTime.parse(json['originalEndTime']),
      compressedStartTime: DateTime.parse(json['compressedStartTime']),
      compressedEndTime: DateTime.parse(json['compressedEndTime']),
      eventIds: List<String>.from(json['eventIds'] ?? []),
    );
  }
}

class RandomizedVariationResult {
  final String variationId;
  final int baselineEvents;
  final int variationEvents;
  final double variationPercentage;
  final Map<String, dynamic> variationStats;
  final List<String> eventIds;

  RandomizedVariationResult({
    required this.variationId,
    required this.baselineEvents,
    required this.variationEvents,
    required this.variationPercentage,
    required this.variationStats,
    required this.eventIds,
  });

  factory RandomizedVariationResult.fromJson(Map<String, dynamic> json) {
    return RandomizedVariationResult(
      variationId: json['variationId'],
      baselineEvents: json['baselineEvents'],
      variationEvents: json['variationEvents'],
      variationPercentage: (json['variationPercentage'] as num).toDouble(),
      variationStats: Map<String, dynamic>.from(json['variationStats']),
      eventIds: List<String>.from(json['eventIds'] ?? []),
    );
  }
}

class AnomalyInjectionResult {
  final String injectionId;
  final int totalEvents;
  final int anomalyCount;
  final List<String> anomalyTypes;
  final Map<String, int> anomalyTypeCounts;
  final List<String> anomalyEventIds;
  final List<String> normalEventIds;

  AnomalyInjectionResult({
    required this.injectionId,
    required this.totalEvents,
    required this.anomalyCount,
    required this.anomalyTypes,
    required this.anomalyTypeCounts,
    required this.anomalyEventIds,
    required this.normalEventIds,
  });

  factory AnomalyInjectionResult.fromJson(Map<String, dynamic> json) {
    return AnomalyInjectionResult(
      injectionId: json['injectionId'],
      totalEvents: json['totalEvents'],
      anomalyCount: json['anomalyCount'],
      anomalyTypes: List<String>.from(json['anomalyTypes'] ?? []),
      anomalyTypeCounts: Map<String, int>.from(json['anomalyTypeCounts']),
      anomalyEventIds: List<String>.from(json['anomalyEventIds'] ?? []),
      normalEventIds: List<String>.from(json['normalEventIds'] ?? []),
    );
  }
}
