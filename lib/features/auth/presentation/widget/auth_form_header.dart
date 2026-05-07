/// Copy shown above auth forms (web right pane + mobile stack).
class AuthFormHeader {
  const AuthFormHeader({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  final String eyebrow;
  final String title;
  final String subtitle;

  static const String _systemAccess = 'SYSTEM ACCESS';

  static const signIn = AuthFormHeader(
    eyebrow: _systemAccess,
    title: 'Sign in',
    subtitle: 'Welcome back. Continue to your operations console',
  );

  static const register = AuthFormHeader(
    eyebrow: _systemAccess,
    title: 'Create account',
    subtitle: 'Enter your details to register for TraqTrace access.',
  );

  static const forgotPassword = AuthFormHeader(
    eyebrow: _systemAccess,
    title: 'Forgot password',
    subtitle: 'We will email you a link to reset your password.',
  );

  static const resetPassword = AuthFormHeader(
    eyebrow: _systemAccess,
    title: 'Set new password',
    subtitle: 'Choose a strong password for your account.',
  );

  static const checkEmail = AuthFormHeader(
    eyebrow: _systemAccess,
    title: 'Check your email',
    subtitle: 'Look for a message from us to continue.',
  );

  static const verifyEmail = AuthFormHeader(
    eyebrow: _systemAccess,
    title: 'Email verification',
    subtitle: 'Confirming your email address.',
  );

  static const passwordResetComplete = AuthFormHeader(
    eyebrow: _systemAccess,
    title: 'Password updated',
    subtitle: 'You can sign in with your new password.',
  );

  static const invalidResetLink = AuthFormHeader(
    eyebrow: _systemAccess,
    title: 'Invalid link',
    subtitle: 'This reset link expired or was already used. Request a new one.',
  );
}
