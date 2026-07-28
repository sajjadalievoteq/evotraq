import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/services/barcode_generation_service.dart';
import 'package:traqtrace_app/data/services/epcis/epc_conversion_service.dart';
import 'package:traqtrace_app/data/services/epcis/epcis_serialization_service.dart';
import 'package:traqtrace_app/data/services/gs1_barcode_api_service.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_cubit.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_state.dart';
import 'package:traqtrace_app/features/gs1_tools/models/gs1_tool_kind.dart';
import 'package:traqtrace_app/features/gs1_tools/widgets/tools/ai_parser_tool.dart';
import 'package:traqtrace_app/features/gs1_tools/widgets/tools/barcode_tool.dart';
import 'package:traqtrace_app/features/gs1_tools/widgets/tools/batch_validation_tool.dart';
import 'package:traqtrace_app/features/gs1_tools/widgets/tools/check_digit_tool.dart';
import 'package:traqtrace_app/features/gs1_tools/widgets/tools/digital_link_tool.dart';
import 'package:traqtrace_app/features/gs1_tools/widgets/tools/epc_conversion_tool.dart';
import 'package:traqtrace_app/features/gs1_tools/widgets/tools/identifier_validation_tool.dart';
import 'package:traqtrace_app/features/gs1_tools/widgets/tools/serialize_convert_tool.dart';
import 'package:traqtrace_app/features/gs1_tools/widgets/tools/serialize_export_tool.dart';
import 'package:traqtrace_app/features/gs1_tools/widgets/tools/serialize_import_tool.dart';
import 'package:traqtrace_app/features/gs1_tools/widgets/tools/serialize_validate_tool.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_rail.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_scaffold.dart';

/// Unified GS1 Tools workbench: Tools + Validation + EPCIS Serialization.
class Gs1ToolsScreen extends StatelessWidget {
  const Gs1ToolsScreen({super.key, this.initialTool});

  final Gs1ToolKind? initialTool;

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
          title: 'Validation',
          items: [
            for (final kind in Gs1ToolKindX.validationKinds)
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
        Gs1ToolKind.checkDigit => NavIcons.validation,
        Gs1ToolKind.epcConversion => NavIcons.epcConversion,
        Gs1ToolKind.digitalLink => NavIcons.conversion,
        Gs1ToolKind.aiParser => NavIcons.validationRules,
        Gs1ToolKind.barcode => NavIcons.generateVerifyBarcode,
        Gs1ToolKind.validator => NavIcons.gs1ValidationDemo,
        Gs1ToolKind.identifier => NavIcons.validation,
        Gs1ToolKind.batch => NavIcons.gs1ValidationTests,
        Gs1ToolKind.serializeConvert => NavIcons.conversion,
        Gs1ToolKind.serializeValidate => NavIcons.validation,
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
        initialTool: initialTool ?? Gs1ToolKind.checkDigit,
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
          onSelect: (id) => context.read<Gs1ToolsCubit>().selectTool(
                Gs1ToolKindX.fromId(id),
              ),
          panelBuilder: (_, id) => _toolPanel(Gs1ToolKindX.fromId(id)),
        );
      },
    );
  }

  Widget _toolPanel(Gs1ToolKind kind) => switch (kind) {
        Gs1ToolKind.checkDigit => const CheckDigitTool(),
        Gs1ToolKind.epcConversion => const EpcConversionTool(),
        Gs1ToolKind.digitalLink => const DigitalLinkTool(),
        Gs1ToolKind.aiParser => const AiParserTool(),
        Gs1ToolKind.barcode => const BarcodeTool(),
        Gs1ToolKind.validator =>
          const IdentifierValidationTool(target: Gs1ToolKind.validator),
        Gs1ToolKind.identifier =>
          const IdentifierValidationTool(target: Gs1ToolKind.identifier),
        Gs1ToolKind.batch => const BatchValidationTool(),
        Gs1ToolKind.serializeConvert => const SerializeConvertTool(),
        Gs1ToolKind.serializeValidate => const SerializeValidateTool(),
        Gs1ToolKind.serializeExport => const SerializeExportTool(),
        Gs1ToolKind.serializeImport => const SerializeImportTool(),
      };
}
