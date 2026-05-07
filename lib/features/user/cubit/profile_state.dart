import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:traqtrace_app/data/models/auth/auth_models.dart';
import 'package:traqtrace_app/data/models/profile/profile_models.dart';

enum ProfileStatus {
  initial,
  loading,
  success,
  profilePictureUpdated,
  profilePictureRemoved,
  error,
  passwordChanged,
  preferencesUpdated,
}

class ProfileState extends Equatable {
  final ProfileStatus status;
  final User? user;
  final String? error;
  final ProfilePreferences preferences;
  final bool isSavingProfile;
  final bool isChangingPassword;
  final bool isSavingNotificationPreferences;
  final bool isSavingAppPreferences;
  final Uint8List? profilePictureBytes;
  final bool isLoadingProfilePicture;
  final bool isUploadingProfilePicture;
  final bool isRemovingProfilePicture;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.user,
    this.error,
    this.preferences = const ProfilePreferences(),
    this.isSavingProfile = false,
    this.isChangingPassword = false,
    this.isSavingNotificationPreferences = false,
    this.isSavingAppPreferences = false,
    this.profilePictureBytes,
    this.isLoadingProfilePicture = false,
    this.isUploadingProfilePicture = false,
    this.isRemovingProfilePicture = false,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    User? user,
    String? error,
    ProfilePreferences? preferences,
    bool? isSavingProfile,
    bool? isChangingPassword,
    bool? isSavingNotificationPreferences,
    bool? isSavingAppPreferences,
    Uint8List? profilePictureBytes,
    bool? clearProfilePictureBytes,
    bool? isLoadingProfilePicture,
    bool? isUploadingProfilePicture,
    bool? isRemovingProfilePicture,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
      preferences: preferences ?? this.preferences,
      isSavingProfile: isSavingProfile ?? this.isSavingProfile,
      isChangingPassword: isChangingPassword ?? this.isChangingPassword,
      isSavingNotificationPreferences:
          isSavingNotificationPreferences ?? this.isSavingNotificationPreferences,
      isSavingAppPreferences:
          isSavingAppPreferences ?? this.isSavingAppPreferences,
      profilePictureBytes: (clearProfilePictureBytes ?? false)
          ? null
          : (profilePictureBytes ?? this.profilePictureBytes),
      isLoadingProfilePicture:
          isLoadingProfilePicture ?? this.isLoadingProfilePicture,
      isUploadingProfilePicture:
          isUploadingProfilePicture ?? this.isUploadingProfilePicture,
      isRemovingProfilePicture:
          isRemovingProfilePicture ?? this.isRemovingProfilePicture,
    );
  }

  @override
  List<Object?> get props => [
        status,
        user,
        error,
        preferences,
        isSavingProfile,
        isChangingPassword,
        isSavingNotificationPreferences,
        isSavingAppPreferences,
        profilePictureBytes,
        isLoadingProfilePicture,
        isUploadingProfilePicture,
        isRemovingProfilePicture,
      ];
}

