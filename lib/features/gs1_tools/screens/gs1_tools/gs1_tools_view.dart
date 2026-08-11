import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/services/barcode/barcode_generation_service.dart';
import 'package:traqtrace_app/data/services/epcis/cbv_vocabulary_service.dart';
import 'package:traqtrace_app/data/services/epcis/epc_conversion_service.dart';
import 'package:traqtrace_app/data/services/epcis/epcis_serialization_service.dart';
import 'package:traqtrace_app/data/services/barcode/gs1_barcode_api_service.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_cubit.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_state.dart';
import 'package:traqtrace_app/features/gs1_tools/models/gs1_tool_kind.dart';
import 'package:traqtrace_app/features/gs1_tools/screens/gs1_tools/widgets/ai_element_tool.dart';
import 'package:traqtrace_app/features/gs1_tools/screens/gs1_tools/widgets/barcode_tool.dart';
import 'package:traqtrace_app/features/gs1_tools/screens/gs1_tools/widgets/build_tool.dart';
import 'package:traqtrace_app/features/gs1_tools/screens/gs1_tools/widgets/convert_tool.dart';
import 'package:traqtrace_app/features/gs1_tools/screens/gs1_tools/widgets/lookup_tool.dart';
import 'package:traqtrace_app/features/gs1_tools/screens/gs1_tools/widgets/ndc_tool.dart';
import 'package:traqtrace_app/features/gs1_tools/screens/gs1_tools/widgets/serialize_convert_tool.dart';
import 'package:traqtrace_app/features/gs1_tools/screens/gs1_tools/widgets/serialize_export_tool.dart';
import 'package:traqtrace_app/features/gs1_tools/screens/gs1_tools/widgets/serialize_import_tool.dart';
import 'package:traqtrace_app/features/gs1_tools/screens/gs1_tools/widgets/validate_tool.dart';
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
