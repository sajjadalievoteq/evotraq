import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_presenter.dart';
import 'package:traqtrace_app/data/models/user_management/user_management_models.dart';
import 'package:traqtrace_app/data/services/user_management/user_management_service.dart';
import 'package:traqtrace_app/features/automation_center/widgets/inbound/system_user_form_field.dart';

class CreatedSystemCredentials {
  const CreatedSystemCredentials({
    required this.username,
    required this.password,
  });

  final String username;
  final String password;
}

class CreateSystemUserDialog extends StatefulWidget {
  const CreateSystemUserDialog({super.key, required this.service});

  final UserManagementService service;

  static Future<CreatedSystemCredentials?> show(
    BuildContext context, {
    required UserManagementService service,
  }) => showDialog<CreatedSystemCredentials>(
    context: context,
    barrierDismissible: false,
    builder: (_) => CreateSystemUserDialog(service: service),
  );

  @override
  State<CreateSystemUserDialog> createState() => _CreateSystemUserDialogState();
}

class _CreateSystemUserDialogState extends State<CreateSystemUserDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _obscurePassword = true;
  bool _saving = false;

  String _generatePassword() {
    const alphabet =
        'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@#%_-';
    final random = Random.secure();
    return List.generate(
      20,
      (_) => alphabet[random.nextInt(alphabet.length)],
    ).join();
  }

  void _generate() {
    final password = _generatePassword();
    _formKey.currentState?.fields['password']?.didChange(password);
    setState(() => _obscurePassword = false);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;
    final values = _formKey.currentState!.value;
    setState(() => _saving = true);
    try {
      final password = values['password'] as String;
      await widget.service.createUser(
        CreateUserRequest(
          username: values['username'] as String,
          email: values['email'] as String,
          password: password,
          firstName: values['firstName'] as String,
          lastName: values['lastName'] as String,
          role: 'B2B_SERVICE',
          partyGln: values['partyGln'] as String?,
          enabled: true,
        ),
      );
      if (mounted) {
        Navigator.of(context).pop(
          CreatedSystemCredentials(
            username: values['username'] as String,
            password: password,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        context.showError(error.toString().replaceFirst('Exception: ', ''));
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create B2B Service User'),
      content: SizedBox(
        width: 560,
        child: FormBuilder(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SystemUserFormField(
                  name: 'username',
                  label: 'Username',
                  validators: [
                    FormBuilderValidators.required(),
                    FormBuilderValidators.minLength(3),
                    FormBuilderValidators.maxLength(50),
                  ],
                ),
                SystemUserFormField(
                  name: 'email',
                  label: 'Email',
                  validators: [
                    FormBuilderValidators.required(),
                    FormBuilderValidators.email(),
                  ],
                  keyboardType: TextInputType.emailAddress,
                ),
                Row(
                  children: [
                    const Expanded(
                      child: SystemUserFormField(
                        name: 'firstName',
                        label: 'First name',
                      ),
                    ),
                    const SizedBox(width: TraqSpacing.md),
                    const Expanded(
                      child: SystemUserFormField(
                        name: 'lastName',
                        label: 'Last name',
                      ),
                    ),
                  ],
                ),
                FormBuilderTextField(
                  name: 'password',
                  obscureText: _obscurePassword,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.minLength(12),
                  ]),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      tooltip: _obscurePassword
                          ? 'Show password'
                          : 'Hide password',
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _generate,
                    icon: const Icon(Icons.password),
                    label: const Text('Generate strong password'),
                  ),
                ),
                SystemUserFormField(
                  name: 'partyGln',
                  label: 'Party GLN (optional)',
                  validators: [
                    // Only enforce the 13-digit pattern once something has
                    // actually been typed - FormBuilderValidators.match runs
                    // the regex unconditionally, so leaving this field blank
                    // (it's optional) was incorrectly failing validation.
                    (value) {
                      if (value == null || value.isEmpty) return null;
                      return RegExp(r'^\d{13}$').hasMatch(value)
                          ? null
                          : 'Party GLN must contain exactly 13 digits';
                    },
                  ],
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create B2B Service User'),
        ),
      ],
    );
  }
}
