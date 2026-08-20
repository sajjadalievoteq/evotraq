import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1_tools/screens/gs1_tools/gs1_tools_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/services/barcode/barcode_generation_service.dart';
import 'package:traqtrace_app/data/services/epcis/cbv_vocabulary_service.dart';
import 'package:traqtrace_app/data/services/epcis/epc_conversion_service.dart';
import 'package:traqtrace_app/data/services/epcis/epcis_serialization_service.dart';
import 'package:traqtrace_app/data/services/barcode/gs1_barcode_api_service.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_cubit.dart';
import 'package:traqtrace_app/features/gs1_tools/models/gs1_tool_kind.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_rail.dart';

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
      child: Gs1ToolsView(groups: railGroups),
    );
  }
}
