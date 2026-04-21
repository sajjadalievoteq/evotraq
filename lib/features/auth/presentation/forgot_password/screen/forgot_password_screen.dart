import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/features/auth/presentation/widgets/background_container_widget.dart';
import 'package:traqtrace_app/features/auth/presentation/widgets/build_success_message_widget.dart';

import 'package:traqtrace_app/features/auth/presentation/widgets/auth_responsive_layout_widget.dart';
import 'package:traqtrace_app/shared/widgets/custom_snackbar_widget.dart';

import '../../../../../core/config/constants.dart';
import '../widget/forgot_password_form_widget.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isSubmitting = false;
  bool _isSubmitted = false;
  bool _hasRequiredInput = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      context.read<AuthCubit>().requestPasswordReset(_emailController.text);

      // We always show success regardless of actual success to prevent email enumeration
      setState(() {
        _isSubmitting = false;
        _isSubmitted = true;
      });
    }
  }

  void _updateButtonState() {
    final hasRequiredInput = _emailController.text.trim().isNotEmpty;
    if (hasRequiredInput != _hasRequiredInput) {
      setState(() {
        _hasRequiredInput = hasRequiredInput;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return  BackgroundContainerWidget(
      child: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state.status == AuthStatus.error) {
              context.showError(state.error ?? 'An error occurred');
            }
          },
          child: AuthResponsiveFormLayout(
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
                : ForgotPasswordForm(
                    formKey: _formKey,
                    emailController: _emailController,
                    isSubmitting: _isSubmitting,
                    hasRequiredInput: _hasRequiredInput,
                    onSubmit: _submitForm,
                    onFormChanged: _updateButtonState,
                  ),
          ),
      ),
    );
  }
}
