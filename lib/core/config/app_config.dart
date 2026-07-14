class AppConfig {
  final String apiBaseUrl;

  final String appName;

  final String appVersion;
  
  String get appTitle => appName;
  
  String get loginEndpoint => '$apiBaseUrl/auth/login';
  
  String get registerEndpoint => '$apiBaseUrl/auth/register';
  
  String get passwordResetRequestEndpoint => '$apiBaseUrl/auth/password-reset-request';
  
  String get validateResetTokenEndpoint => '$apiBaseUrl/auth/validate-reset-token';
  
  String get resetPasswordEndpoint => '$apiBaseUrl/auth/reset-password';
  
  String get userProfileEndpoint => '$apiBaseUrl/users/profile';
  
  String get changePasswordEndpoint => '$apiBaseUrl/users/password';
  String get notificationPreferencesEndpoint => '$apiBaseUrl/users/notifications';
  
  String get appPreferencesEndpoint => '$apiBaseUrl/users/preferences/app';
  
  static const String userDataKey = 'user_data';
  
  static const String authTokenKey = 'auth_token';
  
  /// Fail-fast network timeouts so hung calls surface as errors (login/splash/401).
  static const int connectTimeout = 15000;
  static const int sendTimeout = 15000;
  static const int receiveTimeout = 15000;
  
  AppConfig({
    required this.apiBaseUrl,
    required this.appName,
    required this.appVersion,
  });
}