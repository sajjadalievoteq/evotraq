import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/services/user_management/user_management_service.dart';
import 'package:traqtrace_app/features/admin/user_approval/cubit/user_approval_state.dart';

class UserApprovalCubit extends Cubit<UserApprovalState> {
  UserApprovalCubit({UserManagementService? userManagementService})
      : _userManagementService =
            userManagementService ?? getIt<UserManagementService>(),
        super(const UserApprovalState());

  final UserManagementService _userManagementService;

  Future<void> loadApprovals() async {
    emit(state.copyWith(status: UserApprovalStatus.loading));
    try {
      final pendingUsers = await _userManagementService.getPendingApprovals();
      emit(
        state.copyWith(
          status: UserApprovalStatus.success,
          pendingApprovals: pendingUsers,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: UserApprovalStatus.error, error: e.toString()));
    }
  }

  Future<void> approveUser(int userId) async {
    emit(state.copyWith(status: UserApprovalStatus.loading));
    try {
      await _userManagementService.approveUser(userId);
      await loadApprovals();
    } catch (e) {
      emit(state.copyWith(status: UserApprovalStatus.error, error: e.toString()));
    }
  }

  Future<void> rejectUser(int userId) async {
    emit(state.copyWith(status: UserApprovalStatus.loading));
    try {
      await _userManagementService.rejectUser(userId);
      await loadApprovals();
    } catch (e) {
      emit(state.copyWith(status: UserApprovalStatus.error, error: e.toString()));
    }
  }
}
