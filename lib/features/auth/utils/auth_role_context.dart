import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';

extension AuthRoleContext on BuildContext {
  /// Watches [AuthCubit] and rebuilds when admin status changes.
  bool get isAdmin => select<AuthCubit, bool>((c) => c.state.isAdmin);

  /// One-shot read of admin status (no subscription).
  bool get readIsAdmin => read<AuthCubit>().state.isAdmin;

  bool get isManufacturer =>
      select<AuthCubit, bool>((c) => c.state.isManufacturer);

  bool get isDistributor =>
      select<AuthCubit, bool>((c) => c.state.isDistributor);

  bool get isRetailer => select<AuthCubit, bool>((c) => c.state.isRetailer);

  /// Watches whether the user may perform the given operations [step].
  bool canPerform(String step) =>
      select<AuthCubit, bool>((c) => c.state.canPerform(step));

  /// One-shot read of [AuthState.canPerform] (no subscription).
  bool readCanPerform(String step) => read<AuthCubit>().state.canPerform(step);

  /// Watches whether the user may read `/dashboard/summary`.
  bool get canReadDashboard =>
      select<AuthCubit, bool>((c) => c.state.canReadDashboard);

  /// Watches whether the user may read `/commissioning/throughput`.
  bool get canReadThroughput =>
      select<AuthCubit, bool>((c) => c.state.canReadThroughput);
}
