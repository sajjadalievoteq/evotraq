import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';

class RouteAccess {
  const RouteAccess(this.authCubit);

  final AuthCubit authCubit;

  AuthState get authState => authCubit.state;

  String? requireOperationStep(String step) {
    final auth = authState;
    if (!auth.isAuthenticated) return null;
    if (!auth.canPerform(step)) return Constants.homeRoute;
    return null;
  }
}
