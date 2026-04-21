import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/theme/color_manager.dart';
import 'package:traqtrace_app/data/models/auth/auth_models.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/features/auth/presentation/widgets/auth_action_button.dart';
import 'package:traqtrace_app/features/auth/presentation/widgets/auth_input_field.dart';

import '../../../../../core/config/constants.dart';
import '../../../../../shared/widgets/custom_text_button_widget.dart';

enum _UsernameAvailabilityStatus { initial, checking, available, taken, error }

class RegisterFormWidget extends StatefulWidget {
  const RegisterFormWidget({
    super.key,
    required this.state,
    this.onEmailChanged,
  });

  final AuthState state;
  final ValueChanged<String>? onEmailChanged;

  @override
  State<RegisterFormWidget> createState() => _RegisterFormWidgetState();
}

class _RegisterFormWidgetState extends State<RegisterFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _hasRequiredInput = false;
  Timer? _usernameDebounceTimer;
  int _usernameRequestId = 0;
  final Map<String, _UsernameAvailabilityStatus> _usernameAvailabilityCache =
      {};
  _UsernameAvailabilityStatus _usernameAvailabilityStatus =
      _UsernameAvailabilityStatus.initial;
  String? _usernameAvailabilityMessage;

  @override
  void dispose() {
    _usernameDebounceTimer?.cancel();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    widget.onEmailChanged?.call(_emailController.text.trim());

    if (_formKey.currentState!.validate()) {
      final registerRequest = RegisterRequest(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );

      context.read<AuthCubit>().register(registerRequest);
    }
  }

  void _updateButtonState() {
    final hasRequiredInput =
        _firstNameController.text.trim().isNotEmpty &&
        _lastNameController.text.trim().isNotEmpty &&
        _usernameController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty;
    if (hasRequiredInput != _hasRequiredInput) {
      setState(() {
        _hasRequiredInput = hasRequiredInput;
      });
    }
  }

  void _handleUsernameChanged(String value) {
    final trimmedUsername = value.trim();
    _usernameDebounceTimer?.cancel();
    final requestId = ++_usernameRequestId;

    if (trimmedUsername.isEmpty || trimmedUsername.length < 3) {
      if (_usernameAvailabilityStatus != _UsernameAvailabilityStatus.initial ||
          _usernameAvailabilityMessage != null) {
        setState(() {
          _usernameAvailabilityStatus = _UsernameAvailabilityStatus.initial;
          _usernameAvailabilityMessage = null;
        });
      }
      return;
    }

    final cachedStatus = _usernameAvailabilityCache[trimmedUsername];
    if (cachedStatus != null) {
      setState(() {
        _usernameAvailabilityStatus = cachedStatus;
        _usernameAvailabilityMessage = _usernameMessageForStatus(cachedStatus);
      });
      return;
    }

    setState(() {
      _usernameAvailabilityStatus = _UsernameAvailabilityStatus.checking;
      _usernameAvailabilityMessage = null;
    });

    _usernameDebounceTimer = Timer(const Duration(milliseconds: 400), () async {
      try {
        final isAvailable = await context
            .read<AuthCubit>()
            .authService
            .checkUsernameAvailability(trimmedUsername);

        if (!mounted || requestId != _usernameRequestId) {
          return;
        }

        final status = isAvailable
            ? _UsernameAvailabilityStatus.available
            : _UsernameAvailabilityStatus.taken;
        _usernameAvailabilityCache[trimmedUsername] = status;

        setState(() {
          _usernameAvailabilityStatus = status;
          _usernameAvailabilityMessage = _usernameMessageForStatus(status);
        });
      } catch (_) {
        if (!mounted || requestId != _usernameRequestId) {
          return;
        }

        _usernameAvailabilityCache[trimmedUsername] =
            _UsernameAvailabilityStatus.error;

        setState(() {
          _usernameAvailabilityStatus = _UsernameAvailabilityStatus.error;
          _usernameAvailabilityMessage = _usernameMessageForStatus(
            _UsernameAvailabilityStatus.error,
          );
        });
      }
    });
  }

  String? _usernameMessageForStatus(_UsernameAvailabilityStatus status) {
    switch (status) {
      case _UsernameAvailabilityStatus.available:
        return 'Username available';
      case _UsernameAvailabilityStatus.taken:
        return 'Username already taken';
      case _UsernameAvailabilityStatus.error:
        return "Couldn't verify username right now";
      case _UsernameAvailabilityStatus.initial:
      case _UsernameAvailabilityStatus.checking:
        return null;
    }
  }

  Color? _usernameMessageColor(BuildContext context) {
    switch (_usernameAvailabilityStatus) {
      case _UsernameAvailabilityStatus.available:
        return Colors.green.shade600;
      case _UsernameAvailabilityStatus.taken:
        return Theme.of(context).colorScheme.error;
      case _UsernameAvailabilityStatus.error:
        return ColorManager.textSecondary(context);
      case _UsernameAvailabilityStatus.initial:
      case _UsernameAvailabilityStatus.checking:
        return null;
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AuthInputField(
            controller: _firstNameController,
            labelText: 'First Name',
            prefixIcon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your first name';
              }
              return null;
            },
            enabled: !isLoading,
          ),
          const SizedBox(height: 16),
          AuthInputField(
            controller: _lastNameController,
            labelText: 'Last Name',
            prefixIcon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your last name';
              }
              return null;
            },
            enabled: !isLoading,
          ),
          const SizedBox(height: 16),
          AuthInputField(
            controller: _usernameController,
            labelText: 'Username',
            type: AuthInputFieldType.username,
            prefixIcon: Icons.account_circle,
            onChanged: _handleUsernameChanged,
            suffixIcon:
                _usernameAvailabilityStatus ==
                    _UsernameAvailabilityStatus.checking
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : null,
            helperText: _usernameAvailabilityMessage,
            helperTextColor: _usernameMessageColor(context),
            validator: (value) {
              final trimmedValue = value?.trim() ?? '';

              if (trimmedValue.isEmpty) {
                return 'Please enter a username';
              }
              if (trimmedValue.length < 4) {
                return 'Username must be at least 4 characters';
              }
              if (_usernameAvailabilityStatus ==
                  _UsernameAvailabilityStatus.taken) {
                return 'Username already taken';
              }
              return null;
            },
            enabled: !isLoading,
          ),
          const SizedBox(height: 16),
          AuthInputField(
            controller: _emailController,
            labelText: 'Email',
            type: AuthInputFieldType.email,
            enabled: !isLoading,
            onChanged: (value) {
              widget.onEmailChanged?.call(value.trim());
            },
          ),
          const SizedBox(height: 16),
          AuthInputField(
            controller: _passwordController,
            labelText: 'Password',
            type: AuthInputFieldType.password,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              return null;
            },
            enabled: !isLoading,
          ),
          const SizedBox(height: 16),
          AuthInputField(
            controller: _confirmPasswordController,
            labelText: 'Confirm Password',
            type: AuthInputFieldType.password,
            prefixIcon: Icons.lock_outline,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
            enabled: !isLoading,
          ),
          const SizedBox(height: 24),
          AuthActionButton(
            label: 'REGISTER',
            isLoading: isLoading,
            isEnabled: _hasRequiredInput && !isLoading,
            onPressed: _submitForm,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already have an account?',
                style: TextStyle(color: textPrimary),
              ),
              CustomTextButtonWidget(
                title: 'Login',
                onTap: () {
                  context.go(Constants.loginRoute);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
