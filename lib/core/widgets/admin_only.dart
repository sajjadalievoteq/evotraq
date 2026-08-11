import 'package:flutter/widgets.dart';
import 'package:traqtrace_app/core/widgets/role_gate_widget.dart';

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
