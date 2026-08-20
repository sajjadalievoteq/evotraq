import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_cubit.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_state.dart';
import 'package:traqtrace_app/features/gs1_tools/models/gs1_tool_kind.dart';
import 'package:traqtrace_app/features/gs1_tools/screens/gs1_tools/widgets/gs1_tool_panel.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_rail.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_scaffold.dart';

/// Unified GS1 Tools workbench: mode-driven tools + EPCIS Serialization.
class Gs1ToolsView extends StatelessWidget {
  const Gs1ToolsView({required this.groups});

  final List<WorkbenchRailGroup> groups;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Gs1ToolsCubit, Gs1ToolsState>(
      buildWhen: (p, c) => p.selectedTool != c.selectedTool,
      builder: (context, state) {
        return WorkbenchScaffold(
          title: 'GS1 Tools',
          groups: groups,
          selectedId: state.selectedTool.id,
          onSelect: (id) {
            String? mode;
            final tool = Gs1ToolKindX.fromId(id, onMode: (m) => mode = m);
            context.read<Gs1ToolsCubit>().selectTool(tool, mode: mode);
          },
          panelBuilder: (_, id) => Gs1ToolPanel(kind: Gs1ToolKindX.fromId(id)),
        );
      },
    );
  }
}
