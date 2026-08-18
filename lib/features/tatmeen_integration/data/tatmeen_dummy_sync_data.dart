import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_dashboard_models.dart';

class TatmeenFailedQueueItem {
  const TatmeenFailedQueueItem({
    required this.event,
    required this.attempts,
  });

  final TatmeenSyncEvent event;
  final int attempts;
}

abstract final class TatmeenDummySyncData {
  static List<TatmeenFailedQueueItem> failedQueue({DateTime? now}) {
    final at = now ?? DateTime.now().toLocal();
    return [
      _failed(
        at,
        minutes: 8,
        type: 'Shipment',
        id: 'SHIP-440128',
        message: 'Remote endpoint timeout after 15s',
        attempts: 3,
      ),
      _failed(
        at,
        minutes: 22,
        type: 'Serialized Pack',
        id: 'SGTIN-6291041500012.44112200',
        message: 'Authentication token expired while sending batch',
        attempts: 2,
      ),
      _failed(
        at,
        minutes: 41,
        type: 'Aggregation',
        id: 'AGG-882104',
        message: 'Payload rejected: missing mandatory serial metadata',
        attempts: 4,
      ),
      _failed(
        at,
        minutes: 63,
        type: 'Decommission',
        id: 'SGTIN-6291041500012.77001122',
        message: 'Duplicate transaction reference detected by Tatmeen',
        attempts: 1,
      ),
      _failed(
        at,
        minutes: 88,
        type: 'Return Receiving',
        id: 'RET-88221',
        message: 'Transport unavailable: TLS handshake failure',
        attempts: 3,
      ),
      _failed(
        at,
        minutes: 110,
        type: 'Shipment',
        id: 'SHIP-440901',
        message: 'Remote endpoint timeout after 15s',
        attempts: 2,
      ),
      _failed(
        at,
        minutes: 147,
        type: 'Serialized Pack',
        id: 'SGTIN-6291041500012.11990033',
        message: 'Payload rejected: missing mandatory serial metadata',
        attempts: 5,
      ),
      _failed(
        at,
        minutes: 186,
        type: 'Aggregation',
        id: 'AGG-901445',
        message: 'Authentication token expired while sending batch',
        attempts: 1,
      ),
    ];
  }

  static List<TatmeenSyncEvent> syncLogs({DateTime? now}) {
    final at = now ?? DateTime.now().toLocal();
    final failed = failedQueue(now: at).map((item) => item.event).toList();
    return [
      TatmeenSyncEvent(
        timestamp: at.subtract(const Duration(minutes: 3)),
        recordType: 'Serialized Pack',
        recordId: 'SGTIN-6291041500012.99887766',
        status: TatmeenSyncStatus.successful,
        message: 'Synchronized successfully',
      ),
      TatmeenSyncEvent(
        timestamp: at.subtract(const Duration(minutes: 6)),
        recordType: 'Aggregation',
        recordId: 'AGG-782991',
        status: TatmeenSyncStatus.pending,
        message: 'Queued for Tatmeen acknowledgment',
      ),
      ...failed.take(3),
      TatmeenSyncEvent(
        timestamp: at.subtract(const Duration(minutes: 26)),
        recordType: 'Decommission',
        recordId: 'SGTIN-6291041500012.88776611',
        status: TatmeenSyncStatus.successful,
        message: 'Lifecycle status accepted',
      ),
      TatmeenSyncEvent(
        timestamp: at.subtract(const Duration(minutes: 34)),
        recordType: 'Return Receiving',
        recordId: 'RET-77109',
        status: TatmeenSyncStatus.successful,
        message: 'Synchronized successfully',
      ),
      ...failed.skip(3),
      TatmeenSyncEvent(
        timestamp: at.subtract(const Duration(hours: 4, minutes: 12)),
        recordType: 'Shipment',
        recordId: 'SHIP-339002',
        status: TatmeenSyncStatus.successful,
        message: 'Dispatch event accepted',
      ),
    ]..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  static TatmeenFailedQueueItem _failed(
    DateTime at, {
    required int minutes,
    required String type,
    required String id,
    required String message,
    required int attempts,
  }) {
    return TatmeenFailedQueueItem(
      attempts: attempts,
      event: TatmeenSyncEvent(
        timestamp: at.subtract(Duration(minutes: minutes)),
        recordType: type,
        recordId: id,
        status: TatmeenSyncStatus.failed,
        message: message,
      ),
    );
  }
}
