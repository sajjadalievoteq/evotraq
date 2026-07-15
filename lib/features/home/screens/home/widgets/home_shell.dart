import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/features/home/cubit/home_cubit.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/home_auth_loading_scaffold.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/home_loaded_scaffold.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
    final email = user?.email;
    final homeCubit = context.read<HomeCubit>();
    homeCubit.load(accountEmail: email);
    homeCubit.startPolling(accountEmail: email);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    final homeCubit = context.read<HomeCubit>();
    final email = context.read<AuthCubit>().state.user?.email;
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        homeCubit.stopPolling();
      case AppLifecycleState.resumed:
        // Fire-and-forget: immediate SWR then restart the timer.
        homeCubit.onAppResumed(accountEmail: email);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    context.read<HomeCubit>().stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (p, c) => p.user?.email != c.user?.email,
      listener: (context, state) {
        final email = state.user?.email;
        final homeCubit = context.read<HomeCubit>();
        homeCubit.load(accountEmail: email);
        homeCubit.startPolling(accountEmail: email);
      },
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
