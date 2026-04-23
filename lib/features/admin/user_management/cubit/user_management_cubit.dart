import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/models/user_management/user_management_models.dart';
import 'package:traqtrace_app/data/services/user_management/user_management_service.dart';

import 'user_management_state.dart';

class UserManagementCubit extends Cubit<UserManagementState> {
  UserManagementCubit({UserManagementService? userManagementService})
      : _userManagementService =
            userManagementService ?? getIt<UserManagementService>(),
        super(const UserManagementState());

  final UserManagementService _userManagementService;

  Future<void> loadUsers({
    String? search,
    String? role,
    String? status,
    int page = 0,
    int size = 10,
    String sort = 'id',
    String direction = 'asc',
  }) async {
    emit(state.copyWith(status: UserManagementStatus.loading));
    try {
      final response = await _userManagementService.getUsers(
        search: search,
        role: role,
        status: status,
        page: page,
        size: size,
        sort: sort,
        direction: direction,
      );

      emit(
        state.copyWith(
          status: UserManagementStatus.success,
          users: response.users,
          currentPage: response.currentPage,
          totalItems: response.totalItems,
          totalPages: response.totalPages,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: UserManagementStatus.error,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> changeUserStatus(int userId, bool enabled) async {
    emit(
      state.copyWith(
        togglingUserId: userId,
        clearError: true,
      ),
    );
    try {
      final updatedUser = await _userManagementService.changeUserStatus(
        userId,
        enabled,
      );
      final updatedUsers = state.users
          .map((user) => user.id == userId ? updatedUser : user)
          .toList();

      emit(
        state.copyWith(
          status: UserManagementStatus.success,
          users: updatedUsers,
          clearTogglingUserId: true,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: UserManagementStatus.error,
          clearTogglingUserId: true,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> loadApprovals() async {
    emit(state.copyWith(status: UserManagementStatus.loading));
    try {
      final pendingUsers = await _userManagementService.getPendingApprovals();
      emit(
        state.copyWith(
          status: UserManagementStatus.success,
          pendingApprovals: pendingUsers,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: UserManagementStatus.error,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> approveUser(int userId) async {
    emit(state.copyWith(status: UserManagementStatus.loading));
    try {
      await _userManagementService.approveUser(userId);
      await loadApprovals();
    } catch (e) {
      emit(
        state.copyWith(
          status: UserManagementStatus.error,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> rejectUser(int userId) async {
    emit(state.copyWith(status: UserManagementStatus.loading));
    try {
      await _userManagementService.rejectUser(userId);
      await loadApprovals();
    } catch (e) {
      emit(
        state.copyWith(
          status: UserManagementStatus.error,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> changeUserRole(int userId, String role) async {
    emit(state.copyWith(status: UserManagementStatus.loading));
    try {
      await _userManagementService.changeUserRole(userId, role);
      await loadUsers(page: state.currentPage);
    } catch (e) {
      emit(
        state.copyWith(
          status: UserManagementStatus.error,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> updateUser(int userId, UpdateUserRequest updateRequest) async {
    emit(state.copyWith(status: UserManagementStatus.loading));
    try {
      await _userManagementService.updateUser(userId, updateRequest);
      await loadUsers(page: state.currentPage);
    } catch (e) {
      emit(
        state.copyWith(
          status: UserManagementStatus.error,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> createUser(CreateUserRequest createRequest) async {
    emit(state.copyWith(status: UserManagementStatus.loading));
    try {
      await _userManagementService.createUser(createRequest);
      await loadUsers(page: state.currentPage);
    } catch (e) {
      emit(
        state.copyWith(
          status: UserManagementStatus.error,
          error: e.toString(),
        ),
      );
    }
  }
}
