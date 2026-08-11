import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/data/models/auth/user_session.dart';
import 'package:traqtrace_app/features/user/cubit/profile_state.dart';
import 'package:traqtrace_app/features/user/screens/profile/widgets/profile_session_tile.dart';
import 'package:traqtrace_app/features/user/utils/user_strings.dart';

class ProfileSessionsSection extends StatelessWidget {
  const ProfileSessionsSection({
    super.key,
    required this.state,
    required this.onRetry,
    required this.onSignOutSession,
    required this.onLogOutCurrent,
    required this.onSignOutOtherDevices,
  });

  final ProfileState state;
  final VoidCallback onRetry;
  final ValueChanged<UserSession> onSignOutSession;
  final VoidCallback onLogOutCurrent;
  final VoidCallback onSignOutOtherDevices;

  @override
  Widget build(BuildContext context) {
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
            onPressed: onRetry,
            child: const Text(UserStrings.sessionsRetry),
          ),
        ],
      );
    }

    final hasOtherSessions = state.sessions.any((session) => !session.current);
    final busy = state.isRevokingSession || state.isRevokingOtherSessions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final session in state.sessions) ...[
          ProfileSessionTile(
            session: session,
            busy: busy,
            onSignOutSession: () => onSignOutSession(session),
            onLogOutCurrent: onLogOutCurrent,
          ),
          const SizedBox(height: 4),
        ],
        if (hasOtherSessions) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: busy ? null : onSignOutOtherDevices,
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
