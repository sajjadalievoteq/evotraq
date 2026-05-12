import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/home/presentation/cubit/home_dashboard_cubit.dart';

class HomeDashboardErrorView extends StatelessWidget {
  const HomeDashboardErrorView({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Failed to load dashboard: $message',
            style: context.text.body.copyWith(color: context.colors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final email = context.read<AuthCubit>().state.user?.email;
              context.read<HomeDashboardCubit>().refresh(ownerEmail: email);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
