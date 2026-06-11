// ValidationRule model for Phase 3: Event Validation Service
// Matches the backend ValidationRule entity structure

import 'package:flutter/material.dart';

enum EventType {
  ALL,
  ObjectEvent,
  AggregationEvent,
  TransactionEvent,
  TransformationEvent,
}

extension EventTypeExtension on EventType {
  String replaceAll(String pattern, String replacement) {
    return toString().split('.').last.replaceAll(pattern, replacement);
  }
}

enum RuleSeverity {
  ERROR,
  WARNING,
  INFO,
}

extension RuleSeverityExtension on RuleSeverity {
  String get displayName {
    switch (this) {
      case RuleSeverity.INFO:
        return 'Info';
      case RuleSeverity.WARNING:
        return 'Warning';
      case RuleSeverity.ERROR:
        return 'Error';
    }
  }

  Color get color {
    switch (this) {
      case RuleSeverity.INFO:
        return Colors.blue;
      case RuleSeverity.WARNING:
        return Colors.orange;
      case RuleSeverity.ERROR:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (this) {
      case RuleSeverity.INFO:
        return Icons.info;
      case RuleSeverity.WARNING:
        return Icons.warning;
      case RuleSeverity.ERROR:
        return Icons.error;
    }
  }

  bool get failsValidation {
    return this == RuleSeverity.ERROR;
  }
}

class ValidationRule {
  final int? id;
  final String ruleId;
  final String name;
  final String? description;
  final EventType? eventType;
  final RuleSeverity severity;
  final bool enabled;
  final bool isCustom;
  final String? ruleExpression;
  final String? errorMessage;
  final String? category;
  final List<String>? tags;
  final String? createdBy;
  final String? updatedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? validationExpression;
  final String? uuid;
  final int? priority;
  final String? field;

  ValidationRule({
    this.id,
    required this.ruleId,
    required this.name,
    this.description,
    this.eventType,
    required this.severity,
    this.enabled = true,
    this.isCustom = true,
    this.ruleExpression,
    this.errorMessage,
    this.category,
    this.tags,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
    this.validationExpression,
    this.uuid,
    this.priority,
    this.field,
  });

  /// Parse EventType from backend string values
  static EventType? _parseEventTypeFromString(String? eventTypeString) {
    if (eventTypeString == null) return null;
    
    switch (eventTypeString) {
      case 'All':
      case 'ALL':
        return EventType.ALL;
      case 'ObjectEvent':
        return EventType.ObjectEvent;
      case 'AggregationEvent':
        return EventType.AggregationEvent;
      case 'TransactionEvent':
        return EventType.TransactionEvent;
      case 'TransformationEvent':
        return EventType.TransformationEvent;
      default:
        return EventType.ALL; // Default fallback
    }
  }

  /// Convert EventType to backend string format
  static String _eventTypeToString(EventType eventType) {
    switch (eventType) {
      case EventType.ALL:
        return 'All'; // Backend expects "All", not "ALL"
      case EventType.ObjectEvent:
        return 'ObjectEvent';
      case EventType.AggregationEvent:
        return 'AggregationEvent';
      case EventType.TransactionEvent:
        return 'TransactionEvent';
      case EventType.TransformationEvent:
        return 'TransformationEvent';
    }
  }

  // Convert from JSON (from API response)
  factory ValidationRule.fromJson(Map<String, dynamic> json) {
    return ValidationRule(
      id: json['id'],
      ruleId: json['ruleId'] ?? json['rule_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      eventType: json['eventType'] != null 
          ? _parseEventTypeFromString(json['eventType'])
          : null,
      severity: RuleSeverity.values.firstWhere(
        (e) => e.toString().split('.').last == json['severity'],
        orElse: () => RuleSeverity.ERROR,
      ),
      enabled: json['enabled'] ?? true,
      isCustom: json['isCustom'] ?? json['is_custom'] ?? true,
      ruleExpression: json['ruleExpression'] ?? json['rule_expression'],
      errorMessage: json['errorMessage'] ?? json['error_message'],
      category: json['category'],
      tags: json['tags'] != null 
          ? (json['tags'] as String).split(',').map((e) => e.trim()).toList()
          : null,
      createdBy: json['createdBy'] ?? json['created_by'],
      updatedBy: json['updatedBy'] ?? json['updated_by'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : json['created_at'] != null 
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'])
          : json['updated_at'] != null 
              ? DateTime.parse(json['updated_at'])
              : null,
      validationExpression: json['validationExpression'] ?? json['validation_expression'],
      uuid: json['uuid'],
      priority: json['priority'] ?? 100,
      field: json['field'] ?? json['fieldPath'] ?? json['field_path'],
    );
  }

  // Convert to JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'ruleId': ruleId,
      'name': name,
      if (description != null) 'description': description,
      if (eventType != null) 'eventType': _eventTypeToString(eventType!),
      'severity': severity.toString().split('.').last,
      'enabled': enabled,
      'isCustom': isCustom,
      if (ruleExpression != null) 'ruleExpression': ruleExpression,
      if (errorMessage != null) 'errorMessage': errorMessage,
      if (category != null) 'category': category,
      if (tags != null) 'tags': tags!.join(','),
      if (createdBy != null) 'createdBy': createdBy,
      if (updatedBy != null) 'updatedBy': updatedBy,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (validationExpression != null) 'validationExpression': validationExpression,
      if (uuid != null) 'uuid': uuid,
      if (priority != null) 'priority': priority,
      if (field != null) 'field': field,
    };
  }

  // Create a copy with updated fields
  ValidationRule copyWith({
    int? id,
    String? ruleId,
    String? name,
    String? description,
    EventType? eventType,
    RuleSeverity? severity,
    bool? enabled,
    bool? isCustom,
    String? ruleExpression,
    String? errorMessage,
    String? category,
    List<String>? tags,
    String? createdBy,
    String? updatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? validationExpression,
    String? uuid,
    int? priority,
    String? field,
  }) {
    return ValidationRule(
      id: id ?? this.id,
      ruleId: ruleId ?? this.ruleId,
      name: name ?? this.name,
      description: description ?? this.description,
      eventType: eventType ?? this.eventType,
      severity: severity ?? this.severity,
      enabled: enabled ?? this.enabled,
      isCustom: isCustom ?? this.isCustom,
      ruleExpression: ruleExpression ?? this.ruleExpression,
      errorMessage: errorMessage ?? this.errorMessage,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      validationExpression: validationExpression ?? this.validationExpression,
      uuid: uuid ?? this.uuid,
      priority: priority ?? this.priority,
      field: field ?? this.field,
    );
  }

  @override
  String toString() {
    return 'ValidationRule{id: $id, ruleId: $ruleId, name: $name, enabled: $enabled, severity: $severity}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ValidationRule &&
        other.id == id &&
        other.ruleId == ruleId &&
        other.name == name &&
        other.enabled == enabled &&
        other.severity == severity;
  }

  @override
  int get hashCode {
    return Object.hash(id, ruleId, name, enabled, severity);
  }
}
