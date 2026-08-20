import 'package:traqtrace_app/core/animation/traq_staggered_entrance_widget.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_action_button.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_footer_link_row.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_hero_icon.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_hero_subtitle.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_hero_title.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_input_field.dart';
import 'package:traqtrace_app/features/auth/widgets/input/auth_input_field_type.dart';

class ForgotPasswordForm extends StatefulWidget {
  const ForgotPasswordForm({super.key, required this.onSubmitted});

  final VoidCallback onSubmitted;

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isSubmitting = false;
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

      setState(() {
        _isSubmitting = false;
      });
      widget.onSubmitted();
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
    final c = context.colors;

    return Form(
      key: _formKey,
      onChanged: _updateButtonState,
      child: TraqStaggeredEntrance(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: AuthHeroIcon(
              asset: AppAssets.iconLock,
              color: c.primary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: AuthHeroTitle(
              title: 'Reset Your Password',
              color: c.primary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: AuthHeroSubtitle(
              subtitle:
                  'Enter your email address and we will send you instructions to reset your password.',
              color: c.textSecondary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 32),
            child: AuthInputField(
              controller: _emailController,
              labelText: 'Email',
              type: AuthInputFieldType.email,
              enabled: !_isSubmitting,
              onFieldSubmitted: (_) => _submitForm(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 32),
            child: AuthActionButton(
              label: 'SEND RESET INSTRUCTIONS',
              isLoading: _isSubmitting,
              isEnabled: _hasRequiredInput && !_isSubmitting,
              onPressed: _submitForm,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: AuthFooterLinkRow(
              prompt: 'Remember your password?',
              actionLabel: 'Login',
              onTap: () => context.go(Constants.loginRoute),
            ),
          ),
        ],
      ),
    );
  }
}
