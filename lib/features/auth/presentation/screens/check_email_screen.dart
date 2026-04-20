import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:traqtrace_app/core/config/constants.dart';
import 'package:traqtrace_app/core/theme/color_manager.dart';
import 'package:traqtrace_app/features/auth/presentation/widgets/auth_action_button.dart';

class CheckEmailScreen extends StatelessWidget {
  final String? email;

  const CheckEmailScreen({super.key, this.email});

  Future<void> _openGmail() async {
    final gmailUri = Uri.parse('https://mail.google.com/');
    await launchUrl(gmailUri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final textPrimary = ColorManager.textPrimary(context);
    final textSecondary = ColorManager.textSecondary(context);
    final primary = ColorManager.primary(context);
    final emailText = email?.trim();

    return Scaffold(
      backgroundColor: ColorManager.background(context),
      appBar: AppBar(title: const Text('Check Your Email')),
      body: SafeArea(
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
                      color: ColorManager.primaryContainer(context),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Icon(
                      Icons.mark_email_read_rounded,
                      size: 48,
                      color: primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Verify your email',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    emailText == null || emailText.isEmpty
                        ? 'We sent a verification email to your inbox. Please check your inbox and spam folder, then verify your email before logging in.'
                        : 'We sent a verification email to $emailText. Please check your inbox and spam folder, then verify your email before logging in.',
                    style: TextStyle(
                      fontSize: 16,
                      color: textSecondary,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'What happens next?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '1. Open the verification email.\n2. Click the verification link.\n3. Return here and log in.\n4. If your email is verified, your account may still wait for admin approval.',
                          style: TextStyle(
                            fontSize: 14,
                            color: textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: AuthActionButton(
                      label: 'OPEN GMAIL',
                      onPressed: _openGmail,
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
