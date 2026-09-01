import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';

extension AuthRoleContext on BuildContext {
  
  bool get isAdmin => select<AuthCubit, bool>((c) => c.state.isAdmin);

  bool get readIsAdmin => read<AuthCubit>().state.isAdmin;

  bool get isManufacturer =>
      select<AuthCubit, bool>((c) => c.state.isManufacturer);

  bool get isDistributor =>
      select<AuthCubit, bool>((c) => c.state.isDistributor);

  bool get isRetailer => select<AuthCubit, bool>((c) => c.state.isRetailer);

  bool canPerform(String step) =>
      select<AuthCubit, bool>((c) => c.state.canPerform(step));

  bool readCanPerform(String step) => read<AuthCubit>().state.canPerform(step);

  bool get canReadDashboard =>
      select<AuthCubit, bool>((c) => c.state.canReadDashboard);

  bool get canReadThroughput =>
      select<AuthCubit, bool>((c) => c.state.canReadThroughput);
}