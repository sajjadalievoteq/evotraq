import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_cubit.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_state.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_card.dart';
import 'package:traqtrace_app/features/automation_center/widgets/create_subscription_dialog.dart';
import 'package:traqtrace_app/features/automation_center/screens/notification_list/widgets/notification_list_empty_state.dart';
import 'package:traqtrace_app/features/automation_center/screens/notification_list/widgets/notification_list_error_state.dart';

import 'package:traqtrace_app/data/models/notifications/realtime_notification.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationCubit>().loadSubscriptions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Subscriptions'),
        actions: [
          IconButton(
            icon: TraqIcon(AppAssets.iconPlus),
            onPressed: () => _showCreateDialog(context),
          ),
          BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              if (state.status == NotificationStatus.webSocketConnected) {
                return TraqIcon(
                  AppAssets.iconWifi,
                  color: AppColorMapper.successColor(context),
                );
              } else if (state.status ==
                  NotificationStatus.webSocketDisconnected) {
                return TraqIcon(
                  AppAssets.iconWifiOff,
                  color: AppColorMapper.errorColor(context),
                );
              }
              return TraqIcon(
                AppAssets.iconWifiOff,
                color: context.colors.textMuted,
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: BlocConsumer<NotificationCubit, NotificationState>(
        listener: (context, state) {
          if (state.status == NotificationStatus.error &&
              state.error != null) {
            context.showError(state.error!);
          } else if (state.status == NotificationStatus.subscriptionCreated) {
            context.showSuccess('Subscription created successfully');
          } else if (state.status == NotificationStatus.subscriptionDeleted) {
            context.showSuccess('Subscription deleted successfully');
          } else if (state.lastRealtimeNotification != null) {
            _showRealtimeNotification(context, state.lastRealtimeNotification!);
          }
        },
        builder: (context, state) {
          if (state.status == NotificationStatus.loading &&
              state.subscriptions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == NotificationStatus.success ||
              state.status == NotificationStatus.loading ||
              state.status == NotificationStatus.subscriptionCreated ||
              state.status == NotificationStatus.subscriptionDeleted ||
              state.status == NotificationStatus.subscriptionUpdated) {
            if (state.subscriptions.isEmpty &&
                state.status != NotificationStatus.loading) {
              return NotificationListEmptyState(
                onCreate: () => _showCreateDialog(context),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<NotificationCubit>().loadSubscriptions();
              },
              child: ListView.builder(
                itemCount: state.subscriptions.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: SubscriptionCard(
                      subscription: state.subscriptions[index],
                      onEdit: (subscription) => _showEditDialog(
                        context,
                        subscription,
                      ),
                      onDelete: (subscription) => _showDeleteDialog(
                        context,
                        subscription,
                      ),
                      onPause: (subscription) => context
                          .read<NotificationCubit>()
                          .pauseSubscription(subscription.id),
                      onResume: (subscription) => context
                          .read<NotificationCubit>()
                          .resumeSubscription(subscription.id),
                      onViewDetails: (subscription) => context.push(
                        '/notifications/${subscription.id}',
                      ),
                    ),
                  );
                },
              ),
            );
          }

          if (state.status == NotificationStatus.error &&
              state.subscriptions.isEmpty) {
            return NotificationListErrorState(
              message: state.error ?? 'Unknown error',
              onRetry: () {
                context.read<NotificationCubit>().loadSubscriptions();
              },
            );
          }

          return NotificationListEmptyState(
            onCreate: () => _showCreateDialog(context),
          );
        },
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<NotificationCubit>(),
        child: const CreateSubscriptionDialog(),
      ),
    );
  }

  void _showEditDialog(BuildContext context, subscription) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<NotificationCubit>(),
        child: CreateSubscriptionDialog(subscription: subscription),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, subscription) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Subscription'),
        content: Text(
          'Are you sure you want to delete "${subscription.subscriptionName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context
                  .read<NotificationCubit>()
                  .deleteSubscription(subscription.id);
              Navigator.of(dialogContext).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorMapper.errorColor(context),
              foregroundColor: context.colors.textOnInverse,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showRealtimeNotification(
    BuildContext context,
    RealtimeNotification notification,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Real-time Notification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Event: ${notification.eventType}'),
            Text('Time: ${notification.timestamp}'),
            Text('Source: ${notification.source}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
