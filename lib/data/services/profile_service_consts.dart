class ProfileServiceConsts {
  static const contentTypeHeaderKey = 'Content-Type';
  static const contentTypeHeaderValueJson = 'application/json';
  static const authHeaderKey = 'Authorization';
  static const authHeaderValuePrefix = 'Bearer ';

  static const userProfilePath = '/users/profile';
  static const profilePicturePath = '/users/profile/picture';
  static const changePasswordPath = '/users/password';
  static const notificationPreferencesPath = '/users/preferences/notifications';
  static const appPreferencesPath = '/users/preferences/app';

  static const firstNameKey = 'firstName';
  static const lastNameKey = 'lastName';
  static const emailKey = 'email';
  static const currentPasswordKey = 'currentPassword';
  static const newPasswordKey = 'newPassword';
  static const emailNotificationsKey = 'emailNotifications';
  static const appNotificationsKey = 'appNotifications';
  static const darkModeKey = 'darkMode';
  static const languageKey = 'language';

  static const noAuthTokenFound = 'No authentication token found';
  static const unexpectedResponseFormat = 'Unexpected response format';
  static const failedToFetchUserProfile = 'Failed to fetch user profile';
  static const failedToUpdateProfile = 'Failed to update profile';
  static const failedToChangePassword = 'Failed to change password';
  static const failedToUpdateNotificationPreferences =
      'Failed to update notification preferences';
  static const failedToUpdateAppPreferences = 'Failed to update app preferences';

  const ProfileServiceConsts._();
}
