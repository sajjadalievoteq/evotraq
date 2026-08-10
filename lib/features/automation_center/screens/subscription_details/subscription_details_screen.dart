import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_cubit.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_state.dart';
import 'package:traqtrace_app/data/models/automation_center/notification_subscription.dart';
import 'package:traqtrace_app/features/automation_center/widgets/create_subscription_dialog.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/features/automation_center/screens/automation_center/utils/automation_center_sections.dart';
import 'package:traqtrace_app/features/automation_center/screens/subscription_details/widgets/subscription_details_body.dart';
import 'package:traqtrace_app/features/automation_center/screens/subscription_details/widgets/subscription_not_found.dart';
import 'package:traqtrace_app/features/automation_center/widgets/confirm_delete_subscription_dialog.dart';

class SubscriptionDetailsScreen extends StatefulWidget {
  final String subscriptionId;

  const SubscriptionDetailsScreen({super.key, required this.subscriptionId});

  @override
  State<SubscriptionDetailsScreen> createState() =>
      _SubscriptionDetailsScreenState();
}

class _SubscriptionDetailsScreenState extends State<SubscriptionDetailsScreen> {
  @override
  void initState() {
    super.initState();
    _loadSubscription();
  }

  void _loadSubscription() {
    final cubit = context.read<NotificationCubit>();
    cubit.loadSubscription(widget.subscriptionId);
    cubit.loadSubscriptionStats(widget.subscriptionId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        final subscription = state.selectedSubscription;
        final isLoading =
            state.status == NotificationStatus.loading && subscription == null;
        final stats =
            state.lastLoadedStatsSubscriptionId == widget.subscriptionId
            ? state.lastLoadedStats
            : null;

        return Scaffold(
          appBar: AppBar(
            title: Text(subscription?.subscriptionName ?? 'Subscription'),
            actions: [
              if (subscription != null) ...[
                IconButton(
                  icon: TraqIcon(AppAssets.iconEdit),
                  onPressed: () => _editSubscription(subscription),
                  tooltip: 'Edit Subscription',
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'pause':
                        _pauseSubscription();
                        break;
                      case 'resume':
                        _resumeSubscription();
                        break;
                      case 'delete':
                        _deleteSubscription(subscription);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    if (subscription.status == 'ACTIVE')
                      const PopupMenuItem(
                        value: 'pause',
                        child: Row(
                          children: [
                            TraqIcon(AppAssets.iconMinus),
                            SizedBox(width: 8),
                            Text('Pause'),
                          ],
                        ),
                      ),
                    if (subscription.status == 'PAUSED')
                      const PopupMenuItem(
                        value: 'resume',
                        child: Row(
                          children: [
                            TraqIcon(AppAssets.iconArrowR),
                            SizedBox(width: 8),
                            Text('Resume'),
                          ],
                        ),
                      ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          TraqIcon(
                            AppAssets.iconTrash,
                            color: AppColorMapper.errorColor(context),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Delete',
                            style: TextStyle(
                              color: AppColorMapper.errorColor(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          drawer: const AppDrawer(),
          body: BlocListener<NotificationCubit, NotificationState>(
            listener: (context, state) {
              if (state.status == NotificationStatus.error &&
                  state.error != null) {
                context.showError(state.error!);
              }
            },
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : subscription == null
                ? const SubscriptionNotFound()
                : SubscriptionDetailsBody(
                    subscription: subscription,
                    stats: stats,
                  ),
          ),
        );
      },
    );
  }

  void _editSubscription(NotificationSubscription subscription) {
    final cubit = context.read<NotificationCubit>();
    showDialog<bool>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: CreateSubscriptionDialog(subscription: subscription),
      ),
    ).then((changed) {
      if (changed == true) {
        _loadSubscription();
      }
    });
  }

  void _pauseSubscription() {
    context.read<NotificationCubit>().pauseSubscription(widget.subscriptionId);
    context.showInfo('Subscription paused');
  }

  void _resumeSubscription() {
    context.read<NotificationCubit>().resumeSubscription(widget.subscriptionId);
    context.showInfo('Subscription resumed');
  }

  Future<void> _deleteSubscription(
    NotificationSubscription subscription,
  ) async {
    final cubit = context.read<NotificationCubit>();
    final confirmed = await showDeleteSubscriptionDialog(
      context,
      subscriptionName: subscription.subscriptionName,
    );
    if (!confirmed || !mounted) return;
    await cubit.deleteSubscription(widget.subscriptionId);
    if (!mounted) return;
    context.go(AutomationCenterSections.alertSubscriptionsLocation);
  }
}
