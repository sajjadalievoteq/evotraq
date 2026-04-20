import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:traqtrace_app/core/config/constants.dart';
import 'package:traqtrace_app/core/theme/color_manager.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/features/auth/presentation/widgets/auth_action_button.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String token;

  const VerifyEmailScreen({Key? key, required this.token}) : super(key: key);

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

  Future<void> _openGmail() async {
    final gmailUri = Uri.parse('https://mail.google.com/');
    await launchUrl(gmailUri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final textPrimary = ColorManager.textPrimary(context);
    final textSecondary = ColorManager.textSecondary(context);
    final primary = ColorManager.primary(context);
    final success = ColorManager.success(context);
    final error = ColorManager.error(context);

    return Scaffold(
      backgroundColor: ColorManager.background(context),
      appBar: AppBar(title: const Text('Email Verification')),
      body: BlocListener<AuthCubit, AuthState>(
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
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: _isVerifying
                            ? ColorManager.primaryContainer(context)
                            : (_successMessage != null
                                  ? success.withOpacity(0.14)
                                  : error.withOpacity(0.14)),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: _isVerifying
                          ? Padding(
                              padding: const EdgeInsets.all(28),
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  primary,
                                ),
                              ),
                            )
                          : Icon(
                              _successMessage != null
                                  ? Icons.verified_user_rounded
                                  : Icons.mark_email_unread_outlined,
                              size: 48,
                              color: _successMessage != null ? success : error,
                            ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _isVerifying
                          ? 'Verifying your email...'
                          : (_successMessage != null
                                ? 'Email verified'
                                : 'Verification failed'),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isVerifying
                          ? 'Please wait while we verify your email address.'
                          : (_successMessage ??
                                _errorMessage ??
                                'An error occurred during email verification.'),
                      style: TextStyle(
                        fontSize: 16,
                        color: textSecondary,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    if (_successMessage != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ColorManager.primaryContainer(
                            context,
                          ).withOpacity(0.55),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: ColorManager.primaryBorder(context),
                          ),
                        ),
                        child: Text(
                          'You can now return to login. If your email is verified but your account is still not accessible, it may still be waiting for admin approval.',
                          style: TextStyle(
                            fontSize: 14,
                            color: textSecondary,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    if (!_isVerifying) ...[
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: AuthActionButton(
                          label: _successMessage != null
                              ? 'GO TO LOGIN'
                              : 'CHECK YOUR INBOX',
                          onPressed: _successMessage != null
                              ? () => context.go(Constants.loginRoute)
                              : _openGmail,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => context.go(Constants.loginRoute),
                          child: const Text('BACK TO LOGIN'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
