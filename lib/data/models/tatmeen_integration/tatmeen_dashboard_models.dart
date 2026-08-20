import 'package:equatable/equatable.dart';

class TatmeenDashboardStats extends Equatable {
  const TatmeenDashboardStats({
    required this.totalSynced,
    required this.successfulThisMonth,
    required this.failedThisMonth,
    required this.pendingInQueue,
    required this.successfulTrendPct,
    required this.failedTrendPct,
    required this.pendingTrendPct,
    required this.lastSyncedAt,
  });

  final int totalSynced;
  final int successfulThisMonth;
  final int failedThisMonth;
  final int pendingInQueue;
  final double successfulTrendPct;
  final double failedTrendPct;
  final double pendingTrendPct;
  final DateTime lastSyncedAt;

  factory TatmeenDashboardStats.fromJson(Map<String, dynamic> json) {
    return TatmeenDashboardStats(
      totalSynced: _int(json['totalSynced']),
      successfulThisMonth: _int(json['successfulThisMonth']),
      failedThisMonth: _int(json['failedThisMonth']),
      pendingInQueue: _int(json['pendingInQueue']),
      successfulTrendPct: _double(json['successfulTrendPct']),
      failedTrendPct: _double(json['failedTrendPct']),
      pendingTrendPct: _double(json['pendingTrendPct']),
      lastSyncedAt: DateTime.parse(
        json['lastSyncedAt'] as String,
      ).toLocal(),
    );
  }

  static int _int(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _double(Object? value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  @override
  List<Object?> get props => [
    totalSynced,
    successfulThisMonth,
    failedThisMonth,
    pendingInQueue,
    successfulTrendPct,
    failedTrendPct,
    pendingTrendPct,
    lastSyncedAt,
  ];
}

class TatmeenChartPoint extends Equatable {
  const TatmeenChartPoint({
    required this.date,
    required this.successful,
    required this.failed,
  });

  final DateTime date;
  final int successful;
  final int failed;

  factory TatmeenChartPoint.fromJson(Map<String, dynamic> json) {
    final dateRaw = json['date'] as String? ?? '';
    return TatmeenChartPoint(
      date: DateTime.parse(dateRaw),
      successful: TatmeenDashboardStats._int(json['successful']),
      failed: TatmeenDashboardStats._int(json['failed']),
    );
  }

  @override
  List<Object?> get props => [date, successful, failed];
}

class TatmeenStatusBreakdown extends Equatable {
  const TatmeenStatusBreakdown({
    required this.successful,
    required this.failed,
    required this.pending,
  });

  final int successful;
  final int failed;
  final int pending;

  int get total => successful + failed + pending;

  factory TatmeenStatusBreakdown.fromJson(Map<String, dynamic> json) {
    return TatmeenStatusBreakdown(
      successful: TatmeenDashboardStats._int(json['successful']),
      failed: TatmeenDashboardStats._int(json['failed']),
      pending: TatmeenDashboardStats._int(json['pending']),
    );
  }

  @override
  List<Object?> get props => [successful, failed, pending];
}

enum TatmeenSyncStatus { successful, failed, pending }

class TatmeenSyncEvent extends Equatable {
  const TatmeenSyncEvent({
    required this.timestamp,
    required this.recordType,
    required this.recordId,
    required this.status,
    required this.message,
  });

  final DateTime timestamp;
  final String recordType;
  final String recordId;
  final TatmeenSyncStatus status;
  final String message;

  factory TatmeenSyncEvent.fromJson(Map<String, dynamic> json) {
    return TatmeenSyncEvent(
      timestamp: DateTime.parse(json['timestamp'] as String).toLocal(),
      recordType: json['recordType'] as String? ?? 'Sync',
      recordId: json['recordId'] as String? ?? '',
      status: _statusFrom(json['status']),
      message: json['message'] as String? ?? '',
    );
  }

  static TatmeenSyncStatus _statusFrom(Object? value) {
    return switch (value?.toString().toLowerCase()) {
      'successful' => TatmeenSyncStatus.successful,
      'failed' => TatmeenSyncStatus.failed,
      'pending' => TatmeenSyncStatus.pending,
      _ => TatmeenSyncStatus.pending,
    };
  }

  @override
  List<Object?> get props => [timestamp, recordType, recordId, status, message];
}

class TatmeenErrorSummaryItem extends Equatable {
  const TatmeenErrorSummaryItem({required this.message, required this.count});

  final String message;
  final int count;

  factory TatmeenErrorSummaryItem.fromJson(Map<String, dynamic> json) {
    return TatmeenErrorSummaryItem(
      message: json['message'] as String? ?? '',
      count: TatmeenDashboardStats._int(json['count']),
    );
  }

  @override
  List<Object?> get props => [message, count];
}
