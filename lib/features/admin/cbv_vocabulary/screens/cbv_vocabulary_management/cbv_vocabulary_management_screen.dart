import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/admin/cbv_vocabulary/screens/cbv_vocabulary_management/cbv_vocabulary_management_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:traqtrace_app/features/admin/cbv_vocabulary/cubit/admin_cbv_vocabulary_cubit.dart';

class CbvVocabularyManagementScreen extends StatelessWidget {
  const CbvVocabularyManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<AdminCbvVocabularyCubit>()..load(),
      child: const CbvVocabularyManagementView(),
    );
  }
}
