import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/constants.dart';
import 'package:traqtrace_app/core/storage/recent_login_usernames_store.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/data/models/auth/auth_models.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/features/auth/login/screens/widgets/login_username_autocomplete_field.dart';
import 'package:traqtrace_app/features/auth/login/screens/widgets/login_username_input_field.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_action_button.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_input_field.dart';
import 'package:traqtrace_app/core/widgets/custom_text_button_widget.dart';
import 'package:traqtrace_app/core/animation/traq_staggered_entrance.dart';

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
  final _usernameStore = const RecentLoginUsernamesStore();
  bool _hasRequiredInput = false;
  List<String> _recentUsernames = [];

  @override
  void initState() {
    super.initState();
    _loadRecentUsernames();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _usernameFocusNode.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentUsernames() async {
    final usernames = await _usernameStore.getUsernames();
    if (!mounted) return;

    setState(() => _recentUsernames = usernames);

    if (usernames.isNotEmpty) {
      _usernameController.text = usernames.first;
      _updateButtonState();
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text.trim();
      final loginRequest = LoginRequest(
        username: username,
        password: _passwordController.text,
      );

      _usernameStore.rememberUsername(username);
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
    final c = context.colors;
    final t = context.text;

    final usernameField = _recentUsernames.isEmpty
        ? LoginUsernameInputField(
            controller: _usernameController,
            focusNode: _usernameFocusNode,
            isLoading: isLoading,
            onChanged: _updateButtonState,
          )
        : LoginUsernameAutocompleteField(
            controller: _usernameController,
            focusNode: _usernameFocusNode,
            isLoading: isLoading,
            recentUsernames: _recentUsernames,
            onChanged: _updateButtonState,
          );

    return Form(
      key: _formKey,
      onChanged: _updateButtonState,
      child: TraqStaggeredEntrance(
        children: [
          usernameField,
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Don\'t have an account?',
                  style: t.body.copyWith(color: c.textPrimary),
                ),
                CustomTextButtonWidget(
                  title: 'Register',
                  onTap: () {
                    context.go(Constants.registerRoute);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
