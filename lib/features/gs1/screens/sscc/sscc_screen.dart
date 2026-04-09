import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/features/gs1/bloc/sscc/sscc_cubit.dart';
import 'package:traqtrace_app/features/gs1/screens/sscc/sscc_list_screen.dart';
import 'package:traqtrace_app/features/gs1/services/sscc_service.dart';

/// Main screen for SSCC (Serial Shipping Container Code) functionality
class SSCCScreen extends StatelessWidget {
  const SSCCScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SSCCCubit(ssccService: getIt<SSCCService>()),
      child: const SSCCListScreen(),
    );
  }
}
