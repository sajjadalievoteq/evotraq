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

class _HomeShellState extends State<HomeShell> {
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
            return const HomeAuthLoadingScaffold();
          }
          return HomeLoadedScaffold(userEmail: user.email);
        },
      ),
    );
  }
}
