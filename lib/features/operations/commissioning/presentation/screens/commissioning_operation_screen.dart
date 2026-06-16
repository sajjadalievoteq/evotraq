import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/features/gs1/gtin/cubit/gtin_cubit.dart';
import 'commissioning_operation_view.dart';

class CommissioningOperationScreen extends StatelessWidget {
  const CommissioningOperationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<GTINCubit>(),
      child: const CommissioningOperationView(),
    );
  }
}
