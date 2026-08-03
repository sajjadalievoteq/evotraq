import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_cubit.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_state.dart';
import 'package:traqtrace_app/features/automation_center/screens/notification_center/widgets/notification_center_embedded_body.dart';
import 'package:traqtrace_app/features/automation_center/screens/notification_center/widgets/notification_center_standalone_scaffold.dart';

/// Aggregate delivery activity for subscriptions (not a per-event inbox).
class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  NotificationCenterScreenState createState() =>
      NotificationCenterScreenState();
}

class NotificationCenterScreenState extends State<NotificationCenterScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    context.read<NotificationCubit>().loadSubscriptions();
  }

  @override
  void dispose() {
    final cubit = context.read<NotificationCubit>();
    if (cubit.isWebSocketConnected) {
      cubit.disconnectWebSocket();
    }
    super.dispose();
  }

  bool _isLive(NotificationState state) {
    return state.status == NotificationStatus.webSocketConnected ||
        context.read<NotificationCubit>().isWebSocketConnected;
  }

  void refresh() {
    context.read<NotificationCubit>().loadSubscriptions(force: true);
  }

  void toggleLive() {
    final live = _isLive(context.read<NotificationCubit>().state);
    _toggleWebSocketConnection(live);
  }

  void goManageSubscriptions() {
    context.go('/notifications/subscriptions');
  }

  bool get isLive => _isLive(context.read<NotificationCubit>().state);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotificationCubit, NotificationState>(
      listenWhen: (prev, next) =>
          prev.status != next.status &&
          (next.status == NotificationStatus.webSocketConnected ||
              next.status == NotificationStatus.webSocketDisconnected ||
              next.status == NotificationStatus.error),
      listener: (context, state) {
        if (state.status == NotificationStatus.error && state.error != null) {
          context.showError(state.error!);
        }
      },
      builder: (context, state) {
        final live = _isLive(state);
        if (widget.embedded) {
          return NotificationCenterEmbeddedBody(
            state: state,
            live: live,
            selectedFilter: _selectedFilter,
            onFilterSelected: (filter) =>
                setState(() => _selectedFilter = filter),
            onRefresh: refresh,
            onClearFilters: () => setState(() => _selectedFilter = 'all'),
            onPrimaryAction: goManageSubscriptions,
          );
        }
        return NotificationCenterStandaloneScaffold(
          state: state,
          live: live,
          selectedFilter: _selectedFilter,
          onFilterSelected: (filter) =>
              setState(() => _selectedFilter = filter),
          onToggleLive: () => _toggleWebSocketConnection(live),
          onManageSubscriptions: goManageSubscriptions,
          onRefresh: refresh,
          onClearFilters: () => setState(() => _selectedFilter = 'all'),
        );
      },
    );
  }

  void _toggleWebSocketConnection(bool currentlyLive) {
    final cubit = context.read<NotificationCubit>();
    try {
      if (currentlyLive) {
        cubit.disconnectWebSocket();
        context.showInfo('Disconnected from real-time updates');
      } else {
        cubit.connectWebSocket();
        context.showInfo('Connecting to real-time updates…');
      }
    } catch (e) {
      context.showError('Connection error: $e');
    }
  }
}
