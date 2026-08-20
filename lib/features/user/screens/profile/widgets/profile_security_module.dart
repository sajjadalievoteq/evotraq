import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/features/auth/widgets/logout_confirm_dialog.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_input_field.dart';
import 'package:traqtrace_app/features/auth/widgets/input/auth_input_field_type.dart';
import 'package:traqtrace_app/features/user/cubit/profile_cubit.dart';
import 'package:traqtrace_app/features/user/cubit/profile_state.dart';
import 'package:traqtrace_app/features/user/utils/user_strings.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_presenter.dart';
import 'package:traqtrace_app/core/widgets/custom_elevated_button.dart';
import 'package:traqtrace_app/data/models/auth/user_session.dart';
import 'package:traqtrace_app/features/user/screens/profile/widgets/profile_sessions_section.dart';

class ProfileSecurityModule extends StatefulWidget {
  const ProfileSecurityModule({super.key});

  @override
  State<ProfileSecurityModule> createState() => _ProfileSecurityModuleState();
}

class _ProfileSecurityModuleState extends State<ProfileSecurityModule> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cubit = context.read<ProfileCubit>();
      if (cubit.state.sessionsStatus == SessionsStatus.initial) {
        cubit.loadSessions();
      }
    });
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _changePassword() {
    if (_formKey.currentState!.validate()) {
      context.read<ProfileCubit>().changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );
    }
  }

  void _clearPasswordFields() {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  Future<void> _signOutSession(UserSession session) async {
    final ok = await context.read<ProfileCubit>().revokeSession(session.id);
    if (!mounted) return;
    if (ok) {
      context.showSuccess(UserStrings.sessionSignedOut);
    } else {
      final error = context.read<ProfileCubit>().state.sessionsError;
      context.showError(error ?? UserStrings.genericError);
    }
  }

  Future<void> _signOutOtherDevices() async {
    final ok = await context.read<ProfileCubit>().revokeOtherSessions();
    if (!mounted) return;
    if (ok) {
      context.showSuccess(UserStrings.otherSessionsSignedOut);
    } else {
      final error = context.read<ProfileCubit>().state.sessionsError;
      context.showError(error ?? UserStrings.genericError);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state.status == ProfileStatus.error) {
          context.showError(state.error ?? UserStrings.genericError);
        } else if (state.status == ProfileStatus.passwordChanged) {
          context.showSuccess(UserStrings.passwordChangedSuccessfully);
          _clearPasswordFields();
        }
      },
      builder: (context, state) {
        final isLoading = state.isChangingPassword;

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                UserStrings.changePasswordTitle,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                UserStrings.passwordHelpText,
                style: TextStyle(color: context.colors.textMuted),
              ),
              const SizedBox(height: 24),
              AuthInputField(
                controller: _currentPasswordController,
                labelText: UserStrings.currentPasswordLabel,
                type: AuthInputFieldType.password,
                enabled: !isLoading,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return UserStrings.enterCurrentPassword;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AuthInputField(
                controller: _newPasswordController,
                labelText: UserStrings.newPasswordLabel,
                type: AuthInputFieldType.password,
                enabled: !isLoading,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return UserStrings.enterNewPassword;
                  }
                  if (value.length < 12) {
                    return UserStrings.passwordAtLeast8Chars;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AuthInputField(
                controller: _confirmPasswordController,
                labelText: UserStrings.confirmNewPasswordLabel,
                type: AuthInputFieldType.password,
                enabled: !isLoading,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return UserStrings.confirmNewPassword;
                  }
                  if (value != _newPasswordController.text) {
                    return UserStrings.passwordsDoNotMatch;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              CustomElevatedButton(
                label: UserStrings.changePasswordButton,
                onPressed: _changePassword,
                isLoading: isLoading,
                isEnabled: !isLoading,
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                UserStrings.sessionsTitle,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                UserStrings.sessionsSubtitle,
                style: TextStyle(color: context.colors.textMuted),
              ),
              const SizedBox(height: 16),
              ProfileSessionsSection(
                state: state,
                onRetry: () => context.read<ProfileCubit>().loadSessions(),
                onSignOutSession: _signOutSession,
                onLogOutCurrent: () => showLogoutConfirmDialog(context),
                onSignOutOtherDevices: _signOutOtherDevices,
              ),
            ],
          ),
        );
      },
    );
  }
}
