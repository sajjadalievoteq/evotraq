import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/widgets/error_state/app_error_state.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/home/utils/home_strings.dart';
import 'package:traqtrace_app/features/home/cubit/home_cubit.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

class HomeErrorView extends StatelessWidget {
  const HomeErrorView({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return AppErrorState(
      title: 'Unable to load dashboard',
      message: HomeStrings.loadHomeFailed(message),
      iconAsset: AppAssets.iconDashboard,
      retryLabel: HomeStrings.retry,
      onRetry: () {
        final email = context.read<AuthCubit>().state.user?.email;
        context.read<HomeCubit>().refresh(accountEmail: email);
      },
    );
  }
}
