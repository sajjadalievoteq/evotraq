import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/services/service_account_service.dart';
import 'package:traqtrace_app/features/api_management/cubit/api_collection_cubit.dart';
import 'package:traqtrace_app/features/api_management/cubit/api_management_cubit.dart';
import 'package:traqtrace_app/features/api_management/providers/partner_access_provider.dart';
import 'package:traqtrace_app/features/api_management/providers/service_account_provider.dart';

/// Provides API-management cubits for the feature route subtree.
///
/// Lifetime matches the go_router [ShellRoute] session: cubits persist across
/// intra-feature navigation and are disposed when leaving the feature.
class ApiManagementShell extends StatelessWidget {
  const ApiManagementShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ApiCollectionCubit>(
          create: (context) => ApiCollectionCubit(),
        ),
        BlocProvider<ApiManagementCubit>(
          create: (context) => ApiManagementCubit(),
        ),
        BlocProvider<PartnerAccessCubit>(
          create: (context) => PartnerAccessCubit(),
        ),
        BlocProvider<ServiceAccountCubit>(
          create: (context) =>
              ServiceAccountCubit(service: getIt<ServiceAccountService>()),
        ),
      ],
      child: child,
    );
  }
}