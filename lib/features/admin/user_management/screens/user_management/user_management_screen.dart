import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/admin/user_management/screens/user_management/user_management_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/features/admin/user_management/cubit/user_management_cubit.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<UserManagementCubit>(),
      child: const UserManagementView(),
    );
  }
}
