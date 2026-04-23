import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/constants.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/features/auth/presentation/login/widget/login_form_widget.dart';
import 'package:traqtrace_app/features/auth/presentation/widgets/auth_responsive_layout_widget.dart';
import 'package:traqtrace_app/features/auth/presentation/widgets/background_container_widget.dart';
import 'package:traqtrace_app/shared/widgets/custom_snackbar_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _shouldRedirectToCheckEmail(AuthState state) {
    final error = state.error?.trim().toLowerCase() ?? '';
    return state.status == AuthStatus.error &&
        error.contains('verify your email');
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundContainerWidget(
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (_shouldRedirectToCheckEmail(state)) {
            final email = state.registeredEmail?.trim();
            context.go(
              Uri(
                path: Constants.checkEmailRoute,
                queryParameters: {
                  if (email != null && email.isNotEmpty) 'email': email,
                },
              ).toString(),
            );
          } else if (state.status == AuthStatus.error) {
            context.showError(state.error ?? 'Authentication failed');
          } else if (state.status == AuthStatus.authenticated) {
            context.go(Constants.homeRoute);
          }
        },
        builder: (context, state) {
          return AuthResponsiveFormLayout(
            child: LoginFormWidget(state: state),
          );
        },
      ),
    );
  }
}
