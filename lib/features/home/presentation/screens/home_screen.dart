import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/traq_app_bar.dart';
import 'package:traqtrace_app/data/services/home/dashboard_service.dart';
import 'package:traqtrace_app/data/session/home_overview_session_store.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/features/home/presentation/constants/home_strings.dart';
import 'package:traqtrace_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:traqtrace_app/features/home/presentation/cubit/home_state.dart';
import 'package:traqtrace_app/features/home/presentation/widgets/key_metrics/key_metrics_section.dart';
import 'package:traqtrace_app/features/home/presentation/widgets/loading/dashboard_loader.dart';
import 'package:traqtrace_app/features/home/presentation/widgets/operations_header/operations_header.dart';
import 'package:traqtrace_app/features/home/presentation/widgets/quick_actions/quick_actions_and_compliance_row.dart';
import 'package:traqtrace_app/features/home/presentation/widgets/shared/home_error_view.dart';
import 'package:traqtrace_app/features/home/presentation/widgets/status_rail/status_rail.dart';
import 'package:traqtrace_app/features/home/presentation/widgets/throughput_chart/throughput_and_events_row.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit(
            getIt<DashboardService>(),
            getIt<HomeOverviewSessionStore>(),
          ),
      child: const _HomeShell(),
    );
  }
}

class _HomeShell extends StatefulWidget {
  const _HomeShell();

  @override
  State<_HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<_HomeShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  void _bootstrap() {
    if (!mounted) return;
    final auth = context.read<AuthCubit>();
    var user = auth.state.user;
    if (user == null) {
      auth.getCurrentUser();
    }
    user = auth.state.user;
    context.read<HomeCubit>().load(accountEmail: user?.email);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (p, c) => p.user?.email != c.user?.email,
      listener: (context, state) {
        context.read<HomeCubit>().load(accountEmail: state.user?.email);
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
                HomeStrings.appBarTitle,
                style: context.text.body.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
            drawer: const AppDrawer(),
            body: BlocBuilder<HomeCubit, HomeState>(
              builder: (context, homeState) {
                return RefreshIndicator(
                  onRefresh: () {
                    return context
                        .read<HomeCubit>()
                        .refresh(accountEmail: user.email);
                  },
                  child: homeState.isLoading
                      ? const DashboardLoader()
                      : homeState.hasError
                          ? HomeErrorView(
                              message: homeState.errorMessage ??
                                  HomeStrings.unknownError,
                            )
                          : const _HomeScrollBody(),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _HomeScrollBody extends StatelessWidget {
  const _HomeScrollBody();

  @override
  Widget build(BuildContext context) {
    return AppLayoutBuilder(
      builder: (context, layout) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
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
