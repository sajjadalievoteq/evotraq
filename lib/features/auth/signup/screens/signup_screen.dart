import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/features/auth/signup/screens/widgets/signup_form_widget.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_form_header.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_responsive_layout_widget.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_screen_host.dart';
import 'package:traqtrace_app/core/config/constants.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String _typedEmail = '';

  @override
  Widget build(BuildContext context) {
    return AuthScreenHost(
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
                queryParameters: {if (email.isNotEmpty) 'email': email},
              ).toString(),
            );
          }
        },
        builder: (context, state) {
          return AuthResponsiveFormLayout(
            header: AuthFormHeader.register,
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
