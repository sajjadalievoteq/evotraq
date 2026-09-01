import 'package:equatable/equatable.dart';
import 'package:traqtrace_app/data/models/auth/user.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_permissions.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  registered,
  passwordResetRequested,
  passwordResetTokenValid,
  passwordResetTokenInvalid,
  passwordReset,
  emailVerified,
  verificationEmailResent,
  error,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? token;
  final String? error;
  final String? message;
  final String? registeredEmail;

  final bool bootstrapCompleted;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.token,
    this.error,
    this.message,
    this.registeredEmail,
    this.bootstrapCompleted = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? token,
    String? error,
    String? message,
    String? registeredEmail,
    bool? bootstrapCompleted,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      token: token ?? this.token,
      error: error,
      message: message,
      registeredEmail: registeredEmail,
      bootstrapCompleted: bootstrapCompleted ?? this.bootstrapCompleted,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;

  String? get role {
    final value = user?.role.trim();
    if (value == null || value.isEmpty) return null;
    return value.toUpperCase();
  }

  bool get isAdmin => isAuthenticated && role == 'ADMIN';

  bool get isManufacturer => isAuthenticated && role == 'MANUFACTURER';

  bool get isDistributor => isAuthenticated && role == 'DISTRIBUTOR';

  bool get isRetailer => isAuthenticated && role == 'RETAILER';

  bool hasRole(String roleName) =>
      isAuthenticated && role == roleName.trim().toUpperCase();

  bool hasAnyRole(Iterable<String> roles) => roles.any(hasRole);

  bool canPerform(String step) {
    if (!isAuthenticated) return false;
    if (isAdmin) return true;
    final allowed = OperationPermissions.rolesFor(step);
    if (allowed == null) return false;
    return hasAnyRole(allowed);
  }

  bool get canReadDashboard =>
      hasAnyRole(const ['ADMIN', 'MANUFACTURER', 'DISTRIBUTOR', 'RETAILER']);

  bool get canReadThroughput =>
      hasAnyRole(const ['ADMIN', 'MANUFACTURER', 'DISTRIBUTOR']);

  bool get canReadSystemHealth => isAdmin;

  bool get canAccessTatmeenIntegration => hasAnyRole(const [
    'ADMIN',
    'MANUFACTURER',
    'DISTRIBUTOR',
    'RETAILER',
    'B2B_SERVICE',
  ]);

  @override
  List<Object?> get props => [
    status,
    user,
    token,
    error,
    message,
    registeredEmail,
    bootstrapCompleted,
  ];
}