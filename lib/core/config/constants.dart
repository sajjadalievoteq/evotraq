class Constants {
  // app branding
  static const String appName = 'evotraq.io';
  static const String appTagline = 'GS1-compliant track and trace system';

  // page routes
  static const String splashRoute = '/splash';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String forgotPasswordRoute = '/forgot-password';
  static const String authResetPasswordRoute = '/reset-password';
  static const String resetPasswordRoute = '/auth/reset-password';
  static const String verifyEmailRoute = '/auth/verify-email';
  static const String verifyEmailAliasRoute = '/verify-email';
  static const String checkEmailRoute = '/check-email';

  // API endpoints
  static const String authLoginEndpoint = '/auth/login';
  static const String authRegisterEndpoint = '/auth/register';
  static const String authCheckUsernameEndpoint = '/auth/check-username';
  static const String authPasswordResetRequestEndpoint =
      '/auth/password-reset-request';
  static const String authValidateResetTokenEndpoint =
      '/auth/validate-reset-token';
  static const String authResetPasswordEndpoint = '/auth/reset-password';
  static const String verificationVerifyEmailEndpoint =
      '/verification/verify-email';
  static const String usersProfileEndpoint = '/users/profile';

  // assets
  // images
  static const String splashImage = 'assets/images/splash.png';
  static const String logoImage = 'assets/images/logo.jpg';
  static const String loginBackground = 'assets/images/background_image.png';
}
