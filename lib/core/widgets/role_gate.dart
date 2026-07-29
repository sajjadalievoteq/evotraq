import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';

/// Conditionally builds [child] when the signed-in user is allowed to see it.
///
/// Prefer [step] for operations UI (mirrors Phase 2 matrix via
/// [AuthState.canPerform]). Use [allowedRoles] for non-step gates (e.g. admin
/// tools). When both are set, the user must satisfy **either** check.
///
/// Hidden ≠ secure: the backend remains the real gate. This is UX only.
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

  /// Operations step key from [OperationSteps] / `operation_permissions.dart`.
  final String? step;

  /// Explicit role allow-list (e.g. `['ADMIN']`). Compared case-insensitively.
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
      (c) => _allows(c.state, step: step, roles: allowedRoles),
    );
    return allowed ? child : fallback;
  }
}

/// Shows [child] only for admins. Thin convenience over [RoleGate].
class AdminOnly extends StatelessWidget {
  const AdminOnly({
    super.key,
    required this.child,
    this.fallback = const SizedBox.shrink(),
  });

  final Widget child;
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    return RoleGate(
      allowedRoles: const ['ADMIN'],
      fallback: fallback,
      child: child,
    );
  }
}
