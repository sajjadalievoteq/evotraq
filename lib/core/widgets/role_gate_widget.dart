import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';

class RoleGate extends StatelessWidget {
  const RoleGate({
    super.key,
    this.step,
    this.allowedRoles,
    required this.child,
    this.fallback = const SizedBox.shrink(),
  }) : assert(
         step != null || allowedRoles != null,
         'Provide step and/or allowedRoles',
       );
  final String? step;
  final Iterable<String>? allowedRoles;
  final Widget child;
  final Widget fallback;

  static bool _allows(AuthState auth, {String? step, Iterable<String>? roles}) {
    if (!auth.isAuthenticated) return false;
    if (step != null && auth.canPerform(step)) return true;
    if (roles != null && auth.hasAnyRole(roles)) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final allowed = context.select<AuthCubit, bool>(
      (cubit) => _allows(cubit.state, step: step, roles: allowedRoles),
    );
    return allowed ? child : fallback;
  }
}
