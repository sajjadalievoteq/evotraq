import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/features/auth/presentation/reset_password/widget/reset_password_form_widget.dart';
import 'package:traqtrace_app/features/auth/presentation/reset_password/widget/reset_password_invalid_token_widget.dart';
import 'package:traqtrace_app/features/auth/presentation/widgets/auth_responsive_layout_widget.dart';
import 'package:traqtrace_app/core/widgets/background_container_widget.dart';
import 'package:traqtrace_app/features/auth/presentation/widgets/build_success_message_widget.dart';
import 'package:traqtrace_app/shared/widgets/custom_snackbar_widget.dart';

import '../../../../../core/config/constants.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String token;

  const ResetPasswordScreen({super.key, required this.token});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  @override
  void initState() {
    super.initState();
    _validateToken();
  }

  Future<void> _validateToken() async {
    // Call the cubit to validate the token
    context.read<AuthCubit>().validatePasswordResetToken(widget.token);
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundContainerWidget(
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.error) {
            context.showError(state.error ?? 'An error occurred');
          }
        },
        builder: (context, state) {
          if (state.status == AuthStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == AuthStatus.passwordResetTokenInvalid) {
            return const ResetPasswordInvalidTokenWidget();
          }

          if (state.status == AuthStatus.passwordReset) {
            return AuthResponsiveFormLayout(
              child: BuildSuccessMessage(
                title: 'Password Reset Successfully',
                message:
                    'Your password has been reset successfully. You can now log in with your new password.',
                buttonLabel: 'GO TO LOGIN',
                onButtonPressed: () {
                  context.go(Constants.loginRoute);
                },
              ),
            );
          }

          return AuthResponsiveFormLayout(
            child: ResetPasswordFormWidget(token: widget.token),
          );
        },
      ),
    );
  }
}