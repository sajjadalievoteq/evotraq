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

  @override
  List<Object?> get props => [timestamp, recordType, recordId, status, message];
}

class TatmeenErrorSummaryItem extends Equatable {
  const TatmeenErrorSummaryItem({required this.message, required this.count});

  final String message;
  final int count;

  @override
  List<Object?> get props => [message, count];
}
