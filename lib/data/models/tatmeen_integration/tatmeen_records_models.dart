import 'package:equatable/equatable.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_dashboard_models.dart';

enum TatmeenRecordsStatusFilter { all, successful, failed, pending }

enum TatmeenRecordsSource { kpiCard, recentActivity }

class RecordsFilter extends Equatable {
  const RecordsFilter({
    required this.status,
    required this.source,
  });

  const RecordsFilter.kpi(this.status) : source = TatmeenRecordsSource.kpiCard;

  const RecordsFilter.recentActivity()
    : status = TatmeenRecordsStatusFilter.all,
      source = TatmeenRecordsSource.recentActivity;

  final TatmeenRecordsStatusFilter status;
  final TatmeenRecordsSource source;

  String get title => switch (status) {
    TatmeenRecordsStatusFilter.all => 'All Sync Records',
    TatmeenRecordsStatusFilter.successful => 'Successful Syncs',
    TatmeenRecordsStatusFilter.failed => 'Failed Syncs',
    TatmeenRecordsStatusFilter.pending => 'Pending Syncs',
  };

  String get statusLabel => switch (status) {
    TatmeenRecordsStatusFilter.all => 'all',
    TatmeenRecordsStatusFilter.successful => 'successful',
    TatmeenRecordsStatusFilter.failed => 'failed',
    TatmeenRecordsStatusFilter.pending => 'pending',
  };

  RecordsFilter copyWith({
    TatmeenRecordsStatusFilter? status,
    TatmeenRecordsSource? source,
  }) {
    return RecordsFilter(
      status: status ?? this.status,
      source: source ?? this.source,
    );
  }

  static RecordsFilter fromExtra(Object? extra) {
    if (extra is RecordsFilter) return extra;
    if (extra is Map) {
      final statusName = extra['status']?.toString();
      final sourceName = extra['source']?.toString();
      return RecordsFilter(
        status: TatmeenRecordsStatusFilter.values.firstWhere(
          (value) => value.name == statusName,
          orElse: () => TatmeenRecordsStatusFilter.all,
        ),
        source: TatmeenRecordsSource.values.firstWhere(
          (value) => value.name == sourceName,
          orElse: () => TatmeenRecordsSource.kpiCard,
        ),
      );
    }
    return const RecordsFilter(
      status: TatmeenRecordsStatusFilter.all,
      source: TatmeenRecordsSource.kpiCard,
    );
  }

  @override
  List<Object?> get props => [status, source];
}

class TatmeenAttemptHistory extends Equatable {
  const TatmeenAttemptHistory({
    required this.timestamp,
    required this.errorMessage,
  });

  final DateTime timestamp;
  final String errorMessage;

  factory TatmeenAttemptHistory.fromJson(Map<String, dynamic> json) {
    return TatmeenAttemptHistory(
      timestamp: DateTime.parse(json['timestamp'] as String).toLocal(),
      errorMessage: json['errorMessage'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [timestamp, errorMessage];
}

class TatmeenSyncRecord extends Equatable {
  const TatmeenSyncRecord({
    required this.id,
    required this.operationId,
    required this.operationType,
    required this.status,
    required this.attemptNumber,
    required this.maxRetries,
    required this.durationMs,
    required this.message,
    required this.requestPayload,
    required this.responseBody,
    required this.attemptHistory,
    required this.createdAt,
  });

  final String id;
  final String operationId;
  final String operationType;
  final TatmeenSyncStatus status;
  final int attemptNumber;
  final int maxRetries;
  final int durationMs;
  final String message;
  final Map<String, dynamic> requestPayload;
  final Map<String, dynamic> responseBody;
  final List<TatmeenAttemptHistory> attemptHistory;
  final DateTime createdAt;

  String get durationLabel {
    if (durationMs < 1000) return '${durationMs}ms';
    return '${(durationMs / 1000).toStringAsFixed(1)}s';
  }

  String get attemptsLabel => '$attemptNumber / $maxRetries';

  String get truncatedMessage {
    if (message.length <= 60) return message;
    return '${message.substring(0, 60)}…';
  }

  factory TatmeenSyncRecord.fromJson(Map<String, dynamic> json) {
    return TatmeenSyncRecord(
      id: json['id'] as String,
      operationId: json['operationId'] as String,
      operationType: json['operationType'] as String,
      status: _statusFrom(json['status']),
      attemptNumber: json['attemptNumber'] as int? ?? 1,
      maxRetries: json['maxRetries'] as int? ?? 3,
      durationMs: json['durationMs'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      requestPayload: Map<String, dynamic>.from(
        (json['requestPayload'] as Map?) ?? const {},
      ),
      responseBody: Map<String, dynamic>.from(
        (json['responseBody'] as Map?) ?? const {},
      ),
      attemptHistory: [
        for (final item in (json['attemptHistory'] as List? ?? const []))
          if (item is Map)
            TatmeenAttemptHistory.fromJson(Map<String, dynamic>.from(item)),
      ],
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
    );
  }

  static TatmeenSyncStatus _statusFrom(Object? value) {
    return switch (value?.toString()) {
      'successful' => TatmeenSyncStatus.successful,
      'failed' => TatmeenSyncStatus.failed,
      'pending' => TatmeenSyncStatus.pending,
      _ => TatmeenSyncStatus.pending,
    };
  }

  @override
  List<Object?> get props => [
    id,
    operationId,
    operationType,
    status,
    attemptNumber,
    maxRetries,
    durationMs,
    message,
    requestPayload,
    responseBody,
    attemptHistory,
    createdAt,
  ];
}

class TatmeenSyncRecordsPage extends Equatable {
  const TatmeenSyncRecordsPage({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  final List<TatmeenSyncRecord> items;
  final int total;
  final int page;
  final int pageSize;

  int get totalPages {
    if (pageSize <= 0) return 1;
    final pages = (total / pageSize).ceil();
    return pages < 1 ? 1 : pages;
  }

  factory TatmeenSyncRecordsPage.fromJson(Map<String, dynamic> json) {
    return TatmeenSyncRecordsPage(
      items: [
        for (final item in (json['items'] as List? ?? const []))
          if (item is Map)
            TatmeenSyncRecord.fromJson(Map<String, dynamic>.from(item)),
      ],
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 20,
    );
  }

  @override
  List<Object?> get props => [items, total, page, pageSize];
}

class TatmeenRecordsQuery {
  const TatmeenRecordsQuery({
    required this.status,
    this.fromDate,
    this.toDate,
    this.search,
    this.page = 1,
    this.pageSize = 20,
  });

  final TatmeenRecordsStatusFilter status;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? search;
  final int page;
  final int pageSize;
}

/// Result of a manual Tatmeen retry attempt, with a ready-to-display user message.
class TatmeenRetryOutcome {
  const TatmeenRetryOutcome._({required this.succeeded, required this.message});

  final bool succeeded;
  final String message;

  const TatmeenRetryOutcome.success()
      : succeeded = true,
        message = 'Retry successful! The record has been synced to Tatmeen.';

  factory TatmeenRetryOutcome.failure(String message) =>
      TatmeenRetryOutcome._(succeeded: false, message: message);
}
