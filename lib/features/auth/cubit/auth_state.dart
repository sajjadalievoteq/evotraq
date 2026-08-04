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

  /// True after the first startup [AuthCubit.checkAuth] / [AuthCubit.sessionExpired]
  /// settles. Stays true for the rest of the app session so login/register loading
  /// never re-shows the startup splash.
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

  /// Canonical uppercase role name, or `null` when unauthenticated / unset.
  String? get role {
    final value = user?.role.trim();
    if (value == null || value.isEmpty) return null;
    return value.toUpperCase();
  }

  /// Canonical admin check — use this instead of ad-hoc `role == 'ADMIN'`.
  bool get isAdmin => isAuthenticated && role == 'ADMIN';

  bool get isManufacturer => isAuthenticated && role == 'MANUFACTURER';

  bool get isDistributor => isAuthenticated && role == 'DISTRIBUTOR';

  bool get isRetailer => isAuthenticated && role == 'RETAILER';

  bool hasRole(String roleName) =>
      isAuthenticated && role == roleName.trim().toUpperCase();

  bool hasAnyRole(Iterable<String> roles) => roles.any(hasRole);

  /// Whether this user may perform an EPCIS / operations [step].
  ///
  /// Mirrors backend `OperationSecurityExpressions`. ADMIN is always allowed.
  /// Unknown steps return false.
  bool canPerform(String step) {
    if (!isAuthenticated) return false;
    if (isAdmin) return true;
    final allowed = OperationPermissions.rolesFor(step);
    if (allowed == null) return false;
    return hasAnyRole(allowed);
  }

  /// Mirrors `DashboardSecurityExpressions.READ_ANY` on the backend, which
  /// guards `/dashboard/summary` (home stats, throughput, recent events).
  bool get canReadDashboard => hasAnyRole(
    const ['ADMIN', 'MANUFACTURER', 'DISTRIBUTOR', 'RETAILER'],
  );

  /// Mirrors backend aggregate / manufacturer-distributor throughput access.
  /// Retailers are excluded.
  bool get canReadThroughput => hasAnyRole(
    const ['ADMIN', 'MANUFACTURER', 'DISTRIBUTOR'],
  );

  /// `/internal/actuator/**` is admin-only in `SecurityConfig`.
  bool get canReadSystemHealth => isAdmin;

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
