import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/automation_center/notification_subscription.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_cubit.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_state.dart';
import 'package:traqtrace_app/features/automation_center/screens/subscription_details/widgets/subscription_details_body.dart';
import 'package:traqtrace_app/features/automation_center/utils/subscription_delivery_utils.dart';
import 'package:traqtrace_app/features/automation_center/utils/subscription_filter_utils.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_card/subscription_action_menu.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_card/subscription_status_chip.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_empty_state.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_error_view.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_loading_skeleton.dart';

class SubscriptionManagementBody extends StatefulWidget {
  const SubscriptionManagementBody({
    super.key,
    required this.selectedDeliveryFilter,
    required this.selectedStatusFilter,
    required this.searchQuery,
    required this.shrinkWrap,
    required this.onRefresh,
    required this.onEdit,
    required this.onDelete,
    required this.onPause,
    required this.onResume,
    required this.onViewDetails,
    required this.onClearFilters,
    required this.onCreate,
    this.onViewAllActivity,
  });

  final String selectedDeliveryFilter;
  final String selectedStatusFilter;
  final String searchQuery;
  final bool shrinkWrap;
  final VoidCallback onRefresh;
  final void Function(NotificationSubscription) onEdit;
  final void Function(NotificationSubscription) onDelete;
  final void Function(NotificationSubscription) onPause;
  final void Function(NotificationSubscription) onResume;
  final void Function(NotificationSubscription) onViewDetails;
  final VoidCallback onClearFilters;
  final VoidCallback onCreate;
  final VoidCallback? onViewAllActivity;

  @override
  State<SubscriptionManagementBody> createState() =>
      _SubscriptionManagementBodyState();
}

class _SubscriptionManagementBodyState
    extends State<SubscriptionManagementBody> {
  String? _selectedId;
  bool _showFullDetails = false;

  void _selectSubscription(NotificationSubscription sub) {
    setState(() {
      _selectedId = sub.id;
      _showFullDetails = false;
    });
  }

  void _openFullDetails({
    required NotificationSubscription subscription,
    required bool inPanel,
  }) {
    if (inPanel) {
      setState(() => _showFullDetails = true);
      context.read<NotificationCubit>().loadSubscriptionStats(subscription.id);
      return;
    }
    widget.onViewDetails(subscription);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotificationCubit, NotificationState>(
      listenWhen: (prev, next) => prev.subscriptions != next.subscriptions,
      listener: (context, state) {
        if (state.subscriptions.isEmpty) {
          _selectedId = null;
          _showFullDetails = false;
          return;
        }
        final stillExists = state.subscriptions.any((s) => s.id == _selectedId);
        if (!stillExists) {
          setState(() {
            _selectedId = state.subscriptions.first.id;
            _showFullDetails = false;
          });
        }
      },
      builder: (context, state) {
        if (state.status == NotificationStatus.initial ||
            (state.status == NotificationStatus.loading &&
                state.subscriptions.isEmpty)) {
          return SubscriptionLoadingSkeleton(
            shrinkWrap: widget.shrinkWrap,
            itemCount: 4,
            shape: SubscriptionSkeletonShape.managementCard,
          );
        }
        if (state.status == NotificationStatus.error &&
            state.subscriptions.isEmpty) {
          return SubscriptionErrorView(
            title: 'Unable to load subscriptions',
            message: state.error ?? 'Unknown error',
            onRetry: widget.onRefresh,
          );
        }

        final filtered = SubscriptionFilterUtils.search(
          SubscriptionFilterUtils.filterManagement(
            state.subscriptions,
            widget.selectedDeliveryFilter,
            statusFilter: widget.selectedStatusFilter,
          ),
          widget.searchQuery,
        );

        if (filtered.isEmpty) {
          return SubscriptionEmptyState(
            totalSubscriptions: state.subscriptions.length,
            selectedFilter:
                widget.selectedDeliveryFilter == 'all' &&
                    widget.selectedStatusFilter == 'all' &&
                    widget.searchQuery.trim().isEmpty
                ? 'all'
                : 'filtered',
            title: state.subscriptions.isEmpty
                ? 'No subscriptions yet'
                : 'No matching subscriptions',
            subtitle: state.subscriptions.isEmpty
                ? 'Create a subscription to receive alerts for EPCIS events.'
                : 'Adjust the search or filters to see more subscriptions.',
            onClearFilters: widget.onClearFilters,
            onPrimaryAction: widget.onCreate,
          );
        }

        final selectedId = filtered.any((s) => s.id == _selectedId)
            ? _selectedId!
            : filtered.first.id;
        if (_selectedId != selectedId) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() {
              _selectedId = selectedId;
              _showFullDetails = false;
            });
          });
        }

        final selected = filtered.firstWhere((s) => s.id == selectedId);
        final stats =
            state.lastLoadedStatsSubscriptionId == selected.id
            ? state.lastLoadedStats
            : selected.stats;

        return LayoutBuilder(
          builder: (context, constraints) {
            final stacked = constraints.maxWidth < 900 || context.isMobile;
            final list = _SubscriptionMasterList(
              subscriptions: filtered,
              selectedId: selectedId,
              onSelected: _selectSubscription,
            );
            final detail = _showFullDetails && !stacked
                ? _EmbeddedFullDetailsPane(
                    subscription: selected,
                    stats: stats,
                    onBack: () => setState(() => _showFullDetails = false),
                    onEdit: widget.onEdit,
                    onDelete: widget.onDelete,
                    onPause: widget.onPause,
                    onResume: widget.onResume,
                  )
                : _SubscriptionDetailPane(
                    subscription: selected,
                    onEdit: widget.onEdit,
                    onDelete: widget.onDelete,
                    onPause: widget.onPause,
                    onResume: widget.onResume,
                    onViewDetails: () => _openFullDetails(
                      subscription: selected,
                      inPanel: !stacked,
                    ),
                    onViewAllActivity: widget.onViewAllActivity,
                  );

            if (stacked) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 220, child: list),
                  const SizedBox(height: TraqSpacing.md),
                  Expanded(child: detail),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(width: constraints.maxWidth * 0.34, child: list),
                const SizedBox(width: TraqSpacing.md),
                Expanded(child: detail),
              ],
            );
          },
        );
      },
    );
  }
}

