import 'package:traqtrace_app/features/auth/models/auth_models.dart';

/// Service for managing user-related operations
abstract class UserService {
  /// Get the current authenticated user's profile
  Future<User> getCurrentUser();
  
  /// Update the user profile information
  Future<User> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
  });
  
  /// Change the user's password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  });
  
  /// Update user notification preferences
  Future<bool> updateNotificationPreferences({
    required bool emailNotifications,
    required bool appNotifications,
  });
  
  /// Update user application preferences
  Future<bool> updateAppPreferences({
    required bool darkMode,
    required String language,
  });
}