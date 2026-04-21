import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/constants.dart';
import 'package:traqtrace_app/core/theme/color_manager.dart';
import 'package:traqtrace_app/data/models/auth/auth_models.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/features/auth/presentation/widgets/auth_action_button.dart';
import 'package:traqtrace_app/features/auth/presentation/widgets/auth_input_field.dart';
import 'package:traqtrace_app/shared/widgets/custom_text_button_widget.dart';

class LoginFormWidget extends StatefulWidget {
  const LoginFormWidget({
    super.key,
    required this.state,
  });

  final AuthState state;

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _hasRequiredInput = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final loginRequest = LoginRequest(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      context.read<AuthCubit>().login(loginRequest);
    }
  }

  void _updateButtonState() {
    final hasRequiredInput =
        _usernameController.text.trim().isNotEmpty &&
        _passwordController.text.isNotEmpty;
    if (hasRequiredInput != _hasRequiredInput) {
      setState(() {
        _hasRequiredInput = hasRequiredInput;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textPrimary = ColorManager.textPrimary(context);
    final isLoading = widget.state.status == AuthStatus.loading;

    return Form(
      key: _formKey,
      onChanged: _updateButtonState,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthInputField(
            controller: _usernameController,
            labelText: 'Username or Email',
            hintText: 'Enter username or email',
            helperText: 'Use your username or email to log in',
            type: AuthInputFieldType.username,
            enabled: !isLoading,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if ((value?.trim() ?? '').isEmpty) {
                return 'Username or email is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AuthInputField(
            controller: _passwordController,
            labelText: 'Password',
            type: AuthInputFieldType.password,
            enabled: !isLoading,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submitForm(),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: CustomTextButtonWidget(
              title: 'Forgot Password?',
              onTap: () {
                context.go(Constants.forgotPasswordRoute);
              },
            ),
          ),
          const SizedBox(height: 16),
          AuthActionButton(
            label: 'LOGIN',
            isLoading: isLoading,
            isEnabled: _hasRequiredInput && !isLoading,
            onPressed: _submitForm,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Don\'t have an account?',
                style: TextStyle(color: textPrimary),
              ),
              CustomTextButtonWidget(
                title: 'Register',
                onTap: () {
                  context.go(Constants.registerRoute);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
