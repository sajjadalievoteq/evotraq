import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:traqtrace_app/data/models/auth/user.dart';
import 'package:traqtrace_app/data/models/auth/user_session.dart';
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

enum SessionsStatus { initial, loading, success, error }

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
  final SessionsStatus sessionsStatus;
  final List<UserSession> sessions;
  final String? sessionsError;
  final bool isRevokingSession;
  final bool isRevokingOtherSessions;

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
    this.sessionsStatus = SessionsStatus.initial,
    this.sessions = const [],
    this.sessionsError,
    this.isRevokingSession = false,
    this.isRevokingOtherSessions = false,
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
    SessionsStatus? sessionsStatus,
    List<UserSession>? sessions,
    String? sessionsError,
    bool clearSessionsError = false,
    bool? isRevokingSession,
    bool? isRevokingOtherSessions,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
      preferences: preferences ?? this.preferences,
      isSavingProfile: isSavingProfile ?? this.isSavingProfile,
      isChangingPassword: isChangingPassword ?? this.isChangingPassword,
      isSavingNotificationPreferences:
          isSavingNotificationPreferences ??
          this.isSavingNotificationPreferences,
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
      sessionsStatus: sessionsStatus ?? this.sessionsStatus,
      sessions: sessions ?? this.sessions,
      sessionsError: clearSessionsError
          ? null
          : (sessionsError ?? this.sessionsError),
      isRevokingSession: isRevokingSession ?? this.isRevokingSession,
      isRevokingOtherSessions:
          isRevokingOtherSessions ?? this.isRevokingOtherSessions,
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
    sessionsStatus,
    sessions,
    sessionsError,
    isRevokingSession,
    isRevokingOtherSessions,
  ];
}
