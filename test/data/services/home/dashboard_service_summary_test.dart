import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/data/models/home/dashboard_stats.dart';
import 'package:traqtrace_app/data/models/home/recent_event.dart';

void main() {
  group('DashboardStats.fromSummaryJson', () {
    test('maps counts, eventCounts, recent event fields, and throughput', () {
      final json = {
        'counts': {
          'gtin': 1,
          'gln': 2,
          'sgtin': 3,
          'sscc': 4,
        },
        'eventCounts': {
          'Object': 10,
          'Aggregation': 5,
          'Transaction': 3,
          'Transformation': 2,
          'totalEvents': 20,
        },
        'recentEvents': [
          {
            'id': 'evt-1',
            'eventType': 'ObjectEvent',
            'action': 'ADD',
            'businessStep': 'commissioning',
            'eventTime': '2026-07-14T10:00:00.000Z',
            'epcList': ['urn:epc:id:sgtin:0614141.107346.1'],
            'ilmd': {
              'traqtrace:gtin': '00614141107346',
              'cbvmda:lotNumber': 'LOT-1',
            },
          },
        ],
        'throughput': {
          'windowHours': 24,
          'totalCount': 42,
          'buckets': [
            {'hourIndex': 0, 'count': 10},
            {'hourIndex': 1, 'count': 32},
          ],
        },
      };

      final stats = DashboardStats.fromSummaryJson(json);
      expect(stats.gtinCount, 1);
      expect(stats.glnCount, 2);
      expect(stats.sgtinCount, 3);
      expect(stats.ssccCount, 4);
      expect(stats.totalEvents, 20);
      expect(stats.eventsByType['Object'], 10);
      expect(stats.eventsByType['Aggregation'], 5);
      expect(stats.throughputTotal, 42);
      expect(stats.throughputBuckets[0], 10);
      expect(stats.throughputBuckets[1], 32);

      final event = RecentEvent.fromJson(
        Map<String, dynamic>.from(
          (json['recentEvents'] as List).first as Map,
        ),
      );
      expect(event.eventType, 'ObjectEvent');
      expect(event.action, 'ADD');
      expect(event.bizStep, 'commissioning');
      expect(event.epcList, ['urn:epc:id:sgtin:0614141.107346.1']);
      expect(event.gtinCode, '00614141107346');
      expect(event.batchLotNumber, 'LOT-1');
    });
  });
}
