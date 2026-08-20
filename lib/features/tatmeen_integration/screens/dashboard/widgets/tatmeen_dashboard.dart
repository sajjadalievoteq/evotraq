import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/display_date_utils.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/services/tatmeen_integration/tatmeen_integration_service.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_error_view.dart';
import 'package:traqtrace_app/features/tatmeen_integration/hooks/use_tatmeen_dashboard.dart';
import 'package:traqtrace_app/features/tatmeen_integration/hooks/use_tatmeen_navigation.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_records_models.dart';
import 'package:traqtrace_app/features/tatmeen_integration/screens/dashboard/widgets/tatmeen_error_summary.dart';
import 'package:traqtrace_app/features/tatmeen_integration/screens/dashboard/widgets/tatmeen_recent_activity.dart';
import 'package:traqtrace_app/features/tatmeen_integration/screens/dashboard/widgets/tatmeen_stats_row.dart';
import 'package:traqtrace_app/features/tatmeen_integration/screens/dashboard/widgets/tatmeen_status_breakdown.dart';
import 'package:traqtrace_app/features/tatmeen_integration/screens/dashboard/widgets/tatmeen_sync_chart.dart';

class TatmeenDashboard extends StatefulWidget {
  const TatmeenDashboard({super.key, this.controller});

  final UseTatmeenDashboard? controller;

  @override
  State<TatmeenDashboard> createState() => _TatmeenDashboardState();
}

class _TatmeenDashboardState extends State<TatmeenDashboard> {
  late final UseTatmeenDashboard _dashboard;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _dashboard =
        widget.controller ??
        UseTatmeenDashboard(service: getIt<TatmeenIntegrationService>());
    if (_ownsController) {
      _dashboard.load();
    }
  }

  @override
  void dispose() {
    if (_ownsController) {
      _dashboard.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dashboard,
      builder: (context, _) {
        if (_dashboard.isError && !_dashboard.isLoading) {
          return SubscriptionErrorView(
            title: 'Unable to load Tatmeen dashboard',
            message: _dashboard.error ?? 'Unknown error',
            onRetry: _dashboard.refetch,
            padding: EdgeInsets.zero,
          );
        }
        final loading = _dashboard.isLoading;
        final lastSynced = loading ? null : _dashboard.stats?.lastSyncedAt;
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            context.gutter,
            context.gutter,
            context.gutter,
            context.gutter,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 30,
                child: Row(
                  children: [
                    if (loading)
                      AppShimmer(
                        child: AppSkeletonBox(
                          width: 140,
                          height: 22,
                          color: AppShimmer.defaultBaseColor(context),
                        ),
                      )
                    else
                      Text('Dashboard', style: context.text.h2),
                    const Spacer(),
                    if (loading)
                      AppShimmer(
                        child: AppSkeletonBox(
                          width: 160,
                          height: 14,
                          color: AppShimmer.defaultBaseColor(context),
                        ),
                      )
                    else if (lastSynced != null)
                      Text(
                        'Last synced: ${DisplayDateUtils.dmyHm(lastSynced)}',
                        style: context.text.bodySm.copyWith(
                          color: context.colors.textMuted,
                        ),
                      ),
                    const SizedBox(width: TraqSpacing.sm),
                    IconButton(
                      onPressed: loading ? null : _dashboard.refetch,
                      padding: EdgeInsets.zero,
                      tooltip: 'Refresh',
                      icon: _dashboard.isRefreshing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const TraqIcon(AppAssets.iconRefresh, size: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: TraqSpacing.md),
              TatmeenStatsRow(
                stats: loading ? null : _dashboard.stats,
                isLoading: loading,
                onSelectStatus: loading
                    ? null
                    : (status) {
                        TatmeenNavigation.navigateToRecords(
                          context,
                          RecordsFilter.kpi(status),
                        );
                      },
              ),
              const SizedBox(height: TraqSpacing.md),
              LayoutBuilder(
                builder: (context, constraints) {
                  final stacked = constraints.maxWidth < 980;
                  final syncCard = SizedBox(
                    height: 320,
                    child: TraqCard(
                      child: TatmeenSyncChart(
                        data: loading ? const [] : _dashboard.chartData,
                        isLoading: loading,
                        error: loading ? null : _dashboard.error,
                        onRetry: _dashboard.refetch,
                      ),
                    ),
                  );
                  final breakdownCard = SizedBox(
                    height: 320,
                    child: TraqCard(
                      child: TatmeenStatusBreakdownChart(
                        breakdown: loading ? null : _dashboard.breakdown,
                        isLoading: loading,
                        error: loading ? null : _dashboard.error,
                        onRetry: _dashboard.refetch,
                      ),
                    ),
                  );
                  if (stacked) {
                    return Column(
                      children: [
                        syncCard,
                        const SizedBox(height: TraqSpacing.md),
                        breakdownCard,
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: syncCard),
                      const SizedBox(width: TraqSpacing.md),
                      Expanded(child: breakdownCard),
                    ],
                  );
                },
              ),
              const SizedBox(height: TraqSpacing.md),
              TraqCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (loading)
                      AppShimmer(
                        child: AppSkeletonBox(
                          width: 160,
                          height: 22,
                          color: AppShimmer.defaultBaseColor(context),
                        ),
                      )
                    else
                      Text('Recent Activity', style: context.text.h3),
                    const SizedBox(height: TraqSpacing.sm),
                    TatmeenRecentActivity(
                      events: loading ? const [] : _dashboard.recentActivity,
                      isLoading: loading,
                      error: loading ? null : _dashboard.error,
                      onRetry: _dashboard.refetch,
                      onViewAll: loading
                          ? null
                          : () {
                              TatmeenNavigation.navigateToRecords(
                                context,
                                const RecordsFilter.recentActivity(),
                              );
                            },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: TraqSpacing.md),
              TraqCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (loading)
                      AppShimmer(
                        child: AppSkeletonBox(
                          width: 200,
                          height: 22,
                          color: AppShimmer.defaultBaseColor(context),
                        ),
                      )
                    else
                      Text('Top Errors This Month', style: context.text.h3),
                    const SizedBox(height: TraqSpacing.sm),
                    TatmeenErrorSummary(
                      items: loading ? const [] : _dashboard.errorSummary,
                      isLoading: loading,
                      error: loading ? null : _dashboard.error,
                      onRetry: _dashboard.refetch,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
