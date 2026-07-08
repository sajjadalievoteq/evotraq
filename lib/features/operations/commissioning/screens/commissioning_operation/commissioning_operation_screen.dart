import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/services/gs1/gtin/gtin_service.dart';
import 'package:traqtrace_app/features/gs1/gtin/cubit/gtin_cubit.dart';
import 'package:traqtrace_app/features/operations/commissioning/cubit/commissioning_operation_cubit.dart';
import 'commissioning_operation_view.dart';

class CommissioningOperationScreen extends StatelessWidget {
  const CommissioningOperationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => GTINCubit(gtinService: getIt<GTINService>()),
        ),
        BlocProvider(
          create: (_) => getIt<CommissioningOperationCubit>(),
        ),
      ],
      child: const CommissioningOperationView(),
    );
  }
}
