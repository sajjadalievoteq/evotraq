import 'package:traqtrace_app/core/animation/traq_status_switcher.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_presenter.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/features/auth/screens/forgot_password/widgets/forgot_password_form_widget.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_form_header.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_responsive_form_layout.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_screen_host.dart';
import 'package:traqtrace_app/features/auth/widgets/build_success_message_widget.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool _isSubmitted = false;

  void _onSubmitted() {
    setState(() {
      _isSubmitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenHost(
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.error) {
            context.showError(state.error ?? 'An error occurred');
          }
        },
        child: TraqStatusSwitcher(
          statusKey: _isSubmitted ? 'submitted' : 'form',
          child: AuthResponsiveFormLayout(
            header: _isSubmitted
                ? AuthFormHeader.checkEmail
                : AuthFormHeader.forgotPassword,
            child: _isSubmitted
                ? BuildSuccessMessage(
                    title: 'Check Your Email',
                    message:
                        'If an account exists with the email you provided, we have sent password reset instructions.',
                    buttonLabel: 'BACK TO LOGIN',
                    onButtonPressed: () {
                      context.go(Constants.loginRoute);
                    },
                  )
                : ForgotPasswordForm(onSubmitted: _onSubmitted),
          ),
        ),
      ),
    );
  }
}
