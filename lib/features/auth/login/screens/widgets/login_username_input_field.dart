import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_input_field.dart';

class LoginUsernameInputField extends StatelessWidget {
  const LoginUsernameInputField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isLoading,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isLoading;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return AuthInputField(
      controller: controller,
      focusNode: focusNode,
      labelText: 'Username or Email',
      hintText: 'Enter username or email',
      helperText: 'Use your username or email to log in',
      type: AuthInputFieldType.username,
      enabled: !isLoading,
      textInputAction: TextInputAction.next,
      onChanged: (_) => onChanged(),
      validator: (value) {
        if ((value?.trim() ?? '').isEmpty) {
          return 'Username or email is required';
        }
        return null;
      },
    );
  }
}
