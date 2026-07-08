import 'package:traqtrace_app/data/models/operations/shared/operation_gln_display.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_status.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_type.dart';

class Operation {
  const Operation({
    this.operationId,
    this.operationReference,
    required this.operationType,
    this.processedItemCount,
    this.epcList,
    this.eventIds,
    this.status,
    this.processedAt,
    this.primaryGln,
    this.primaryLocation,
    this.comments,
    this.messages,
    this.processingTimeMs,
    this.metadata = const {},
  });

  final String? operationId;
  final String? operationReference;
  final OperationType operationType;
  final int? processedItemCount;
  final List<String>? epcList;
  final List<String>? eventIds;
  final OperationStatus? status;
  final DateTime? processedAt;
  final String? primaryGln;
  final OperationGlnDisplay? primaryLocation;
  final String? comments;
  final List<String>? messages;
  final int? processingTimeMs;
  final Map<String, dynamic> metadata;

  String? metadataString(String key) {
    final value = metadata[key];
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  int? metadataInt(String key) {
    final value = metadata[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
