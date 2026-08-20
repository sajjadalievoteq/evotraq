import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_dashboard_models.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_records_models.dart';

abstract final class TatmeenRecordsMockData {
  static List<TatmeenSyncRecord> all({DateTime? now}) {
    final at = now ?? DateTime.now().toLocal();
    const types = [
      'Serialized Pack',
      'Aggregation',
      'Shipment',
      'Decommission',
      'Return Receiving',
    ];
    const messages = [
      'Synchronized successfully',
      'Queued for Tatmeen acknowledgment',
      'Remote endpoint timeout after 15s',
      'Authentication token expired while sending batch',
      'Payload rejected: missing mandatory serial metadata',
      'Duplicate transaction reference detected by Tatmeen',
      'Lifecycle status accepted',
      'Dispatch event accepted',
    ];
    return List.generate(36, (index) {
      final status = switch (index % 5) {
        0 => TatmeenSyncStatus.failed,
        1 => TatmeenSyncStatus.pending,
        _ => TatmeenSyncStatus.successful,
      };
      final type = types[index % types.length];
      final failed = status == TatmeenSyncStatus.failed;
      final message = switch (status) {
        TatmeenSyncStatus.successful => messages[index.isEven ? 0 : 6],
        TatmeenSyncStatus.pending => messages[1],
        TatmeenSyncStatus.failed => messages[2 + (index % 4)],
      };
      final attempts = failed ? 1 + (index % 3) : 1;
      return TatmeenSyncRecord(
        id: 'rec-${index + 1}',
        operationId: 'OP-${440100 + index}',
        operationType: type,
        status: status,
        attemptNumber: attempts,
        maxRetries: 3,
        durationMs: failed ? 1520 + index * 17 : 180 + (index * 11) % 900,
        message: message,
        requestPayload: {
          'operationType': type,
          'operationId': 'OP-${440100 + index}',
          'gtin': '6291041500012',
        },
        responseBody: {
          'accepted': !failed,
          'code': failed ? 'TATMEEN_TIMEOUT' : 'OK',
        },
        attemptHistory: [
          for (var attempt = 1; attempt <= attempts; attempt++)
            TatmeenAttemptHistory(
              timestamp: at.subtract(
                Duration(minutes: index * 7 + attempt * 2),
              ),
              errorMessage: failed
                  ? message
                  : (attempt == attempts ? 'Accepted' : message),
            ),
        ],
        createdAt: at.subtract(Duration(minutes: 4 + index * 11)),
      );
    });
  }

  static TatmeenSyncRecordsPage page(TatmeenRecordsQuery query) {
    var items = all();
    if (query.status != TatmeenRecordsStatusFilter.all) {
      final wanted = switch (query.status) {
        TatmeenRecordsStatusFilter.successful => TatmeenSyncStatus.successful,
        TatmeenRecordsStatusFilter.failed => TatmeenSyncStatus.failed,
        TatmeenRecordsStatusFilter.pending => TatmeenSyncStatus.pending,
        TatmeenRecordsStatusFilter.all => null,
      };
      items = items.where((item) => item.status == wanted).toList();
    }
    final search = query.search?.trim().toLowerCase();
    if (search != null && search.isNotEmpty) {
      items = items
          .where(
            (item) =>
                item.operationId.toLowerCase().contains(search) ||
                item.operationType.toLowerCase().contains(search),
          )
          .toList();
    }
    if (query.fromDate != null) {
      final from = DateTime(
        query.fromDate!.year,
        query.fromDate!.month,
        query.fromDate!.day,
      );
      items = items.where((item) => !item.createdAt.isBefore(from)).toList();
    }
    if (query.toDate != null) {
      final to = DateTime(
        query.toDate!.year,
        query.toDate!.month,
        query.toDate!.day,
        23,
        59,
        59,
      );
      items = items.where((item) => !item.createdAt.isAfter(to)).toList();
    }
    final total = items.length;
    final pageSize = query.pageSize <= 0 ? 20 : query.pageSize;
    final page = query.page <= 0 ? 1 : query.page;
    final start = (page - 1) * pageSize;
    final slice = start >= items.length
        ? const <TatmeenSyncRecord>[]
        : items.sublist(
            start,
            start + pageSize > items.length ? items.length : start + pageSize,
          );
    return TatmeenSyncRecordsPage(
      items: slice,
      total: total,
      page: page,
      pageSize: pageSize,
    );
  }
}
