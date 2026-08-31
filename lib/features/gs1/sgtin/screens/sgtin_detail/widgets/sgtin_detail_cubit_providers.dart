import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/features/epcis/cubit/validation_cubit.dart';
import 'package:traqtrace_app/features/gs1/sgtin/cubit/sgtin_batch_cubit.dart';
import 'package:traqtrace_app/features/gs1/sgtin/cubit/sgtin_batch_state.dart';
import 'package:traqtrace_app/features/gs1/sgtin/cubit/sgtin_cubit.dart';

class SgtinDetailCubitProviders extends StatelessWidget {
  const SgtinDetailCubitProviders({
    super.key,
    required this.validationCubit,
    required this.child,
    required this.onBatchStateChanged,
    this.sgtinCubit,
    this.batchCubit,
  });

  final ValidationCubit validationCubit;
  final SGTINCubit? sgtinCubit;
  final SgtinBatchCubit? batchCubit;
  final ValueChanged<SgtinBatchState> onBatchStateChanged;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    Widget content = batchCubit == null
        ? child
        : BlocListener<SgtinBatchCubit, SgtinBatchState>(
            listenWhen: (previous, current) =>
                previous.resolvedBatch != current.resolvedBatch ||
                previous.status != current.status,
            listener: (context, state) => onBatchStateChanged(state),
            child: child,
          );

    if (sgtinCubit != null && batchCubit != null) {
      content = MultiBlocProvider(
        providers: [
          BlocProvider<SGTINCubit>.value(value: sgtinCubit!),
          BlocProvider<SgtinBatchCubit>.value(value: batchCubit!),
        ],
        child: content,
      );
    } else if (sgtinCubit != null) {
      content = BlocProvider<SGTINCubit>.value(
        value: sgtinCubit!,
        child: content,
      );
    } else if (batchCubit != null) {
      content = BlocProvider<SgtinBatchCubit>.value(
        value: batchCubit!,
        child: content,
      );
    }

    return BlocProvider<ValidationCubit>.value(
      value: validationCubit,
      child: content,
    );
  }
}
