/// Configuration class for application-wide settings
class AppConfig {
  /// Base URL for API endpoints
  final String apiBaseUrl;
  
  /// Application name
  final String appName;
    /// Application version
  final String appVersion;
  
  /// Application title for UI display
  String get appTitle => appName;
  
  /// API endpoint for login
  String get loginEndpoint => '$apiBaseUrl/auth/login';
  
  /// API endpoint for registration
  String get registerEndpoint => '$apiBaseUrl/auth/register';
  
  /// API endpoint for password reset request
  String get passwordResetRequestEndpoint => '$apiBaseUrl/auth/password-reset-request';
  
  /// API endpoint for password reset validation
  String get validateResetTokenEndpoint => '$apiBaseUrl/auth/validate-reset-token';
  
  /// API endpoint for password reset completion
  String get resetPasswordEndpoint => '$apiBaseUrl/auth/reset-password';
  
  /// API endpoint for user profile
  String get userProfileEndpoint => '$apiBaseUrl/users/profile';
  
  /// API endpoint for password change
  String get changePasswordEndpoint => '$apiBaseUrl/users/password';
    /// API endpoint for notification preferences
  String get notificationPreferencesEndpoint => '$apiBaseUrl/users/notifications';
  
  /// API endpoint for app preferences (theme, language)
  String get appPreferencesEndpoint => '$apiBaseUrl/users/preferences/app';
  
  /// Key for storing user data in local storage
  static const String userDataKey = 'user_data';
  
  /// Key for storing auth token
  static const String authTokenKey = 'auth_token';
  
  /// HTTP connection timeout in milliseconds
  static const int connectTimeout = 30000;
  
  /// HTTP receive timeout in milliseconds
  static const int receiveTimeout = 30000;
  
  /// Constructor
  AppConfig({
    required this.apiBaseUrl,
    required this.appName,
    required this.appVersion,
  });
}