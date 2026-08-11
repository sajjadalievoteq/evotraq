import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/relative_time_utils.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/auth/user_session.dart';
import 'package:traqtrace_app/features/user/utils/user_strings.dart';

class ProfileSessionTile extends StatelessWidget {
  const ProfileSessionTile({
    super.key,
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
