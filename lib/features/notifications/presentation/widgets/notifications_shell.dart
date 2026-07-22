import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/services/notification_api_service.dart';
import 'package:traqtrace_app/data/services/websocket_service.dart';
import 'package:traqtrace_app/features/notifications/presentation/cubit/notification_cubit.dart';

/// Provides [NotificationCubit] for the notifications feature route subtree.
///
/// Lifetime matches the go_router [ShellRoute] session: the cubit persists
/// across intra-feature navigation and is disposed when leaving the feature.
class NotificationsShell extends StatelessWidget {
  const NotificationsShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NotificationCubit>(
      create: (context) => NotificationCubit(
        apiService: getIt<NotificationApiService>(),
        webSocketService: getIt<WebSocketService>(),
      ),
      child: child,
    );
  }
}
