import '../../core/network/http_service.dart';


class ETLService {
  final HttpService _httpService;

  ETLService(this._httpService);

  Future<List<Map<String, dynamic>>> getPipelines({String? status}) async {
    final queryParameters = <String, dynamic>{};
    if (status != null && status != 'ALL') {
      queryParameters['status'] = status;
    }
    final response = await _httpService.get('/etl/pipelines', queryParameters: queryParameters);
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<List<Map<String, dynamic>>> getTransformations({String? type}) async {
    final queryParameters = <String, dynamic>{};
    if (type != null && type != 'ALL') {
      queryParameters['type'] = type;
    }
    final response = await _httpService.get('/etl/transformations', queryParameters: queryParameters);
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<List<Map<String, dynamic>>> getExecutionHistory({int limit = 50}) async {
    final response = await _httpService.get('/etl/executions', queryParameters: {'limit': limit});
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<Map<String, dynamic>> getQualityMetrics() async {
    final response = await _httpService.get('/etl/quality-metrics');
    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> getPerformanceData() async {
    final response = await _httpService.get('/etl/performance');
    return Map<String, dynamic>.from(response.data);
  }

  Future<void> toggleTransformation(String transformationId, bool enabled) async {
    await _httpService.put(
      '/etl/transformations/$transformationId/toggle',
      data: {'enabled': enabled},
    );
  }

  Future<void> executePipeline(String pipelineId) async {
    await _httpService.post('/etl/pipelines/$pipelineId/execute');
  }

  Future<void> deletePipeline(String pipelineId) async {
    await _httpService.delete('/etl/pipelines/$pipelineId');
  }

  Future<void> deleteTransformation(String transformationId) async {
    await _httpService.delete('/etl/transformations/$transformationId');
  }

  Future<Map<String, dynamic>> testTransformation(String transformationId) async {
    final response = await _httpService.post('/etl/transformations/$transformationId/test');
    return Map<String, dynamic>.from(response.data);
  }

  Future<void> createPipeline(String pipelineName, List<Map<String, dynamic>> transformationRules) async {
    await _httpService.post(
      '/etl/pipelines',
      queryParameters: {'pipelineName': pipelineName},
      data: transformationRules,
    );
  }

  Future<void> updatePipeline(String pipelineId, List<Map<String, dynamic>> transformationRules) async {
    await _httpService.put(
      '/etl/pipelines/$pipelineId',
      data: transformationRules,
    );
  }

  Future<void> createETLJob(Map<String, dynamic> jobConfig) async {
    await _httpService.post('/etl/jobs', data: jobConfig);
  }
}
