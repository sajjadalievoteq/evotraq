import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/traq_app_bar.dart';
import 'package:traqtrace_app/data/services/dashboard_service.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/features/home/home_dashboard_cache.dart';
import 'package:traqtrace_app/features/home/presentation/cubit/home_dashboard_cubit.dart';
import 'package:traqtrace_app/features/home/presentation/cubit/home_dashboard_state.dart';
import 'package:traqtrace_app/features/home/presentation/widgets/key_metrics/key_metrics_section.dart';
import 'package:traqtrace_app/features/home/presentation/widgets/loading/dashboard_loader.dart';
import 'package:traqtrace_app/features/home/presentation/widgets/operations_header/operations_header.dart';
import 'package:traqtrace_app/features/home/presentation/widgets/quick_actions/quick_actions_and_compliance_row.dart';
import 'package:traqtrace_app/features/home/presentation/widgets/shared/home_dashboard_error_view.dart';
import 'package:traqtrace_app/features/home/presentation/widgets/status_rail/status_rail.dart';
import 'package:traqtrace_app/features/home/presentation/widgets/throughput_chart/throughput_and_events_row.dart';
import 'package:traqtrace_app/shared/layout/layout_manager.dart';

import '../widgets/welcome/widgets/dashboard_welcome_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeDashboardCubit(getIt<DashboardService>()),
      child: const _HomeDashboardShell(),
    );
  }
}

class _HomeDashboardShell extends StatefulWidget {
  const _HomeDashboardShell();

  @override
  State<_HomeDashboardShell> createState() => _HomeDashboardShellState();
}

class _HomeDashboardShellState extends State<_HomeDashboardShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  void _bootstrap() {
    if (!mounted) return;
    final auth = context.read<AuthCubit>();
    var user = auth.state.user;
    if (user != null &&
        HomeDashboardCache.ownerEmail != null &&
        HomeDashboardCache.ownerEmail != user.email) {
      HomeDashboardCache.clear();
    }
    if (user == null) {
      auth.getCurrentUser();
    }
    user = auth.state.user;
    context.read<HomeDashboardCubit>().load(ownerEmail: user?.email);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (p, c) => p.user?.email != c.user?.email,
      listener: (context, state) {
        context.read<HomeDashboardCubit>().load(ownerEmail: state.user?.email);
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          final user = authState.user;

          if (user == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return Scaffold(
            backgroundColor: context.colors.background,
            appBar: TraqAppBar(
              context,
              title: Text(
                'Home',
                style: context.text.body.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
            drawer: const AppDrawer(),
            body: BlocBuilder<HomeDashboardCubit, HomeDashboardState>(
              builder: (context, dashState) {
                return RefreshIndicator(
                  onRefresh: () {
                    return context.read<HomeDashboardCubit>().refresh(
                          ownerEmail:
                              context.read<AuthCubit>().state.user?.email,
                        );
                  },
                  child: dashState.isLoading
                      ? const DashboardLoader()
                      : dashState.hasError
                          ? HomeDashboardErrorView(
                              message: dashState.errorMessage ?? 'Unknown error',
                            )
                          : const _DashboardScrollBody(),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _DashboardScrollBody extends StatelessWidget {
  const _DashboardScrollBody();

  @override
  Widget build(BuildContext context) {
    return AppLayoutBuilder(
      builder: (context, layout) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
           ResponsiveUtils.gutter(context),
            ResponsiveUtils.gutter(context)*0.5,
            ResponsiveUtils.gutter(context),

            32,
          ),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OperationsHeader(layout: layout),
                SizedBox(height: layout.isCompact ? 16 : 24),
                StatusRail(layout: layout),
                SizedBox(height: layout.isCompact ? 18 : 26),
                KeyMetricsSection(layout: layout),
                SizedBox(height: layout.isCompact ? 20 : 28),
                ThroughputAndEventsRow(layout: layout),
                SizedBox(height: layout.isCompact ? 20 : 28),
                QuickActionsAndComplianceRow(layout: layout),
              ],
            ),
          ),
        );
      },
    );
  }
}
