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
import 'package:traqtrace_app/features/shared/workbench/workbench_rail.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_scaffold.dart';

/// Unified GS1 Tools workbench: mode-driven tools + EPCIS Serialization.
class Gs1ToolsScreen extends StatelessWidget {
  const Gs1ToolsScreen({super.key, this.initialTool, this.initialMode});

  final Gs1ToolKind? initialTool;
  final String? initialMode;

  static List<WorkbenchRailGroup> get railGroups => [
    WorkbenchRailGroup(
      title: 'Tools',
      items: [
        for (final kind in Gs1ToolKindX.toolKinds)
          WorkbenchRailItem(
            id: kind.id,
            iconAsset: _iconFor(kind),
            label: kind.label,
          ),
      ],
    ),
    WorkbenchRailGroup(
      title: 'EPCIS Serialization',
      items: [
        for (final kind in Gs1ToolKindX.serializationKinds)
          WorkbenchRailItem(
            id: kind.id,
            iconAsset: _iconFor(kind),
            label: kind.label,
          ),
      ],
    ),
  ];

  static String _iconFor(Gs1ToolKind kind) => switch (kind) {
    Gs1ToolKind.convert => NavIcons.conversion,
    Gs1ToolKind.validate => NavIcons.validation,
    Gs1ToolKind.build => NavIcons.systemTools,
    Gs1ToolKind.barcode => NavIcons.generateVerifyBarcode,
    Gs1ToolKind.aiElement => NavIcons.validationRules,
    Gs1ToolKind.ndc => NavIcons.gtin,
    Gs1ToolKind.lookup => NavIcons.integrationValidation,
    Gs1ToolKind.serializeConvert => NavIcons.conversion,
    Gs1ToolKind.serializeExport => NavIcons.bulkExport,
    Gs1ToolKind.serializeImport => NavIcons.eventSerialization,
  };

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => Gs1ToolsCubit(
        epcConversionService: getIt<EPCConversionService>(),
        barcodeGenerationService: getIt<BarcodeGenerationService>(),
        gs1BarcodeApiService: getIt<GS1BarcodeApiService>(),
        serializationService: getIt<EPCISSerializationService>(),
        cbvVocabularyService: getIt<CbvVocabularyService>(),
        initialTool: initialTool ?? Gs1ToolKind.convert,
        initialMode: initialMode,
      ),
      child: const _Gs1ToolsView(),
    );
  }
}

class _Gs1ToolsView extends StatelessWidget {
  const _Gs1ToolsView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Gs1ToolsCubit, Gs1ToolsState>(
      buildWhen: (p, c) => p.selectedTool != c.selectedTool,
      builder: (context, state) {
        return WorkbenchScaffold(
          title: 'GS1 Tools',
          groups: Gs1ToolsScreen.railGroups,
          selectedId: state.selectedTool.id,
          onSelect: (id) {
            String? mode;
            final tool = Gs1ToolKindX.fromId(id, onMode: (m) => mode = m);
            context.read<Gs1ToolsCubit>().selectTool(tool, mode: mode);
          },
          panelBuilder: (_, id) => _panelFor(Gs1ToolKindX.fromId(id)),
        );
      },
    );
  }

  Widget _panelFor(Gs1ToolKind kind) => switch (kind) {
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
