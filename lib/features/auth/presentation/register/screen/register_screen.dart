import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/features/auth/presentation/register/widget/register_form_widget.dart';
import 'package:traqtrace_app/features/auth/presentation/widgets/auth_responsive_layout_widget.dart';
import 'package:traqtrace_app/features/auth/presentation/widgets/background_container_widget.dart';
import 'package:traqtrace_app/shared/widgets/custom_snackbar_widget.dart';

import '../../../../../core/config/constants.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String _typedEmail = '';

  @override
  Widget build(BuildContext context) {
    return BackgroundContainerWidget(
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.error) {
            context.showError(state.error ?? 'Registration failed');
          } else if (state.status == AuthStatus.registered) {
            final email = state.registeredEmail ?? _typedEmail;
            context.showSuccess(
              state.message ??
                  'Registration successful. Check your email to verify your account before logging in.',
            );
            context.go(
              Uri(
                path: Constants.checkEmailRoute,
                queryParameters: {
                  if (email.isNotEmpty) 'email': email,
                },
              ).toString(),
            );
          }
        },
        builder: (context, state) {
          return AuthResponsiveFormLayout(
            child: RegisterFormWidget(
              state: state,
              onEmailChanged: (email) => _typedEmail = email,
            ),
          );
        },
      ),
    );
  }
}
