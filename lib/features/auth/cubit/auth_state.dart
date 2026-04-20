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
  error,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? token;
  final String? error;
  final String? message;
  final String? registeredEmail;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.token,
    this.error,
    this.message,
    this.registeredEmail,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? token,
    String? error,
    String? message,
    String? registeredEmail,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      token: token ?? this.token,
      error: error,
      message: message,
      registeredEmail: registeredEmail,
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
  ];
}
