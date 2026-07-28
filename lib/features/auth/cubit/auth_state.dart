import 'package:equatable/equatable.dart';
import 'package:traqtrace_app/data/models/auth/auth_models.dart';

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
