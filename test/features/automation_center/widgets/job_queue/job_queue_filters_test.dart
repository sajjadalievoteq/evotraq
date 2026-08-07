import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/utils/job_queue_filters.dart';

void main() {
  final queue = <Map<String, dynamic>>[
    {'jobId': 'Q1', 'status': 'QUEUED'},
    {'jobId': 'Q2', 'status': 'QUEUED'},
    {'jobId': 'R1', 'status': 'RUNNING'},
  ];

  final history = <Map<String, dynamic>>[
    {'jobId': 'H1', 'jobType': 'NOTIFICATION_BATCH', 'status': 'COMPLETED'},
    {'jobId': 'H2', 'jobType': 'EXPORT', 'status': 'FAILED'},
  ];

  group('JobQueueFilters.byStatus', () {
    test('ALL returns everything', () {
      expect(JobQueueFilters.byStatus(queue, 'ALL').length, 3);
    });

    test('QUEUED returns only queued jobs', () {
      final result = JobQueueFilters.byStatus(queue, 'QUEUED');
      expect(result.map((j) => j['jobId']), ['Q1', 'Q2']);
    });

    test('RUNNING returns only running jobs', () {
      final result = JobQueueFilters.byStatus(queue, 'RUNNING');
      expect(result.map((j) => j['jobId']), ['R1']);
    });

    test('a status absent from the queue yields an empty list', () {
      expect(JobQueueFilters.byStatus(queue, 'COMPLETED'), isEmpty);
    });
  });

  group('JobQueueFilters.byJobType', () {
    test('ALL returns everything', () {
      expect(JobQueueFilters.byJobType(history, 'ALL').length, 2);
    });

    test('filters by job type', () {
      final result = JobQueueFilters.byJobType(history, 'EXPORT');
      expect(result.map((j) => j['jobId']), ['H2']);
    });
  });
}
