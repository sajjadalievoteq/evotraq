class ApiConfig {
  static const int integrationLayerPort = 8090;

  static const int coreSystemPort = 8080;

  static const String integrationLayerContextPath = '/integration';

  static String get integrationLayerBaseUrl {
    final baseUrl = const String.fromEnvironment(
      'INTEGRATION_LAYER_URL',
      defaultValue: 'http://localhost:8090',
    );
    if (!baseUrl.endsWith(integrationLayerContextPath)) {
      return '$baseUrl$integrationLayerContextPath';
    }
    return baseUrl;
  }

  static String fromCoreSystemUrl(String coreSystemUrl) {
    final baseUrl = coreSystemUrl.replaceAll(':$coreSystemPort', ':$integrationLayerPort');
    final uri = Uri.parse(baseUrl);
    return '${uri.scheme}://${uri.host}:${uri.port}$integrationLayerContextPath';
  }

  static String fromCoreUrl(String coreSystemUrl) => fromCoreSystemUrl(coreSystemUrl);

  static String getIntegrationLayerUrl(String? coreSystemUrl) {
    if (coreSystemUrl != null && coreSystemUrl.isNotEmpty) {
      return fromCoreSystemUrl(coreSystemUrl);
    }
    return integrationLayerBaseUrl;
  }
}
