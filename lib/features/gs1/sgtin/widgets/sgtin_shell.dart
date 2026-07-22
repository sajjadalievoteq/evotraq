import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sgtin/sgtin_service.dart';
import 'package:traqtrace_app/features/gs1/sgtin/bloc/sgtin_cubit.dart';

/// Provides [SGTINCubit] for the SGTIN feature route subtree.
///
/// Lifetime matches the go_router [ShellRoute] session: the cubit persists
/// across intra-feature navigation and is disposed when leaving the feature.
class SgtinShell extends StatelessWidget {
  const SgtinShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SGTINCubit>(
      create: (context) => SGTINCubit(sgtinService: getIt<SGTINService>()),
      child: child,
    );
  }
}
