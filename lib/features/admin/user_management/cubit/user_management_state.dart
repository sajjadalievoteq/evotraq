import 'package:equatable/equatable.dart';
import 'package:traqtrace_app/data/models/user_management/user_management_models.dart';

enum UserManagementStatus { initial, loading, success, error }

class UserManagementState extends Equatable {
  const UserManagementState({
    this.status = UserManagementStatus.initial,
    this.users = const [],
    this.pendingApprovals = const [],
    this.togglingUserId,
    this.currentPage = 0,
    this.totalItems = 0,
    this.totalPages = 0,
    this.error,
  });

  final UserManagementStatus status;
  final List<UserResponse> users;
  final List<UserResponse> pendingApprovals;
  final int? togglingUserId;
  final int currentPage;
  final int totalItems;
  final int totalPages;
  final String? error;

  UserManagementState copyWith({
    UserManagementStatus? status,
    List<UserResponse>? users,
    List<UserResponse>? pendingApprovals,
    int? togglingUserId,
    bool clearTogglingUserId = false,
    int? currentPage,
    int? totalItems,
    int? totalPages,
    String? error,
    bool clearError = false,
  }) {
    return UserManagementState(
      status: status ?? this.status,
      users: users ?? this.users,
      pendingApprovals: pendingApprovals ?? this.pendingApprovals,
      togglingUserId: clearTogglingUserId
          ? null
          : togglingUserId ?? this.togglingUserId,
      currentPage: currentPage ?? this.currentPage,
      totalItems: totalItems ?? this.totalItems,
      totalPages: totalPages ?? this.totalPages,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        status,
        users,
        pendingApprovals,
        togglingUserId,
        currentPage,
        totalItems,
        totalPages,
        error,
      ];
}
