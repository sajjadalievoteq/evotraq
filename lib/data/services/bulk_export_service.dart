import '../../core/network/dio_service.dart';


class BulkExportService {
  final DioService _dioService;

  BulkExportService(this._dioService);

  Future<List<Map<String, dynamic>>> getExportJobs({String? format, String? status}) async {
    final Map<String, dynamic> queryParameters = {};
    if (format != null && format != 'ALL') {
      queryParameters['format'] = format;
    }
    if (status != null && status != 'ALL') {
      queryParameters['status'] = status;
    }

    final response = await _dioService.get('/bulk-export/jobs', queryParameters: queryParameters);
    return List<Map<String, dynamic>>.from(response.data as List);
  }

  Future<List<Map<String, dynamic>>> getExportTemplates() async {
    final response = await _dioService.get('/bulk-export/templates');
    return List<Map<String, dynamic>>.from(response.data as List);
  }

  Future<List<Map<String, dynamic>>> getExportHistory({int limit = 100}) async {
    final response = await _dioService.get('/bulk-export/history', queryParameters: {'limit': limit});
    return List<Map<String, dynamic>>.from(response.data as List);
  }

  Future<Map<String, dynamic>> getExportStatistics() async {
    final response = await _dioService.get('/bulk-export/statistics');
    return response.data as Map<String, dynamic>;
  }

  Future<void> cancelExport(String jobId) async {
    await _dioService.delete('/bulk-export/jobs/$jobId');
  }

  Future<void> retryExport(String jobId) async {
    await _dioService.post('/bulk-export/jobs/$jobId/retry');
  }

  Future<void> executeExportJob(String jobId) async {
    await _dioService.post('/bulk-export/jobs/$jobId/execute');
  }

  Future<void> deleteExport(String jobId) async {
    await _dioService.delete('/bulk-export/jobs/$jobId/delete');
  }

  Future<void> duplicateTemplate(String templateId) async {
    await _dioService.post('/bulk-export/templates/$templateId/duplicate');
  }

  Future<void> exportTemplateConfig(String templateId) async {
    await _dioService.get('/bulk-export/templates/$templateId/export');
  }

  Future<void> deleteTemplate(String templateId) async {
    await _dioService.delete('/bulk-export/templates/$templateId');
  }

  Future<Map<String, dynamic>> applyTemplate(String templateId, Map<String, dynamic> params) async {
    final response = await _dioService.post(
      '/bulk-export/templates/$templateId/apply',
      data: params,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createExportJob(Map<String, dynamic> data) async {
    final response = await _dioService.post(
      '/bulk-export/jobs',
      data: data,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createStreamingExport(Map<String, dynamic> data) async {
    final response = await _dioService.post(
      '/bulk-export/streaming',
      data: data,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createPaginatedExport(Map<String, dynamic> data) async {
    final response = await _dioService.post(
      '/bulk-export/paginated',
      data: data,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<void> downloadExport(String downloadUrl) async {
    await _dioService.get(downloadUrl);
  }
}
