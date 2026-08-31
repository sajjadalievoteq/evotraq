import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_commissioning_prefill.dart';
import 'package:traqtrace_app/features/operations/commissioning/cubit/commissioning_operation_cubit.dart';
import 'commissioning_operation_view.dart';

class CommissioningOperationScreen extends StatelessWidget {
  const CommissioningOperationScreen({
    super.key,
    this.initialIdentifierType,
    this.initialEpc,
    this.ssccPrefill,
  });

  final EPCType? initialIdentifierType;
  final String? initialEpc;
  final SsccCommissioningPrefill? ssccPrefill;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CommissioningOperationCubit>(),
      child: CommissioningOperationView(
        initialIdentifierType: initialIdentifierType,
        initialEpc: initialEpc,
        ssccPrefill: ssccPrefill,
      ),
    );
  }
}
