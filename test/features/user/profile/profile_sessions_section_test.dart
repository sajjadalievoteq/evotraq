import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/data/models/auth/user_session.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/user/cubit/profile_state.dart';
import 'package:traqtrace_app/features/user/screens/profile/widgets/profile_sessions_section.dart';

Widget _host(Widget child) => MaterialApp(
  theme: TraqTheme.light(),
  home: Scaffold(body: child),
);

ProfileSessionsSection _section({
  required ProfileState state,
  VoidCallback? onRetry,
  ValueChanged<UserSession>? onSignOutSession,
}) {
  return ProfileSessionsSection(
    state: state,
    onRetry: onRetry ?? () {},
    onSignOutSession: onSignOutSession ?? (_) {},
    onLogOutCurrent: () {},
    onSignOutOtherDevices: () {},
  );
}

void main() {
  testWidgets('sessions section preserves loading state', (tester) async {
    await tester.pumpWidget(_host(_section(state: const ProfileState())));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('sessions section preserves error and retry behavior', (
    tester,
  ) async {
    var retries = 0;
    await tester.pumpWidget(
      _host(
        _section(
          state: const ProfileState(
            sessionsStatus: SessionsStatus.error,
            sessionsError: 'Unable to load sessions',
          ),
          onRetry: () => retries++,
        ),
      ),
    );

    expect(find.text('Unable to load sessions'), findsOneWidget);
    await tester.tap(find.byType(TextButton));
    expect(retries, 1);
  });

  testWidgets('session tile delegates sign-out for another device', (
    tester,
  ) async {
    final now = DateTime(2026, 8, 11);
    final session = UserSession(
      id: 'session-1',
      device: 'Chrome on Windows',
      lastSeenAt: now,
      createdAt: now,
      current: false,
    );
    UserSession? signedOut;

    await tester.pumpWidget(
      _host(
        _section(
          state: ProfileState(
            sessionsStatus: SessionsStatus.success,
            sessions: [session],
          ),
          onSignOutSession: (value) => signedOut = value,
        ),
      ),
    );

    expect(find.text('Chrome on Windows'), findsOneWidget);
    await tester.tap(find.text('Sign out'));
    expect(signedOut, same(session));
  });
}
