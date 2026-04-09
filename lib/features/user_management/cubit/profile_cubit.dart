import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_state.dart';
import '../services/user_service.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final UserService _userService;

  ProfileCubit({required UserService userService})
      : _userService = userService,
        super(const ProfileState());

  Future<void> loadProfile() async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final user = await _userService.getCurrentUser();
      emit(state.copyWith(
        status: ProfileStatus.success,
        user: user,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final updatedUser = await _userService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        email: email,
      );
      emit(state.copyWith(
        status: ProfileStatus.success,
        user: updatedUser,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      await _userService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      emit(state.copyWith(status: ProfileStatus.passwordChanged));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> updateNotificationPreferences({
    required bool emailNotifications,
    required bool appNotifications,
  }) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      await _userService.updateNotificationPreferences(
        emailNotifications: emailNotifications,
        appNotifications: appNotifications,
      );
      emit(state.copyWith(
        status: ProfileStatus.preferencesUpdated,
        emailNotifications: emailNotifications,
        appNotifications: appNotifications,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> updateAppPreferences({
    required bool darkMode,
    required String language,
  }) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      await _userService.updateAppPreferences(
        darkMode: darkMode,
        language: language,
      );
      emit(state.copyWith(
        status: ProfileStatus.preferencesUpdated,
        darkMode: darkMode,
        language: language,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        error: e.toString(),
      ));
    }
  }
}
