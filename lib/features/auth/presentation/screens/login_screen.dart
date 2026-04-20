import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/constants.dart';
import 'package:traqtrace_app/core/theme/color_manager.dart';
import 'package:traqtrace_app/data/models/auth/auth_models.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/features/auth/presentation/screens/register_screen.dart';
import 'package:traqtrace_app/features/auth/presentation/widgets/auth_action_button.dart';
import 'package:traqtrace_app/features/auth/presentation/widgets/auth_input_field.dart';
import 'package:traqtrace_app/shared/widgets/custom_snackbar_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
    final primary = ColorManager.primary(context);
    final textPrimary = ColorManager.textPrimary(context);
    final textSecondary = ColorManager.textSecondary(context);

    return Scaffold(
      backgroundColor: ColorManager.background(context),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.error) {
            context.showError(state.error ?? 'Authentication failed');
          } else if (state.status == AuthStatus.authenticated) {
            context.go('/home');
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                onChanged: _updateButtonState,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 48),
                    // Logo
                    Icon(Icons.track_changes_rounded, size: 80, color: primary),
                    const SizedBox(height: 24),
                    // App Name
                    Text(
                      'evotraq.io',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    // App Description
                    Text(
                      'GS1-compliant track and trace system',
                      style: TextStyle(fontSize: 16, color: textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    // Username Or Email Field
                    AuthInputField(
                      controller: _usernameController,
                      labelText: 'Username or Email',
                      hintText: 'Enter username or email',
                      helperText: 'Use your username or email to log in',
                      type: AuthInputFieldType.username,
                      enabled: state.status != AuthStatus.loading,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if ((value?.trim() ?? '').isEmpty) {
                          return 'Username or email is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Password Field
                    AuthInputField(
                      controller: _passwordController,
                      labelText: 'Password',
                      type: AuthInputFieldType.password,
                      enabled: state.status != AuthStatus.loading,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submitForm(),
                    ),
                    const SizedBox(height: 8),
                    // Forgot Password Link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          context.go(Constants.forgotPasswordRoute);
                        },
                        child: const Text('Forgot Password?'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Login Button
                    AuthActionButton(
                      label: 'LOGIN',
                      isLoading: state.status == AuthStatus.loading,
                      isEnabled:
                          _hasRequiredInput &&
                          state.status != AuthStatus.loading,
                      onPressed: _submitForm,
                    ),
                    const SizedBox(height: 16),
                    // Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an account?',
                          style: TextStyle(color: textPrimary),
                        ),
                        TextButtonWidget(title: 'Register', onTap: () {
              context.go(Constants.registerRoute);
              },)

                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
