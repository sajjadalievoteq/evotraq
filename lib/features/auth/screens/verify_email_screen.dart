import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/theme/app_theme.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String token;

  const VerifyEmailScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isVerifying = true;
  bool _isVerified = false;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Verification'),
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.emailVerified) {
            setState(() {
              _isVerifying = false;
              _isVerified = true;
            });
          } else if (state.status == AuthStatus.error) {
            setState(() {
              _isVerifying = false;
              _errorMessage = state.error ?? 'Failed to verify email';
            });
          }
        },
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: _buildContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isVerifying) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(),
          SizedBox(height: 24),
          Text(
            'Verifying your email...',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    if (_isVerified) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle,
            color: AppTheme.successColor,
            size: 100,
          ),
          const SizedBox(height: 24),
          const Text(
            'Email Verified Successfully!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Your email has been verified. Your account is now pending admin approval.',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                context.go('/login');
              },
              child: const Text('GO TO LOGIN', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      );
    }

    // Error state
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.error,
          color: Colors.red,
          size: 100,
        ),
        const SizedBox(height: 24),
        const Text(
          'Verification Failed',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          _errorMessage ?? 'An error occurred during email verification.',
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              context.go('/login');
            },
            child: const Text('GO TO LOGIN', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }
}