import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/traq_app_bar.dart';
import 'package:traqtrace_app/features/shared/hierarchy/screens/hierarchy/cubit/hierarchy_cubit.dart';
import 'package:traqtrace_app/features/shared/hierarchy/screens/hierarchy/widgets/hierarchy_list.dart';
import 'package:traqtrace_app/features/shared/hierarchy/utils/hierarchy_epc_utils.dart';

class HierarchyView extends StatelessWidget {
  const HierarchyView({super.key, required this.rootEpc, required this.title});

  final String rootEpc;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TraqAppBar(context, title: Text(title)),
      drawer: const AppDrawer(),
      body: BlocBuilder<HierarchyCubit, HierarchyState>(
        builder: (context, state) {
          return switch (state) {
            HierarchyLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            HierarchyResolvingRoot() => const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text(
                    'Finding root container…',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
            HierarchyError(:final message) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(message, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<HierarchyCubit>().loadRoot(
                      normalizeHierarchyEpc(rootEpc),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            HierarchyLoaded(:final root, :final summary, :final highlightEpc) =>
              HierarchyList(
                root: root,
                summary: summary,
                highlightEpc: highlightEpc,
              ),
          };
        },
      ),
    );
  }
}