class _SubscriptionMasterList extends StatelessWidget {
  const _SubscriptionMasterList({
    required this.subscriptions,
    required this.selectedId,
    required this.onSelected,
  });

  final List<NotificationSubscription> subscriptions;
  final String selectedId;
  final ValueChanged<NotificationSubscription> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: subscriptions.length,
      separatorBuilder: (_, _) => const SizedBox(height: TraqSpacing.sm),
      itemBuilder: (context, index) {
        final sub = subscriptions[index];
        return _SubscriptionMasterRow(
          subscription: sub,
          selected: sub.id == selectedId,
          onTap: () => onSelected(sub),
        );
      },
    );
  }
}

class _SubscriptionMasterRow extends StatelessWidget {
  const _SubscriptionMasterRow({
    required this.subscription,
    required this.selected,
    required this.onTap,
  });

  final NotificationSubscription subscription;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final created = DateFormat.yMMMd().format(subscription.createdAt.toLocal());

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: selected ? c.primary.withValues(alpha: 0.06) : c.surface,
        borderRadius: TraqRadius.card,
        border: Border.all(
          color: selected ? c.primary.withValues(alpha: 0.5) : c.border,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: TraqRadius.card,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: TraqSpacing.md,
              vertical: TraqSpacing.md,
            ),
            child: Row(
              children: [
                TraqIcon(
                  SubscriptionDeliveryUtils.iconForEndpoint(
                    subscription.webhookUrl,
                  ),
                  size: 18,
                  color: selected ? c.primary : c.textMuted,
                ),
                const SizedBox(width: TraqSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subscription.subscriptionName,
                        style: context.text.bodySm.copyWith(
                          fontWeight: FontWeight.w700,
                          color: c.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: TraqSpacing.xs),
                      Text(
                        subscription.webhookUrl,
                        style: context.text.cap.copyWith(color: c.textMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Created $created',
                        style: context.text.cap.copyWith(color: c.textMuted),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: TraqSpacing.xs),
                TraqIcon(
                  AppAssets.iconChevronR,
                  size: 14,
                  color: c.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SubscriptionDetailPane extends StatelessWidget {
  const _SubscriptionDetailPane({
    required this.subscription,
    required this.onEdit,
    required this.onDelete,
    required this.onPause,
    required this.onResume,
    required this.onViewDetails,
    this.onViewAllActivity,
  });

  final NotificationSubscription subscription;
  final void Function(NotificationSubscription) onEdit;
  final void Function(NotificationSubscription) onDelete;
  final void Function(NotificationSubscription) onPause;
  final void Function(NotificationSubscription) onResume;
  final VoidCallback onViewDetails;
  final VoidCallback? onViewAllActivity;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final created = DateFormat.yMMMd().format(subscription.createdAt.toLocal());
    final deliveryLabel = SubscriptionDeliveryUtils.labelForEndpoint(
      subscription.webhookUrl,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: TraqRadius.card,
        border: Border.all(color: c.border),
      ),
      child: Padding(
        padding: TraqSpacing.surfacePad,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TraqIcon(
                        SubscriptionDeliveryUtils.iconForEndpoint(
                          subscription.webhookUrl,
                        ),
                        size: 22,
                        color: c.primary,
                      ),
                      const SizedBox(width: TraqSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    subscription.subscriptionName,
                                    style: context.text.h3.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                SubscriptionStatusChip(
                                  status: subscription.status,
                                ),
                                SubscriptionActionMenu(
                                  subscription: subscription,
                                  onEdit: () => onEdit(subscription),
                                  onPause: () => onPause(subscription),
                                  onResume: () => onResume(subscription),
                                  onDelete: () => onDelete(subscription),
                                ),
                              ],
                            ),
                            const SizedBox(height: TraqSpacing.xs),
                            Text(
                              'Endpoint: ${subscription.webhookUrl}',
                              style: context.text.bodySm.copyWith(
                                color: c.textMuted,
                              ),
                            ),
                            Text(
                              'Created: $created',
                              style: context.text.bodySm.copyWith(
                                color: c.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: TraqSpacing.lg),
                  _ConfigRow(label: 'Delivery', value: deliveryLabel),
                  _ConfigRow(
                    label: 'Type',
                    value: subscription.subscriptionType,
                  ),
                  _ConfigRow(
                    label: 'Format',
                    value: subscription.notificationFormat ?? '—',
                  ),
                  const SizedBox(height: TraqSpacing.lg),
                  Text(
                    'Delivery metrics and per-event history live on the '
                    'Activity tab.',
                    style: context.text.bodySm.copyWith(color: c.textMuted),
                  ),

                ],
              ),
            ),
            const SizedBox(height: TraqSpacing.md),
            FilledButton(
              onPressed: onViewDetails,
              child: const Text('Open full details'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmbeddedFullDetailsPane extends StatelessWidget {
  const _EmbeddedFullDetailsPane({
    required this.subscription,
    required this.stats,
    required this.onBack,
    required this.onEdit,
    required this.onDelete,
    required this.onPause,
    required this.onResume,
  });

  final NotificationSubscription subscription;
  final NotificationStats? stats;
  final VoidCallback onBack;
  final void Function(NotificationSubscription) onEdit;
  final void Function(NotificationSubscription) onDelete;
  final void Function(NotificationSubscription) onPause;
  final void Function(NotificationSubscription) onResume;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: TraqRadius.card,
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              TraqSpacing.sm,
              TraqSpacing.sm,
              TraqSpacing.md,
              TraqSpacing.sm,
            ),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Back to summary',
                  onPressed: onBack,
                  icon: const TraqIcon(AppAssets.iconChevronL, size: 18),
                ),
                Expanded(
                  child: Text(
                    'Subscription details',
                    style: context.text.body.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SubscriptionActionMenu(
                  subscription: subscription,
                  onEdit: () => onEdit(subscription),
                  onPause: () => onPause(subscription),
                  onResume: () => onResume(subscription),
                  onDelete: () => onDelete(subscription),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: c.border),
          Expanded(
            child: Padding(
              padding: TraqSpacing.surfacePad,
              child: SubscriptionDetailsBody(
                subscription: subscription,
                stats: stats,
                embedded: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfigRow extends StatelessWidget {
  const _ConfigRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: TraqSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: context.text.cap.copyWith(
                color: c.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: context.text.bodySm.copyWith(color: c.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
