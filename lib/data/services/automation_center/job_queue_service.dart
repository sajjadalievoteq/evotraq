import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';

class JobDownloadResult {
  const JobDownloadResult({
    required this.bytes,
    required this.filename,
  });

  final Uint8List bytes;
  final String filename;
}

class JobQueueService {
  JobQueueService({required DioService dioService}) : _dioService = dioService;

  final DioService _dioService;

  Future<Map<String, dynamic>> getDashboard() async {
    final response = await _dioService.get('/jobs/dashboard');
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<List<Map<String, dynamic>>> getActiveJobs() async {
    final response = await _dioService.get('/jobs/active');
    return List<Map<String, dynamic>>.from(response.data as List);
  }

  Future<List<Map<String, dynamic>>> getQueuedJobs({
    String? status,
    int limit = 100,
  }) async {
    final queryParameters = <String, dynamic>{'limit': limit};
    if (status != null && status != 'ALL') {
      queryParameters['status'] = status;
    }
    final response = await _dioService.get(
      '/jobs/queue',
      queryParameters: queryParameters,
    );
    return List<Map<String, dynamic>>.from(response.data as List);
  }

  Future<List<Map<String, dynamic>>> getJobHistory({
    String? jobType,
    int limit = 100,
  }) async {
    final queryParameters = <String, dynamic>{'limit': limit};
    if (jobType != null && jobType != 'ALL') {
      queryParameters['jobType'] = jobType;
    }
    final response = await _dioService.get(
      '/jobs/history',
      queryParameters: queryParameters,
    );
    return List<Map<String, dynamic>>.from(response.data as List);
  }

  Future<Map<String, dynamic>> getWorkerPoolStats() async {
    final response = await _dioService.get('/jobs/worker-pool/stats');
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> getWorkerPoolConfig() async {
    final response = await _dioService.get('/jobs/worker-pool/config');
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> configureWorkerPool({
    required int corePoolSize,
    required int maxPoolSize,
    required int queueCapacity,
  }) async {
    final response = await _dioService.post(
      '/jobs/worker-pool/configure',
      queryParameters: {
        'corePoolSize': corePoolSize,
        'maxPoolSize': maxPoolSize,
        'queueCapacity': queueCapacity,
      },
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> resizeWorkerPool({required int newSize}) async {
    final response = await _dioService.put(
      '/jobs/worker-pool/resize',
      queryParameters: {'newSize': newSize},
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> getQueueHealth() async {
    final response = await _dioService.get('/jobs/health');
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<void> cancelJob(String jobId) async {
    await _dioService.delete('/jobs/$jobId');
  }

  Future<void> retryJob(String jobId) async {
    await _dioService.post('/jobs/$jobId/retry');
  }

  Future<void> pauseQueue() async {
    await _dioService.post('/jobs/pause');
  }

  Future<void> resumeQueue() async {
    await _dioService.post('/jobs/resume');
  }

  Future<Map<String, dynamic>> purgeJobs({int retentionDays = 30}) async {
    final response = await _dioService.delete(
      '/jobs/purge',
      queryParameters: {'retentionDays': retentionDays},
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<void> submitJob({
    required String jobType,
    required int priority,
    required Map<String, dynamic> payload,
  }) async {
    await _dioService.post(
      '/jobs/submit',
      queryParameters: {
        'jobType': jobType,
        'priority': priority,
      },
      data: payload,
    );
  }

  Future<JobDownloadResult> downloadJobResult(String jobId) async {
    final response = await _dioService.get(
      '/jobs/$jobId/download',
      responseType: ResponseType.bytes,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to download job result: ${response.statusCode}');
    }

    String filename = 'export_data.csv';
    final cdHdr = response.headers['content-disposition'];
    final contentDisposition =
        cdHdr != null && cdHdr.isNotEmpty ? cdHdr.first : null;
    if (contentDisposition != null) {
      final match =
          RegExp(r'filename="([^"]+)"').firstMatch(contentDisposition);
      if (match != null) {
        filename = match.group(1)!;
      }
    }

    final raw = response.data;
    final bytes = raw is Uint8List
        ? raw
        : Uint8List.fromList(List<int>.from(raw as List));

    return JobDownloadResult(bytes: bytes, filename: filename);
  }
}
