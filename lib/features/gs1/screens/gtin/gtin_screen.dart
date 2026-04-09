import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/features/gs1/bloc/gtin/gtin_cubit.dart';
import 'package:traqtrace_app/features/gs1/screens/gtin/gtin_list_screen.dart';
import 'package:traqtrace_app/features/gs1/services/gtin_service.dart';

/// Main screen for GTIN (Global Trade Item Number) functionality
class GTINScreen extends StatelessWidget {
  const GTINScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GTINCubit(gtinService: getIt<GTINService>()),
      child: const GTINListScreen(),
    );
  }
}
