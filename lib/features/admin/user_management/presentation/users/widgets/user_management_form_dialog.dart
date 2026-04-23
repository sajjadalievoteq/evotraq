import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/user_management/user_management_models.dart';
import 'package:traqtrace_app/shared/widgets/custom_text_button_widget.dart';

import 'user_management_constants.dart';
import 'user_management_input_field.dart';

class UserManagementFormResult {
  UserManagementFormResult.create({
    required CreateUserRequest createUserRequest,
  })  : createRequest = createUserRequest,
        updateRequest = null,
        selectedRole = createUserRequest.role;

  UserManagementFormResult.edit({
    required UpdateUserRequest userUpdateRequest,
    required this.selectedRole,
  })  : createRequest = null,
        updateRequest = userUpdateRequest;

  final CreateUserRequest? createRequest;
  final UpdateUserRequest? updateRequest;
  final String selectedRole;
}

class UserManagementFormDialog extends StatefulWidget {
  const UserManagementFormDialog({
    super.key,
    this.user,
  });

  final UserResponse? user;

  bool get isEditing => user != null;

  @override
  State<UserManagementFormDialog> createState() =>
      _UserManagementFormDialogState();
}

class _UserManagementFormDialogState extends State<UserManagementFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _usernameController;
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  late String _selectedRole;
  bool _enabled = true;

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    _usernameController = TextEditingController(text: user?.username ?? '');
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _passwordController = TextEditingController();
    _selectedRole = user?.role ?? UserManagementConstants.defaultRole;
    _enabled = user?.enabled ?? true;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (widget.isEditing) {
      Navigator.of(context).pop(
        UserManagementFormResult.edit(
          userUpdateRequest: UpdateUserRequest(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text.trim().isEmpty
                ? null
                : _passwordController.text.trim(),
          ),
          selectedRole: _selectedRole,
        ),
      );
      return;
    }

    Navigator.of(context).pop(
      UserManagementFormResult.create(
        createUserRequest: CreateUserRequest(
          username: _usernameController.text.trim(),
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          role: _selectedRole,
          enabled: _enabled,
        ),
      ),
    );
  }

  double _fieldWidth(double maxWidth, {bool fullWidth = false}) {
    if (maxWidth < 560 || fullWidth) {
      return maxWidth;
    }
    return (maxWidth - UserManagementConstants.spacing) / 2;
  }

  String get _title =>
      widget.isEditing ? 'Edit User: ${widget.user!.username}' : 'Add New User';

  String get _submitLabel => widget.isEditing ? 'Save' : 'Create';

  @override
  Widget build(BuildContext context) {
    final dialogWidth = MediaQuery.sizeOf(context).width * 0.9;

    return AlertDialog(
      title: Text(_title),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth.clamp(
            320.0,
            UserManagementConstants.dialogMaxWidth,
          ),
        ),
        child: SingleChildScrollView(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;

              return Form(
                key: _formKey,
                child: Wrap(
                  spacing: UserManagementConstants.spacing,
                  runSpacing: UserManagementConstants.spacing,
                  children: [
                    if (!widget.isEditing)
                      SizedBox(
                        width: _fieldWidth(maxWidth),
                        child: UserManagementInputField(
                          controller: _usernameController,
                          label: 'Username',
                          validator: _validateUsername,
                        ),
                      ),
                    SizedBox(
                      width: _fieldWidth(maxWidth),
                      child: UserManagementInputField(
                        controller: _firstNameController,
                        label: 'First Name',
                        validator: _validateRequired('Please enter first name'),
                      ),
                    ),
                    SizedBox(
                      width: _fieldWidth(maxWidth),
                      child: UserManagementInputField(
                        controller: _lastNameController,
                        label: 'Last Name',
                        validator: _validateRequired('Please enter last name'),
                      ),
                    ),
                    SizedBox(
                      width: _fieldWidth(maxWidth, fullWidth: maxWidth < 560),
                      child: UserManagementInputField(
                        controller: _emailController,
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                      ),
                    ),
                    SizedBox(
                      width: _fieldWidth(maxWidth, fullWidth: maxWidth < 560),
                      child: UserManagementInputField(
                        controller: _passwordController,
                        label: widget.isEditing
                            ? 'Password (leave blank to keep unchanged)'
                            : 'Password',
                        obscureText: true,
                        validator: widget.isEditing
                            ? _validateOptionalPassword
                            : _validateRequiredPassword,
                      ),
                    ),
                    SizedBox(
                      width: _fieldWidth(maxWidth, fullWidth: maxWidth < 560),
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedRole,
                        decoration: const InputDecoration(
                          labelText: 'Role',
                          border: OutlineInputBorder(),
                        ),
                        items: UserManagementConstants.assignableRoles
                            .map(
                              (role) => DropdownMenuItem<String>(
                                value: role,
                                child: Text(role),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _selectedRole = value);
                        },
                      ),
                    ),
                    if (!widget.isEditing)
                      SizedBox(
                        width: maxWidth,
                        child: SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Account Active'),
                          value: _enabled,
                          onChanged: (value) {
                            setState(() => _enabled = value);
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      actions: [
        CustomTextButtonWidget(
          title: 'Cancel',
          onTap: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(_submitLabel),
        ),
      ],
    );
  }

  String? Function(String? value) _validateRequired(String message) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return message;
      }
      return null;
    };
  }

  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter username';
    }
    if (value.trim().length < 4) {
      return 'Username must be at least 4 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter email';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validateRequiredPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  String? _validateOptionalPassword(String? value) {
    if (value != null && value.isNotEmpty && value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }
}
