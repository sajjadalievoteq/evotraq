import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/services/home/dashboard_service.dart';
import 'package:traqtrace_app/data/session/home_overview_session_store.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/features/home/cubit/home_cubit.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/home_auth_loading_scaffold.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/home_loaded_scaffold.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late final HomeCubit _homeCubit;
  String? _accountEmail;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _homeCubit = HomeCubit(
      getIt<DashboardService>(),
      getIt<HomeOverviewSessionStore>(),
    );

    _accountEmail = context.read<AuthCubit>().state.user?.email;
    _homeCubit.load(accountEmail: _accountEmail);
    _homeCubit.startPolling(accountEmail: _accountEmail);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _homeCubit.stopPolling();
    _homeCubit.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        _homeCubit.stopPolling();
      case AppLifecycleState.resumed:
        unawaited(_homeCubit.onAppResumed(accountEmail: _accountEmail));
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _homeCubit,
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          final user = authState.user;
          if (user == null) {
            return const HomeAuthLoadingScaffold();
          }
          return HomeLoadedScaffold(userEmail: user.email);
        },
      ),
    );
  }
}
