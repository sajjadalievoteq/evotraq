import 'package:traqtrace_app/core/animation/traq_staggered_entrance_widget.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/data/models/auth/register_request.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/features/auth/utils/auth_password_validator.dart';
import 'package:traqtrace_app/features/auth/utils/auth_username_availability.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_action_button.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_footer_link_row.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_input_field.dart';
import 'package:traqtrace_app/features/auth/widgets/input/auth_input_field_type.dart';

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
  final Map<String, UsernameAvailabilityStatus> _usernameAvailabilityCache =
      {};
  UsernameAvailabilityStatus _usernameAvailabilityStatus =
      UsernameAvailabilityStatus.initial;
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

    if (trimmedUsername.isEmpty ||
        trimmedUsername.length < AuthUsernameAvailability.minCheckLength) {
      if (_usernameAvailabilityStatus != UsernameAvailabilityStatus.initial ||
          _usernameAvailabilityMessage != null) {
        setState(() {
          _usernameAvailabilityStatus = UsernameAvailabilityStatus.initial;
          _usernameAvailabilityMessage = null;
        });
      }
      return;
    }

    final cachedStatus = _usernameAvailabilityCache[trimmedUsername];
    if (cachedStatus != null) {
      setState(() {
        _usernameAvailabilityStatus = cachedStatus;
        _usernameAvailabilityMessage =
            AuthUsernameAvailability.messageForStatus(cachedStatus);
      });
      return;
    }

    setState(() {
      _usernameAvailabilityStatus = UsernameAvailabilityStatus.checking;
      _usernameAvailabilityMessage = null;
    });

    _usernameDebounceTimer = Timer(AuthUsernameAvailability.debounce, () async {
      try {
        final isAvailable = await context
            .read<AuthCubit>()
            .authService
            .checkUsernameAvailability(trimmedUsername);

        if (!mounted || requestId != _usernameRequestId) {
          return;
        }

        final status = isAvailable
            ? UsernameAvailabilityStatus.available
            : UsernameAvailabilityStatus.taken;
        _usernameAvailabilityCache[trimmedUsername] = status;

        setState(() {
          _usernameAvailabilityStatus = status;
          _usernameAvailabilityMessage =
              AuthUsernameAvailability.messageForStatus(status);
        });
      } catch (_) {
        if (!mounted || requestId != _usernameRequestId) {
          return;
        }

        _usernameAvailabilityCache[trimmedUsername] =
            UsernameAvailabilityStatus.error;

        setState(() {
          _usernameAvailabilityStatus = UsernameAvailabilityStatus.error;
          _usernameAvailabilityMessage =
              AuthUsernameAvailability.messageForStatus(
            UsernameAvailabilityStatus.error,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = widget.state.status == AuthStatus.loading;

    return Form(
      key: _formKey,
      onChanged: _updateButtonState,
      child: TraqStaggeredEntrance(
        children: [
          AuthInputField(
            controller: _firstNameController,
            labelText: 'First Name',
            prefixAsset: AppAssets.iconUser,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your first name';
              }
              return null;
            },
            enabled: !isLoading,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: AuthInputField(
              controller: _lastNameController,
              labelText: 'Last Name',
              prefixAsset: AppAssets.iconUser,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your last name';
                }
                return null;
              },
              enabled: !isLoading,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: AuthInputField(
              controller: _usernameController,
              labelText: 'Username',
              type: AuthInputFieldType.username,
              prefixAsset: AppAssets.iconUser,
              onChanged: _handleUsernameChanged,
              suffixIcon:
                  _usernameAvailabilityStatus ==
                      UsernameAvailabilityStatus.checking
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
              helperText: _usernameAvailabilityMessage,
              helperTextColor: AuthUsernameAvailability.messageColor(
                context,
                _usernameAvailabilityStatus,
              ),
              validator: (value) => AuthUsernameAvailability.validate(
                value,
                _usernameAvailabilityStatus,
              ),
              enabled: !isLoading,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: AuthInputField(
              controller: _emailController,
              labelText: 'Email',
              type: AuthInputFieldType.email,
              enabled: !isLoading,
              onChanged: (value) {
                widget.onEmailChanged?.call(value.trim());
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: AuthInputField(
              controller: _passwordController,
              labelText: 'Password',
              type: AuthInputFieldType.password,
              validator: AuthPasswordValidator.validate,
              enabled: !isLoading,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: AuthInputField(
              controller: _confirmPasswordController,
              labelText: 'Confirm Password',
              type: AuthInputFieldType.password,
              prefixAsset: AppAssets.iconLock,
              validator: (value) => AuthPasswordValidator.validateConfirmation(
                value,
                _passwordController.text,
              ),
              enabled: !isLoading,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: AuthActionButton(
              label: 'REGISTER',
              isLoading: isLoading,
              isEnabled: _hasRequiredInput && !isLoading,
              onPressed: _submitForm,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: AuthFooterLinkRow(
              prompt: 'Already have an account?',
              actionLabel: 'Login',
              onTap: () => context.go(Constants.loginRoute),
            ),
          ),
        ],
      ),
    );
  }
}
