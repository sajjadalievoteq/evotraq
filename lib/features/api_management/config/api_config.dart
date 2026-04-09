/// Configuration for API Management feature
/// Provides base URLs for the Integration Layer
class ApiConfig {
  /// Default port for the Integration Layer
  static const int integrationLayerPort = 8090;

  /// Default port for the Core System
  static const int coreSystemPort = 8080;

  /// Context path for the Integration Layer
  static const String integrationLayerContextPath = '/integration';

  /// Base URL for the Integration Layer
  /// This should be configured from environment or app config
  static String get integrationLayerBaseUrl {
    // Default to localhost for development
    // In production, this would come from environment configuration
    final baseUrl = const String.fromEnvironment(
      'INTEGRATION_LAYER_URL',
      defaultValue: 'http://localhost:8090',
    );
    // Ensure context path is included
    if (!baseUrl.endsWith(integrationLayerContextPath)) {
      return '$baseUrl$integrationLayerContextPath';
    }
    return baseUrl;
  }

  /// Create Integration Layer URL from Core System URL
  /// Replaces the port from 8080 to 8090 and adds context path
  static String fromCoreSystemUrl(String coreSystemUrl) {
    final baseUrl = coreSystemUrl.replaceAll(':$coreSystemPort', ':$integrationLayerPort');
    // Remove any existing context path and add the correct one
    final uri = Uri.parse(baseUrl);
    return '${uri.scheme}://${uri.host}:${uri.port}$integrationLayerContextPath';
  }

  /// Alias for fromCoreSystemUrl for convenience
  static String fromCoreUrl(String coreSystemUrl) => fromCoreSystemUrl(coreSystemUrl);

  /// Get Integration Layer URL dynamically
  static String getIntegrationLayerUrl(String? coreSystemUrl) {
    if (coreSystemUrl != null && coreSystemUrl.isNotEmpty) {
      return fromCoreSystemUrl(coreSystemUrl);
    }
    return integrationLayerBaseUrl;
  }
}
