import 'package:traqtrace_app/core/animation/traq_staggered_entrance_widget.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/widgets/custom_text_button_widget.dart';
import 'package:traqtrace_app/data/models/auth/login_request.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/features/auth/screens/login/widgets/login_username_input_field.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_action_button.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_footer_link_row.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_input_field.dart';
import 'package:traqtrace_app/features/auth/widgets/input/auth_input_field_type.dart';

class LoginFormWidget extends StatefulWidget {
  const LoginFormWidget({super.key, required this.state});

  final AuthState state;

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _usernameFocusNode = FocusNode();
  final _passwordController = TextEditingController();
  bool _hasRequiredInput = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _usernameFocusNode.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text.trim();
      final loginRequest = LoginRequest(
        username: username,
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
    final isLoading = widget.state.status == AuthStatus.loading;

    return Form(
      key: _formKey,
      onChanged: _updateButtonState,
      child: TraqStaggeredEntrance(
        children: [
          LoginUsernameInputField(
            controller: _usernameController,
            focusNode: _usernameFocusNode,
            isLoading: isLoading,
            onChanged: _updateButtonState,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: AuthInputField(
              controller: _passwordController,
              labelText: 'Password',
              type: AuthInputFieldType.password,
              enabled: !isLoading,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submitForm(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: CustomTextButtonWidget(
                title: 'Forgot Password?',
                onTap: () {
                  context.go(Constants.forgotPasswordRoute);
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: AuthActionButton(
              label: 'LOGIN',
              isLoading: isLoading,
              isEnabled: _hasRequiredInput && !isLoading,
              onPressed: _submitForm,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: AuthFooterLinkRow(
              prompt: "Don't have an account?",
              actionLabel: 'Register',
              onTap: () => context.go(Constants.registerRoute),
            ),
          ),
        ],
      ),
    );
  }
}
