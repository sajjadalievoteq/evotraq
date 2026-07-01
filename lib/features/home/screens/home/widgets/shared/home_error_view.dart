import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/home/utils/home_strings.dart';
import 'package:traqtrace_app/features/home/cubit/home_cubit.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

class HomeErrorView extends StatelessWidget {
  const HomeErrorView({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TraqIcon(AppAssets.iconAlert, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            HomeStrings.loadHomeFailed(message),
            style: context.text.body.copyWith(color: context.colors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final email = context.read<AuthCubit>().state.user?.email;
              context.read<HomeCubit>().refresh(accountEmail: email);
            },
            child: const Text(HomeStrings.retry),
          ),
        ],
      ),
    );
  }
}
