import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/services/admin_service.dart';
import 'admin_state.dart';
import '../models/admin_models.dart';

class AdminCubit extends Cubit<AdminState> {
  final AdminService _adminService;

  AdminCubit({required AdminService adminService})
      : _adminService = adminService,
        super(const AdminState());

  Future<void> loadUsers({
    String? search,
    String? role,
    String? status,
    int page = 0,
    int size = 10,
    String sort = 'id',
    String direction = 'asc',
  }) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      final response = await _adminService.getUsers(
        search: search,
        role: role,
        status: status,
        page: page,
        size: size,
        sort: sort,
        direction: direction,
      );

      emit(state.copyWith(
        status: AdminStatus.success,
        users: response.users,
        currentPage: response.currentPage,
        totalItems: response.totalItems,
        totalPages: response.totalPages,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AdminStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> loadApprovals() async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      final pendingUsers = await _adminService.getPendingApprovals();
      emit(state.copyWith(
        status: AdminStatus.success,
        pendingApprovals: pendingUsers,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AdminStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> approveUser(int userId) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      await _adminService.approveUser(userId);
      await loadApprovals();
    } catch (e) {
      emit(state.copyWith(
        status: AdminStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> rejectUser(int userId) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      await _adminService.rejectUser(userId);
      await loadApprovals();
    } catch (e) {
      emit(state.copyWith(
        status: AdminStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> changeUserStatus(int userId, bool enabled) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      await _adminService.changeUserStatus(userId, enabled);
      await loadUsers(page: state.currentPage);
    } catch (e) {
      emit(state.copyWith(
        status: AdminStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> changeUserRole(int userId, String role) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      await _adminService.changeUserRole(userId, role);
      await loadUsers(page: state.currentPage);
    } catch (e) {
      emit(state.copyWith(
        status: AdminStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> updateUser(int userId, UpdateUserRequest updateRequest) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      await _adminService.updateUser(userId, updateRequest);
      await loadUsers(page: state.currentPage);
    } catch (e) {
      emit(state.copyWith(
        status: AdminStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> createUser(CreateUserRequest createRequest) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      await _adminService.createUser(createRequest);
      await loadUsers(page: state.currentPage);
    } catch (e) {
      emit(state.copyWith(
        status: AdminStatus.error,
        error: e.toString(),
      ));
    }
  }
}
