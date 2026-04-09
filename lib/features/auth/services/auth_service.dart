import 'package:traqtrace_app/features/auth/models/auth_models.dart';

abstract class AuthService {
  Future<AuthResponse> login(LoginRequest request);
  Future<void> register(RegisterRequest request);
  Future<User> getCurrentUser();
  Future<void> logout();
  
  // Password reset methods
  Future<bool> requestPasswordReset(String email);
  Future<bool> validatePasswordResetToken(String token);
  Future<bool> resetPassword(String token, String newPassword, String confirmPassword);
  
  // Email verification method
  Future<bool> verifyEmail(String token);
}