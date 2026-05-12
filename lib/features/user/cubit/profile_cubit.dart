import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/data/services/profile_service.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileService _profileService;

  ProfileCubit({required ProfileService profileService})
    : _profileService = profileService,
      super(const ProfileState());

  Future<void> loadProfile() async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final user = await _profileService.getCurrentUser();
      emit(state.copyWith(status: ProfileStatus.success, user: user));

      await loadProfilePicture();
    } catch (e) {
      emit(state.copyWith(status: ProfileStatus.error, error: e.toString()));
    }
  }

  Future<void> loadProfilePicture() async {
    emit(state.copyWith(isLoadingProfilePicture: true));
    try {
      final bytes = await _profileService.getProfilePictureBytes();
      emit(
        state.copyWith(
          isLoadingProfilePicture: false,
          profilePictureBytes: bytes,
          clearProfilePictureBytes: bytes == null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoadingProfilePicture: false));
    }
  }

  Future<void> uploadProfilePicture({
    required List<int> bytes,
    required String filename,
    required String contentType,
  }) async {
    emit(
      state.copyWith(
        status: ProfileStatus.loading,
        error: null,
        isUploadingProfilePicture: true,
        isRemovingProfilePicture: false,
      ),
    );
    try {
      final updatedUser = await _profileService.uploadProfilePicture(
        bytes: Uint8List.fromList(bytes),
        filename: filename,
        contentType: contentType,
      );
      emit(
        state.copyWith(
          status: ProfileStatus.profilePictureUpdated,
          user: updatedUser,
          isUploadingProfilePicture: false,
        ),
      );
      await loadProfilePicture();
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.error,
          error: e.toString(),
          isUploadingProfilePicture: false,
        ),
      );
    }
  }

  Future<void> deleteProfilePicture() async {
    emit(
      state.copyWith(
        status: ProfileStatus.loading,
        error: null,
        isRemovingProfilePicture: true,
        isUploadingProfilePicture: false,
      ),
    );
    try {
      final updatedUser = await _profileService.deleteProfilePicture();
      emit(
        state.copyWith(
          status: ProfileStatus.profilePictureRemoved,
          user: updatedUser,
          isRemovingProfilePicture: false,
          clearProfilePictureBytes: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.error,
          error: e.toString(),
          isRemovingProfilePicture: false,
        ),
      );
    }
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
  }) async {
    emit(
      state.copyWith(
        status: ProfileStatus.loading,
        error: null,
        isSavingProfile: true,
      ),
    );
    try {
      final updatedUser = await _profileService.updateProfile(
        firstName: firstName,
        lastName: lastName,
      );
      emit(
        state.copyWith(
          status: ProfileStatus.success,
          user: updatedUser,
          isSavingProfile: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.error,
          error: e.toString(),
          isSavingProfile: false,
        ),
      );
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    emit(
      state.copyWith(
        status: ProfileStatus.loading,
        error: null,
        isChangingPassword: true,
      ),
    );
    try {
      await _profileService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      emit(
        state.copyWith(
          status: ProfileStatus.passwordChanged,
          isChangingPassword: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.error,
          error: e.toString(),
          isChangingPassword: false,
        ),
      );
    }
  }

  Future<void> updateNotificationPreferences({
    required bool emailNotifications,
    required bool appNotifications,
  }) async {
    emit(
      state.copyWith(
        status: ProfileStatus.loading,
        error: null,
        isSavingNotificationPreferences: true,
      ),
    );
    try {
      await _profileService.updateNotificationPreferences(
        emailNotifications: emailNotifications,
        appNotifications: appNotifications,
      );
      emit(
        state.copyWith(
          status: ProfileStatus.preferencesUpdated,
          preferences: state.preferences.copyWith(
            emailNotifications: emailNotifications,
            appNotifications: appNotifications,
          ),
          isSavingNotificationPreferences: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.error,
          error: e.toString(),
          isSavingNotificationPreferences: false,
        ),
      );
    }
  }

  Future<void> updateAppPreferences({
    required bool darkMode,
    required String language,
  }) async {
    emit(
      state.copyWith(
        status: ProfileStatus.loading,
        error: null,
        isSavingAppPreferences: true,
      ),
    );
    try {
      await _profileService.updateAppPreferences(
        darkMode: darkMode,
        language: language,
      );
      emit(
        state.copyWith(
          status: ProfileStatus.preferencesUpdated,
          preferences: state.preferences.copyWith(
            darkMode: darkMode,
            language: language,
          ),
          isSavingAppPreferences: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.error,
          error: e.toString(),
          isSavingAppPreferences: false,
        ),
      );
    }
  }
}
