import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/automation_center/notification_subscription.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_cubit.dart';
import 'package:traqtrace_app/features/automation_center/cubit/notification_state.dart';
import 'package:traqtrace_app/features/automation_center/utils/subscription_filter_utils.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_empty_state.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_error_view.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_loading_skeleton.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_skeleton_shape.dart';
import 'package:traqtrace_app/features/automation_center/screens/subscription_management/widgets/subscription_master_list.dart';
import 'package:traqtrace_app/features/automation_center/screens/subscription_management/widgets/subscription_detail_pane.dart';
import 'package:traqtrace_app/features/automation_center/screens/subscription_management/widgets/embedded_full_details_pane.dart';

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
          return const SubscriptionLoadingSkeleton(
            shrinkWrap: true,
            shape: SubscriptionSkeletonShape.managementMasterDetail,
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
        final stats = state.lastLoadedStatsSubscriptionId == selected.id
            ? state.lastLoadedStats
            : selected.stats;

        return LayoutBuilder(
          builder: (context, constraints) {
            final stacked = constraints.maxWidth < 900 || context.isMobile;
            final list = SubscriptionMasterList(
              subscriptions: filtered,
              selectedId: selectedId,
              onSelected: _selectSubscription,
              shrinkWrap: widget.shrinkWrap,
            );
            final detail = _showFullDetails && !stacked
                ? EmbeddedFullDetailsPane(
                    subscription: selected,
                    stats: stats,
                    shrinkWrap: widget.shrinkWrap,
                    onBack: () => setState(() => _showFullDetails = false),
                    onEdit: widget.onEdit,
                    onDelete: widget.onDelete,
                    onPause: widget.onPause,
                    onResume: widget.onResume,
                  )
                : SubscriptionDetailPane(
                    subscription: selected,
                    shrinkWrap: widget.shrinkWrap,
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
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.shrinkWrap)
                    list
                  else
                    SizedBox(height: 220, child: list),
                  const SizedBox(height: TraqSpacing.md),
                  if (widget.shrinkWrap) detail else Expanded(child: detail),
                ],
              );
            }

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(width: constraints.maxWidth * 0.34, child: list),
                  const SizedBox(width: TraqSpacing.md),
                  Expanded(child: detail),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
