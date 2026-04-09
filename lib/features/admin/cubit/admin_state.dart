import 'package:equatable/equatable.dart';
import 'package:traqtrace_app/features/admin/models/admin_models.dart';

enum AdminStatus { initial, loading, success, error }

class AdminState extends Equatable {
  final AdminStatus status;
  final List<UserResponse> users;
  final List<UserResponse> pendingApprovals;
  final int currentPage;
  final int totalItems;
  final int totalPages;
  final String? error;

  const AdminState({
    this.status = AdminStatus.initial,
    this.users = const [],
    this.pendingApprovals = const [],
    this.currentPage = 0,
    this.totalItems = 0,
    this.totalPages = 0,
    this.error,
  });

  AdminState copyWith({
    AdminStatus? status,
    List<UserResponse>? users,
    List<UserResponse>? pendingApprovals,
    int? currentPage,
    int? totalItems,
    int? totalPages,
    String? error,
  }) {
    return AdminState(
      status: status ?? this.status,
      users: users ?? this.users,
      pendingApprovals: pendingApprovals ?? this.pendingApprovals,
      currentPage: currentPage ?? this.currentPage,
      totalItems: totalItems ?? this.totalItems,
      totalPages: totalPages ?? this.totalPages,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    status, 
    users, 
    pendingApprovals, 
    currentPage, 
    totalItems, 
    totalPages, 
    error
  ];
}