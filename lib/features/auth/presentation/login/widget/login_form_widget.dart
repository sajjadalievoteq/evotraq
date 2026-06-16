import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/constants.dart';
import 'package:traqtrace_app/core/storage/recent_login_usernames_store.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/data/models/auth/auth_models.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/features/auth/presentation/widget/auth_action_button.dart';
import 'package:traqtrace_app/features/auth/presentation/widget/auth_input_field.dart';
import 'package:traqtrace_app/core/widgets/custom_text_button_widget.dart';

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

  Iterable<String> _usernameSuggestions(String query) {
    if (_recentUsernames.isEmpty) return const Iterable<String>.empty();

    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return _recentUsernames;

    return _recentUsernames.where(
      (username) => username.toLowerCase().contains(normalizedQuery),
    );
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

  AuthInputField _buildUsernameInput({
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isLoading,
  }) {
    return AuthInputField(
      controller: controller,
      focusNode: focusNode,
      labelText: 'Username or Email',
      hintText: 'Enter username or email',
      helperText: 'Use your username or email to log in',
      type: AuthInputFieldType.username,
      enabled: !isLoading,
      textInputAction: TextInputAction.next,
      onChanged: (_) => _updateButtonState(),
      validator: (value) {
        if ((value?.trim() ?? '').isEmpty) {
          return 'Username or email is required';
        }
        return null;
      },
    );
  }

  Widget _buildUsernameField({required bool isLoading}) {
    if (_recentUsernames.isEmpty) {
      return _buildUsernameInput(
        controller: _usernameController,
        focusNode: _usernameFocusNode,
        isLoading: isLoading,
      );
    }

    final c = context.colors;

    return RawAutocomplete<String>(
      textEditingController: _usernameController,
      focusNode: _usernameFocusNode,
      displayStringForOption: (option) => option,
      optionsBuilder: (value) => _usernameSuggestions(value.text),
      onSelected: (selection) {
        _usernameController
          ..text = selection
          ..selection = TextSelection.collapsed(offset: selection.length);
        _updateButtonState();
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return _buildUsernameInput(
          controller: controller,
          focusNode: focusNode,
          isLoading: isLoading,
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            color: c.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: c.border),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200, minWidth: 280),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                separatorBuilder: (_, __) => Divider(height: 1, color: c.border),
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    title: Text(
                      option,
                      style: TextStyle(color: c.textPrimary),
                    ),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = widget.state.status == AuthStatus.loading;
    final c = context.colors;
    final t = context.text;
    return Form(
      key: _formKey,
      onChanged: _updateButtonState,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildUsernameField(isLoading: isLoading),
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
        ],
      ),
    );
  }
}
