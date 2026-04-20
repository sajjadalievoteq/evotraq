import 'package:equatable/equatable.dart';
import 'package:traqtrace_app/data/models/auth/auth_models.dart';

enum ProfileStatus {
  initial,
  loading,
  success,
  error,
  passwordChanged,
  preferencesUpdated
}

class ProfileState extends Equatable {
  final ProfileStatus status;
  final User? user;
  final String? error;
  final bool emailNotifications;
  final bool appNotifications;
  final bool darkMode;
  final String language;
  
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.user,
    this.error,
    this.emailNotifications = true,
    this.appNotifications = true,
    this.darkMode = false,
    this.language = 'English',
  });
  
  ProfileState copyWith({
    ProfileStatus? status,
    User? user,
    String? error,
    bool? emailNotifications,
    bool? appNotifications,
    bool? darkMode,
    String? language,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      appNotifications: appNotifications ?? this.appNotifications,
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
    );
  }
  
  @override
  List<Object?> get props => [
    status, 
    user, 
    error, 
    emailNotifications, 
    appNotifications, 
    darkMode, 
    language
  ];
}