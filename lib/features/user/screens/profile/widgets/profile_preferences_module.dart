import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/theme/theme_cubit.dart';
import 'package:traqtrace_app/features/user/cubit/profile_cubit.dart';
import 'package:traqtrace_app/features/user/cubit/profile_state.dart';
import 'package:traqtrace_app/features/user/utils/user_strings.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/widgets/custom_elevated_button.dart';
import 'package:traqtrace_app/features/user/screens/profile/widgets/operational_gln_preference_card.dart';

class ProfilePreferencesModule extends StatefulWidget {
  const ProfilePreferencesModule({super.key});

  @override
  State<ProfilePreferencesModule> createState() =>
      _ProfilePreferencesModuleState();
}

class _ProfilePreferencesModuleState extends State<ProfilePreferencesModule> {
  bool _emailNotifications = true;
  bool _appNotifications = true;
  String _language = UserStrings.languageEnglish;

  final List<String> _availableLanguages = const [
    UserStrings.languageEnglish,
    UserStrings.languageSpanish,
    UserStrings.languageFrench,
    UserStrings.languageGerman,
    UserStrings.languageChinese,
  ];

  @override
  void initState() {
    super.initState();
    final profileState = context.read<ProfileCubit>().state;
    _language = profileState.preferences.language;
    _emailNotifications = profileState.preferences.emailNotifications;
    _appNotifications = profileState.preferences.appNotifications;
  }

  void _saveNotificationPreferences() {
    context.read<ProfileCubit>().updateNotificationPreferences(
      emailNotifications: _emailNotifications,
      appNotifications: _appNotifications,
    );
  }

  void _saveAppPreferences() {
    final themeCubit = context.read<ThemeCubit>();
    context.read<ProfileCubit>().updateAppPreferences(
      darkMode: themeCubit.isDarkMode,
      language: _language,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state.status == ProfileStatus.preferencesUpdated) {
          context.showSuccess(UserStrings.preferencesUpdatedSuccessfully);
          context.read<ThemeCubit>().refreshFromProfile();
        } else if (state.status == ProfileStatus.error) {
          context.showError(
            '${UserStrings.errorPrefix}${state.error ?? UserStrings.genericError}',
          );
        }
      },
      builder: (context, state) {
        final isSavingNotif = state.isSavingNotificationPreferences;
        final isSavingApp = state.isSavingAppPreferences;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              UserStrings.notificationPreferencesTitle,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text(UserStrings.emailNotificationsTitle),
                      subtitle: const Text(
                        UserStrings.emailNotificationsSubtitle,
                      ),
                      value: _emailNotifications,
                      onChanged: isSavingNotif
                          ? null
                          : (value) => setState(() {
                              _emailNotifications = value;
                            }),
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text(UserStrings.appNotificationsTitle),
                      subtitle: const Text(
                        UserStrings.appNotificationsSubtitle,
                      ),
                      value: _appNotifications,
                      onChanged: isSavingNotif
                          ? null
                          : (value) => setState(() {
                              _appNotifications = value;
                            }),
                    ),
                    const SizedBox(height: 16),
                    CustomElevatedButton(
                      label: UserStrings.saveNotificationPreferences,
                      onPressed: _saveNotificationPreferences,
                      isLoading: isSavingNotif,
                      isEnabled: !isSavingNotif,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              UserStrings.applicationPreferencesTitle,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    BlocBuilder<ThemeCubit, ThemeState>(
                      buildWhen: (previous, current) =>
                          previous.isDarkMode != current.isDarkMode,
                      builder: (context, themeState) {
                        return SwitchListTile(
                          title: const Text(UserStrings.darkModeTitle),
                          subtitle: const Text(UserStrings.darkModeSubtitle),
                          value: themeState.isDarkMode,
                          onChanged: isSavingApp
                              ? null
                              : (value) async {
                                  await context.read<ThemeCubit>().setDarkMode(
                                    value,
                                  );
                                },
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(UserStrings.languageTitle),
                      subtitle: Text(
                        '${UserStrings.languageSubtitlePrefix}$_language',
                      ),
                    ),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                        border: OutlineInputBorder(),
                      ),
                      value: _language,
                      items: _availableLanguages
                          .map(
                            (lang) => DropdownMenuItem(
                              value: lang,
                              child: Text(lang),
                            ),
                          )
                          .toList(),
                      onChanged: isSavingApp
                          ? null
                          : (value) {
                              if (value != null) {
                                setState(() => _language = value);
                              }
                            },
                    ),
                    const SizedBox(height: 16),
                    CustomElevatedButton(
                      label: UserStrings.saveAppPreferences,
                      onPressed: _saveAppPreferences,
                      isLoading: isSavingApp,
                      isEnabled: !isSavingApp,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const OperationalGlnPreferenceCard(),
          ],
        );
      },
    );
  }
}
