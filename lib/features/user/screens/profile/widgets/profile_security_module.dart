import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/relative_time_utils.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/features/auth/widgets/logout_confirm_dialog.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_input_field.dart';
import 'package:traqtrace_app/features/auth/widgets/input/auth_input_field_type.dart';
import 'package:traqtrace_app/features/user/cubit/profile_cubit.dart';
import 'package:traqtrace_app/features/user/cubit/profile_state.dart';
import 'package:traqtrace_app/features/user/utils/user_strings.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/widgets/custom_elevated_button.dart';
import 'package:traqtrace_app/data/models/auth/user_session.dart';

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
                  if (value.length < 8) {
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
              _buildSessionsSection(state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSessionsSection(ProfileState state) {
    if (state.sessionsStatus == SessionsStatus.loading ||
        state.sessionsStatus == SessionsStatus.initial) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.sessionsStatus == SessionsStatus.error) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            state.sessionsError ?? UserStrings.sessionsLoadError,
            style: TextStyle(color: context.colors.textMuted),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.read<ProfileCubit>().loadSessions(),
            child: const Text(UserStrings.sessionsRetry),
          ),
        ],
      );
    }

    final sessions = state.sessions;
    final hasOtherSessions = sessions.any((s) => !s.current);
    final busy = state.isRevokingSession || state.isRevokingOtherSessions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final session in sessions) ...[
          _SessionTile(
            session: session,
            busy: busy,
            onSignOutSession: () => _signOutSession(session),
            onLogOutCurrent: () => showLogoutConfirmDialog(context),
          ),
          const SizedBox(height: 4),
        ],
        if (hasOtherSessions) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: busy ? null : _signOutOtherDevices,
            child: state.isRevokingOtherSessions
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(UserStrings.signOutOtherDevices),
          ),
        ],
      ],
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({
    required this.session,
    required this.busy,
    required this.onSignOutSession,
    required this.onLogOutCurrent,
  });

  final UserSession session;
  final bool busy;
  final VoidCallback onSignOutSession;
  final VoidCallback onLogOutCurrent;

  @override
  Widget build(BuildContext context) {
    final lastActive =
        '${UserStrings.sessionActivePrefix}${RelativeTimeUtils.compactAgo(session.lastSeenAt)}';
    final ip = session.ipAddress?.trim();
    final subtitleParts = <String>[
      if (session.current) UserStrings.currentSessionBadge,
      lastActive,
      if (ip != null && ip.isNotEmpty) ip,
    ];

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: context.colors.primary,
        child: const TraqIcon(AppAssets.iconComputer, color: Colors.white),
      ),
      title: Text(
        session.current ? UserStrings.currentSessionTitle : session.device,
      ),
      subtitle: Text(subtitleParts.join(' • ')),
      trailing: session.current
          ? TextButton(
              onPressed: busy ? null : onLogOutCurrent,
              child: const Text(UserStrings.logOut),
            )
          : TextButton(
              onPressed: busy ? null : onSignOutSession,
              child: const Text(UserStrings.signOutSession),
            ),
    );
  }
}
