import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/features/auth/presentation/verify_email/widget/verify_email_content_widget.dart';
import 'package:traqtrace_app/features/auth/presentation/widgets/auth_responsive_layout_widget.dart';
import 'package:traqtrace_app/core/widgets/background_container_widget.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String token;
  final String? email;

  const VerifyEmailScreen({super.key, required this.token, this.email});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isVerifying = true;
  String? _successMessage;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _verifyEmail();
  }

  Future<void> _verifyEmail() async {
    if (widget.token.isEmpty) {
      setState(() {
        _isVerifying = false;
        _errorMessage = 'Invalid verification token';
      });
      return;
    }

    // Dispatch the email verification action
    context.read<AuthCubit>().verifyEmail(widget.token);
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundContainerWidget(
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.emailVerified) {
            setState(() {
              _isVerifying = false;
              _successMessage =
                  state.message ??
                  'Email verified successfully. Your account is now pending admin approval.';
              _errorMessage = null;
            });
          } else if (state.status == AuthStatus.error) {
            setState(() {
              _isVerifying = false;
              _errorMessage = state.error ?? 'Failed to verify email';
              _successMessage = null;
            });
          }
        },
        child: AuthResponsiveFormLayout(
          child: VerifyEmailContentWidget(
            isVerifying: _isVerifying,
            successMessage: _successMessage,
            errorMessage: _errorMessage,
            email: widget.email,
          ),
        ),
      ),
    );
  }
}
