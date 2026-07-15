import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:traqtrace_app/core/storage/hive_storage.dart';
import 'package:traqtrace_app/features/user/cubit/profile_cubit.dart';
import 'package:traqtrace_app/features/user/cubit/profile_state.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/data/services/profile_service.dart';
import 'dart:async';

const String DARK_MODE_KEY = 'dark_mode_preference';
const String API_ENDPOINT_STATUS_KEY = 'api_endpoint_status';

class ThemeState extends Equatable {
  final bool isDarkMode;

  const ThemeState({required this.isDarkMode});

  ThemeMode get themeMode => isDarkMode ? ThemeMode.dark : ThemeMode.light;

  ThemeState copyWith({bool? isDarkMode}) {
    return ThemeState(isDarkMode: isDarkMode ?? this.isDarkMode);
  }

  @override
  List<Object?> get props => [isDarkMode];
}

class ThemeCubit extends Cubit<ThemeState> {
  final ProfileCubit _profileCubit;
  StreamSubscription? _profileSubscription;

  ThemeCubit({required ProfileCubit profileCubit})
    : _profileCubit = profileCubit,
      super(const ThemeState(isDarkMode: false)) {
    _initThemePreference();
    _profileSubscription = _profileCubit.stream.listen((profileState) {
      if (profileState.status != ProfileStatus.preferencesUpdated) return;

      final newDarkMode = profileState.preferences.darkMode;
      if (newDarkMode == state.isDarkMode) return;

      emit(state.copyWith(isDarkMode: newDarkMode));
      Future(() async => _saveLocalThemePreference(newDarkMode));
    });
  }

  Future<void> _initThemePreference() async {
    final isDarkMode = await _getLocalThemePreference();

    if (isDarkMode != state.isDarkMode) {
      emit(state.copyWith(isDarkMode: isDarkMode));
    }
  }

  Future<bool> _getLocalThemePreference() async {
    try {
      return await HiveStorage.getBool(DARK_MODE_KEY) ?? false;
    } catch (e) {
      print('Error reading theme preference from local storage: $e');
      return false;
    }
  }

  Future<void> _saveLocalThemePreference(bool isDark) async {
    try {
      await HiveStorage.putBool(DARK_MODE_KEY, isDark);
    } catch (e) {
      print('Error saving theme preference to local storage: $e');
    }
  }

  bool get isDarkMode => state.isDarkMode;

  ThemeMode get themeMode => state.themeMode;

  Future<void> toggleTheme() async {
    final newDarkMode = !state.isDarkMode;

    await _saveLocalThemePreference(newDarkMode);

    emit(state.copyWith(isDarkMode: newDarkMode));

    Future(() async {
      final success = await _syncThemeWithServer();
      if (!success) {
        print('Theme saved locally but server sync failed or was skipped');
      }
    });
  }

  Future<void> setDarkMode(bool isDark) async {
    if (state.isDarkMode != isDark) {
      await _saveLocalThemePreference(isDark);

      emit(state.copyWith(isDarkMode: isDark));

      Future(() async {
        final success = await _syncThemeWithServer();
        if (!success) {
          print('Theme saved locally but server sync failed or was skipped');
        }
      });
    }
  }

  Future<bool> _isApiEndpointAvailable() async {
    try {
      await HiveStorage.putBool(API_ENDPOINT_STATUS_KEY, true);

      return true;
    } catch (e) {
      print('Error checking API endpoint: $e');
      return true;
    }
  }

  Future<bool> _syncThemeWithServer() async {
    try {
      if (!(await _isApiEndpointAvailable())) {
        print('API endpoint is unavailable, skipping theme sync');
        return false;
      }

      final profileService = getIt<ProfileService>();
      await profileService.updateAppPreferences(
        darkMode: state.isDarkMode,
        language: _profileCubit.state.preferences.language,
      );

      print(
        'Sent theme preference update to server: darkMode=${state.isDarkMode}',
      );

      return true;
    } catch (e) {
      print('Error syncing theme with server: $e');
      return false;
    }
  }

  Future<void> refreshFromProfile() async {
    final localPreference = await _getLocalThemePreference();

    bool shouldUpdate = false;

    try {
      final profileState = _profileCubit.state;

      if (profileState.preferences.darkMode != localPreference) {
        print(
          'Theme mismatch: Server(${profileState.preferences.darkMode}) vs Local($localPreference)',
        );
        print('Using local preference as source of truth');
      }

      if (state.isDarkMode != localPreference) {
        shouldUpdate = true;
      }
    } catch (e) {
      print('ProfileCubit error during theme refresh: $e');

      if (state.isDarkMode != localPreference) {
        shouldUpdate = true;
      }
    }

    if (shouldUpdate) {
      emit(state.copyWith(isDarkMode: localPreference));
    }
  }

  bool getCurrentThemePreference() {
    return state.isDarkMode;
  }

  static Future<bool> loadThemePreference() async {
    return await HiveStorage.getBool(DARK_MODE_KEY) ?? false;
  }

  static Future<void> saveThemePreference(bool isDarkMode) async {
    await HiveStorage.putBool(DARK_MODE_KEY, isDarkMode);
  }

  static Future<bool> checkApiAvailability() async {
    try {
      final dioService = getIt<DioService>();
      final response = await dioService.get(
        '/health',
        acceptAllStatusCodes: true,
      );
      final code = response.statusCode;
      if (code != null && code >= 200 && code < 300) {
        return true;
      }
      print('API returned status code: $code');
      return false;
    } catch (e) {
      print('Error checking API availability: $e');
      return false;
    }
  }

  @override
  Future<void> close() async {
    await _profileSubscription?.cancel();
    return super.close();
  }
}
