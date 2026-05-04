import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/features/gs1/gtin/cubit/gtin_cubit.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/list/screens/gtin_list_screen.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/screens/gtin_split_view_screen.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/split_or_list_indexed_stack.dart';

/// Main screen for GTIN (Global Trade Item Number) functionality
class GTINScreen extends StatefulWidget {
  const GTINScreen({super.key});

  @override
  State<GTINScreen> createState() => _GTINScreenState();
}

class _GTINScreenState extends State<GTINScreen> {
  late final GTINCubit _gtinCubit;

  @override
  void initState() {
    super.initState();
    _gtinCubit = getIt<GTINCubit>();
  }

  @override
  void dispose() {
    _gtinCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _gtinCubit,
      child: const SplitOrListIndexedStack(
        split: GTINSplitViewScreen(),
        fallback: GTINListScreen(),
      ),
    );
  }
}
