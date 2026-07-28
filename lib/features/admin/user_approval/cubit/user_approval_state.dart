import 'package:equatable/equatable.dart';
import 'package:traqtrace_app/data/models/user_management/user_management_models.dart';

enum UserApprovalStatus { initial, loading, success, error }

class UserApprovalState extends Equatable {
  const UserApprovalState({
    this.status = UserApprovalStatus.initial,
    this.pendingApprovals = const [],
    this.error,
  });

  final UserApprovalStatus status;
  final List<UserResponse> pendingApprovals;
  final String? error;

  UserApprovalState copyWith({
    UserApprovalStatus? status,
    List<UserResponse>? pendingApprovals,
    String? error,
    bool clearError = false,
  }) {
    return UserApprovalState(
      status: status ?? this.status,
      pendingApprovals: pendingApprovals ?? this.pendingApprovals,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, pendingApprovals, error];
}
