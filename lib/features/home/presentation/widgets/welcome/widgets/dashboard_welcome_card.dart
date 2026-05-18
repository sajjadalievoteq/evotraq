import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/features/home/presentation/constants/home_strings.dart';

class DashboardWelcomeCard extends StatelessWidget {
  const DashboardWelcomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (p, c) => p.user != c.user,
      builder: (context, state) {
        final user = state.user;
        if (user == null) {
          return const SizedBox.shrink();
        }

        final now = DateTime.now();
        final String greeting;

        if (now.hour < 12) {
          greeting = HomeStrings.welcomeMorning;
        } else if (now.hour < 17) {
          greeting = HomeStrings.welcomeAfternoon;
        } else {
          greeting = HomeStrings.welcomeEvening;
        }

        return Card(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isSmallScreen = constraints.maxWidth < 400;
          
              return Padding(
                padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            HomeStrings.welcomeFirstNameLine(user.firstName),
                            style: context.text.h2.copyWith(

                              fontSize: isSmallScreen ? 18 : 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            greeting,
                            style: context.text.body.copyWith(
                              color: context.colors.primary,
                              fontSize: isSmallScreen ? 12 : 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isSmallScreen) ...[
                      const SizedBox(width: 16),

                    ],
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
