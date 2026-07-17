import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/features/auth/reset_password/screens/widgets/reset_password_form_widget.dart';
import 'package:traqtrace_app/features/auth/reset_password/screens/widgets/reset_password_invalid_token_widget.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_form_header.dart';
import 'package:traqtrace_app/core/web/auth_navigation_stub.dart'
    if (dart.library.html) 'package:traqtrace_app/core/web/auth_navigation_web.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_responsive_layout_widget.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_screen_host.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_staggered_entrance.dart';
import 'package:traqtrace_app/features/auth/widgets/build_success_message_widget.dart';
import 'package:traqtrace_app/features/auth/reset_password/screens/widgets/reset_password_loading_body.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';

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
    context.read<AuthCubit>().validatePasswordResetToken(widget.token);
  }

  String _statusKey(AuthState state) {
    if (state.status == AuthStatus.loading) return 'loading';
    if (state.status == AuthStatus.passwordResetTokenInvalid) return 'invalid';
    if (state.status == AuthStatus.passwordReset) return 'success';
    return 'form';
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenHost(
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.error) {
            context.showError(state.error ?? 'An error occurred');
          }
        },
        builder: (context, state) {
          late final Widget body;
          if (state.status == AuthStatus.loading) {
            body = const ResetPasswordLoadingBody();
          } else if (state.status == AuthStatus.passwordResetTokenInvalid) {
            body = const ResetPasswordInvalidTokenWidget();
          } else if (state.status == AuthStatus.passwordReset) {
            body = AuthResponsiveFormLayout(
              header: AuthFormHeader.passwordResetComplete,
              child: BuildSuccessMessage(
                title: 'Password Reset Successfully',
                message:
                    'Your password has been reset successfully. You can now log in with your new password.',
                buttonLabel: 'GO TO LOGIN',
                onButtonPressed: () => goToLogin(context),
              ),
            );
          } else {
            body = AuthResponsiveFormLayout(
              header: AuthFormHeader.resetPassword,
              child: ResetPasswordFormWidget(token: widget.token),
            );
          }

          return AuthStatusSwitcher(
            statusKey: _statusKey(state),
            child: body,
          );
        },
      ),
    );
  }
}
