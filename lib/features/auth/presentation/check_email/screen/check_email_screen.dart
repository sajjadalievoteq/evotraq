import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/features/auth/presentation/check_email/widget/check_email_content_widget.dart';
import 'package:traqtrace_app/features/auth/presentation/widgets/auth_responsive_layout_widget.dart';
import 'package:traqtrace_app/features/auth/presentation/widgets/background_container_widget.dart';
import 'package:traqtrace_app/shared/widgets/custom_snackbar_widget.dart';

class CheckEmailScreen extends StatefulWidget {
  final String? email;

  const CheckEmailScreen({super.key, this.email});

  @override
  State<CheckEmailScreen> createState() => _CheckEmailScreenState();
}

class _CheckEmailScreenState extends State<CheckEmailScreen> {
  bool _isResendInFlight = false;

  void _handleResend(String email) {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) {
      context.showError('Email address is required to resend verification email.');
      return;
    }

    setState(() {
      _isResendInFlight = true;
    });
    context.read<AuthCubit>().resendVerificationEmail(trimmedEmail);
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundContainerWidget(
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (!_isResendInFlight) {
            return;
          }

          if (state.status == AuthStatus.verificationEmailResent) {
            setState(() {
              _isResendInFlight = false;
            });
            context.showSuccess(
              state.message ??
                  'If an unverified account exists for that email, a new verification email has been sent.',
            );
          } else if (state.status == AuthStatus.error) {
            setState(() {
              _isResendInFlight = false;
            });
            context.showError(
              state.error ?? 'Failed to resend verification email.',
            );
          }
        },
        builder: (context, state) {
          final resolvedEmail =
              (widget.email?.trim().isNotEmpty ?? false)
              ? widget.email!.trim()
              : state.registeredEmail;

          return AuthResponsiveFormLayout(
            child: CheckEmailContentWidget(
              email: resolvedEmail,
              isResending:
                  _isResendInFlight && state.status == AuthStatus.loading,
              onResend: resolvedEmail == null
                  ? null
                  : () => _handleResend(resolvedEmail),
            ),
          );
        },
      ),
    );
  }
}
