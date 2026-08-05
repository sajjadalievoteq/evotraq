import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/features/auth/utils/auth_password_validator.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_action_button.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_hero_icon.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_hero_subtitle.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_hero_title.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_input_field.dart';
import 'package:traqtrace_app/features/auth/widgets/input/auth_input_field_type.dart';

class ResetPasswordFormWidget extends StatefulWidget {
  const ResetPasswordFormWidget({super.key, required this.token});

  final String token;

  @override
  State<ResetPasswordFormWidget> createState() =>
      _ResetPasswordFormWidgetState();
}

class _ResetPasswordFormWidgetState extends State<ResetPasswordFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _hasRequiredInput = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().completePasswordReset(
        widget.token,
        _passwordController.text,
        _confirmPasswordController.text,
      );
    }
  }

  void _updateButtonState() {
    final hasRequiredInput =
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty;
    if (hasRequiredInput != _hasRequiredInput) {
      setState(() {
        _hasRequiredInput = hasRequiredInput;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isLoading = context.select<AuthCubit, bool>(
      (cubit) => cubit.state.status == AuthStatus.loading,
    );

    return Form(
      key: _formKey,
      onChanged: _updateButtonState,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthHeroIcon(asset: AppAssets.iconLock, color: c.primary),
          const SizedBox(height: 24),
          AuthHeroTitle(title: 'Create New Password', color: c.primary),
          const SizedBox(height: 16),
          AuthHeroSubtitle(
            subtitle:
                'Your password must be at least 12 characters long and include a mix of letters, numbers, and symbols.',
            color: c.textSecondary,
          ),
          const SizedBox(height: 32),
          AuthInputField(
            controller: _passwordController,
            labelText: 'New Password',
            type: AuthInputFieldType.password,
            enabled: !isLoading,
            validator: (value) => AuthPasswordValidator.validate(
              value,
              emptyMessage: 'Please enter a new password',
            ),
          ),
          const SizedBox(height: 16),
          AuthInputField(
            controller: _confirmPasswordController,
            labelText: 'Confirm Password',
            type: AuthInputFieldType.password,
            enabled: !isLoading,
            validator: (value) => AuthPasswordValidator.validateConfirmation(
              value,
              _passwordController.text,
            ),
          ),
          const SizedBox(height: 32),
          AuthActionButton(
            label: 'RESET PASSWORD',
            isLoading: isLoading,
            isEnabled: _hasRequiredInput && !isLoading,
            onPressed: _submitForm,
          ),
        ],
      ),
    );
  }
}
