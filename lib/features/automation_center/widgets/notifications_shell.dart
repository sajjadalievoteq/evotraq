import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/services/automation_center/notification_api_service.dart';
import 'package:traqtrace_app/data/services/websocket_service.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_cubit.dart';

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