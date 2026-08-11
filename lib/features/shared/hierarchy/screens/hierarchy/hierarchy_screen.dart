import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/features/shared/hierarchy/screens/hierarchy/cubit/hierarchy_cubit.dart';
import 'package:traqtrace_app/features/shared/hierarchy/screens/hierarchy/widgets/hierarchy_view.dart';
import 'package:traqtrace_app/features/shared/hierarchy/utils/hierarchy_epc_utils.dart';

class HierarchyScreen extends StatelessWidget {
  const HierarchyScreen({
    super.key,
    required this.rootEpc,
    required this.title,
  });

  final String rootEpc;
  final String title;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HierarchyCubit()..loadRoot(normalizeHierarchyEpc(rootEpc)),
      child: HierarchyView(rootEpc: rootEpc, title: title),
    );
  }
}
