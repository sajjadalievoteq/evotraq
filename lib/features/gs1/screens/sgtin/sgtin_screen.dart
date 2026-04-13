import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/features/gs1/bloc/sgtin/sgtin_cubit.dart';
import 'package:traqtrace_app/features/gs1/screens/sgtin/sgtin_list_screen.dart';

import '../../../../data/services/sgtin_service.dart';

/// Main screen for SGTIN (Serialized Global Trade Item Number) functionality
class SGTINScreen extends StatelessWidget {
  const SGTINScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SGTINCubit(sgtinService: getIt<SGTINService>()),
      child: const SGTINListScreen(),
    );
  }
}
