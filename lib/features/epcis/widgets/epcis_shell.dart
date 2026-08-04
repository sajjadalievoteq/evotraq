import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/features/epcis/cubit/aggregation_events_cubit.dart';
import 'package:traqtrace_app/features/epcis/cubit/cbv_vocabulary_cubit.dart';
import 'package:traqtrace_app/features/epcis/cubit/object_events_cubit.dart';
import 'package:traqtrace_app/features/epcis/cubit/transaction_document_cubit.dart';
import 'package:traqtrace_app/features/epcis/cubit/transaction_events_cubit.dart';
import 'package:traqtrace_app/features/epcis/cubit/transformation_events_cubit.dart';
import 'package:traqtrace_app/features/epcis/cubit/validation_cubit.dart';

/// Provides EPCIS cubits for the feature route subtree.
///
/// Lifetime matches the go_router [ShellRoute] session: cubits persist across
/// intra-feature navigation and are disposed when leaving the feature.
///
/// [CbvVocabularyCubit] is the GetIt singleton (also used by admin via DI);
/// startup [CbvVocabularyService.hydrateFromCache] remains in `main()`.
class EpcisShell extends StatelessWidget {
  const EpcisShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CbvVocabularyCubit>.value(
          value: getIt<CbvVocabularyCubit>(),
        ),
        BlocProvider<TransactionEventsCubit>(
          create: (context) => TransactionEventsCubit(),
        ),
        BlocProvider<ObjectEventsCubit>(
          create: (context) => ObjectEventsCubit(),
        ),
        BlocProvider<TransformationEventsCubit>(
          create: (context) => TransformationEventsCubit(),
        ),
        BlocProvider<ValidationCubit>(
          create: (context) => ValidationCubit(),
        ),
        BlocProvider<TransactionDocumentCubit>(
          create: (context) =>
              TransactionDocumentCubit(appConfig: getIt<AppConfig>()),
        ),
        BlocProvider<AggregationEventsCubit>(
          create: (context) => AggregationEventsCubit(),
        ),
      ],
      child: child,
    );
  }
}
