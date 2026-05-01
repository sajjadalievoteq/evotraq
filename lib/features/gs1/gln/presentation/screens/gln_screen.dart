import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/services/gln_service.dart';
import 'package:traqtrace_app/features/gs1/gln/cubit/gln_cubit.dart';
import 'package:traqtrace_app/features/gs1/gln/presentation/screens/gln_list_screen.dart';
import 'package:traqtrace_app/features/gs1/gln/presentation/screens/gln_split_view_screen.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/split_view.dart';

/// Main screen for GLN (Global Location Number) functionality
class GLNScreen extends StatefulWidget {
  const GLNScreen({super.key});

  @override
  State<GLNScreen> createState() => _GLNScreenState();
}

class _GLNScreenState extends State<GLNScreen> {
  late final GLNCubit _glnCubit;

  @override
  void initState() {
    super.initState();
    _glnCubit = GLNCubit(glnService: getIt<GLNService>());
  }

  @override
  void dispose() {
    _glnCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _glnCubit,
      child: const SplitOrListIndexedStack(
        split: GLNSplitViewScreen(),
        fallback: GLNListScreen(),
      ),
    );
  }
}
