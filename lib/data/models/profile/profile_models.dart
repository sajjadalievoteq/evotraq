import 'package:equatable/equatable.dart';

class ProfilePreferences extends Equatable {
  final bool emailNotifications;
  final bool appNotifications;
  final bool darkMode;
  final String language;

  const ProfilePreferences({
    this.emailNotifications = true,
    this.appNotifications = true,
    this.darkMode = false,
    this.language = 'English',
  });

  ProfilePreferences copyWith({
    bool? emailNotifications,
    bool? appNotifications,
    bool? darkMode,
    String? language,
  }) {
    return ProfilePreferences(
      emailNotifications: emailNotifications ?? this.emailNotifications,
      appNotifications: appNotifications ?? this.appNotifications,
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
    );
  }

  @override
  List<Object?> get props => [
        emailNotifications,
        appNotifications,
        darkMode,
        language,
      ];
}
