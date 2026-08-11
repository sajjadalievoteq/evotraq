import 'package:flutter/material.dart';
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

class Gs1ToolPanel extends StatelessWidget {
  const Gs1ToolPanel({required this.kind, super.key});

  final Gs1ToolKind kind;

  @override
  Widget build(BuildContext context) {
    return switch (kind) {
      Gs1ToolKind.convert => const ConvertTool(),
      Gs1ToolKind.validate => const ValidateTool(),
      Gs1ToolKind.build => const BuildTool(),
      Gs1ToolKind.barcode => const BarcodeTool(),
      Gs1ToolKind.aiElement => const AiElementTool(),
      Gs1ToolKind.ndc => const NdcTool(),
      Gs1ToolKind.lookup => const LookupTool(),
      Gs1ToolKind.serializeConvert => const SerializeConvertTool(),
      Gs1ToolKind.serializeExport => const SerializeExportTool(),
      Gs1ToolKind.serializeImport => const SerializeImportTool(),
    };
  }
}
