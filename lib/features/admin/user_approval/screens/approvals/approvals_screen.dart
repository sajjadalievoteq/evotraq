import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/admin/user_approval/screens/approvals/approvals_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/features/admin/user_approval/cubit/user_approval_cubit.dart';

class ApprovalsScreen extends StatelessWidget {
  const ApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<UserApprovalCubit>(),
      child: const ApprovalsView(),
    );
  }
}
