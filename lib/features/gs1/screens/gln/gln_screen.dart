import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/features/gs1/bloc/gln/gln_cubit.dart';

import '../../../../data/services/gln_service.dart';
import 'gln_list_screen.dart';

/// Main screen for GLN (Global Location Number) functionality
class GLNScreen extends StatelessWidget {
  const GLNScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GLNCubit(glnService: getIt<GLNService>()),
      child: const GLNListScreen(),
    );
  }
}
