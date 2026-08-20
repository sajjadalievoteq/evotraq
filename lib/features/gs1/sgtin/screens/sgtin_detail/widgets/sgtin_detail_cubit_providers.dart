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
    return BlocProvider<ValidationCubit>.value(
      value: validationCubit,
      child: MultiBlocProvider(
        providers: [
          if (sgtinCubit != null)
            BlocProvider<SGTINCubit>.value(value: sgtinCubit!),
          if (batchCubit != null)
            BlocProvider<SgtinBatchCubit>.value(value: batchCubit!),
        ],
        child: batchCubit == null
            ? child
            : BlocListener<SgtinBatchCubit, SgtinBatchState>(
                listenWhen: (previous, current) =>
                    previous.resolvedBatch != current.resolvedBatch ||
                    previous.status != current.status,
                listener: (context, state) => onBatchStateChanged(state),
                child: child,
              ),
      ),
    );
  }
}
