import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/utils/gs1/check_digit_utils.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_anatomy.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_date_utils.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_element_string_builder.dart';
import 'package:traqtrace_app/core/utils/gs1/ndc_gtin_converter.dart';
import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_formatter.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_query_parameters_dto.dart';
import 'package:traqtrace_app/data/services/barcode/barcode_generation_service.dart';
import 'package:traqtrace_app/data/services/epcis/cbv_vocabulary_service.dart';
import 'package:traqtrace_app/data/services/epcis/epc_conversion_service.dart';
import 'package:traqtrace_app/data/services/epcis/epcis_serialization_service.dart';
import 'package:traqtrace_app/data/services/barcode/gs1_barcode_api_service.dart';
import 'package:traqtrace_app/data/services/barcode/epc_uri_converter.dart';
import 'package:traqtrace_app/data/services/barcode/gs1_barcode_parser.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_state.dart';
import 'package:traqtrace_app/features/gs1_tools/models/gs1_tool_kind.dart';
import 'package:traqtrace_app/features/gs1_tools/utils/epcis_import_validator.dart';
import 'package:traqtrace_app/features/shared/validation/gs1_batch_validator.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_slice.dart';

part 'gs1_tools_conversion_actions.dart';
part 'gs1_tools_validation_actions.dart';
part 'gs1_tools_barcode_actions.dart';
part 'gs1_tools_epcis_actions.dart';

class Gs1ToolsCubit extends Cubit<Gs1ToolsState> {
  Gs1ToolsCubit({
    required EPCConversionService epcConversionService,
    required BarcodeGenerationService barcodeGenerationService,
    required GS1BarcodeApiService gs1BarcodeApiService,
    required EPCISSerializationService serializationService,
    required CbvVocabularyService cbvVocabularyService,
    Gs1ToolKind initialTool = Gs1ToolKind.convert,
    String? initialMode,
  }) : _epc = epcConversionService,
       _barcodes = barcodeGenerationService,
       _verify = gs1BarcodeApiService,
       _serialization = serializationService,
       _cbvVocabulary = cbvVocabularyService,
       super(
         Gs1ToolsState(selectedTool: initialTool, initialMode: initialMode),
       );

  final EPCConversionService _epc;
  final BarcodeGenerationService _barcodes;
  final GS1BarcodeApiService _verify;
  final EPCISSerializationService _serialization;
  final CbvVocabularyService _cbvVocabulary;

  Future<({Set<String> bizSteps, Set<String> dispositions})>
  _loadCbvSets() async {
    final session = await _cbvVocabulary.ensureLoaded();
    final bizSteps = <String>{};
    final dispositions = <String>{};
    for (final step in session.bizSteps) {
      bizSteps.add(step.code);
      bizSteps.add(CbvVocabularyFormatter.shortName(step.urn));
    }
    for (final disp in session.dispositions) {
      dispositions.add(disp.code);
      dispositions.add(CbvVocabularyFormatter.shortName(disp.urn));
    }
    return (bizSteps: bizSteps, dispositions: dispositions);
  }

  void selectTool(Gs1ToolKind tool, {String? mode}) {
    if (state.selectedTool == tool && mode == null) return;
    emit(
      state.copyWith(
        selectedTool: tool,
        initialMode: mode,
        clearInitialMode: mode == null,
      ),
    );
  }

  void clearInitialMode() {
    if (state.initialMode == null) return;
    emit(state.copyWith(clearInitialMode: true));
  }

  // ─── Convert ──────────────────────────────────────────────────────────────

  void _emitError(Gs1ToolKind kind, String message) {
    emit(
      state.withSlice(
        kind,
        WorkbenchSlice(status: WorkbenchActionStatus.error, error: message),
      ),
    );
  }

  Future<void> _run(
    Gs1ToolKind kind,
    Future<WorkbenchSlice> Function() action,
  ) async {
    emit(
      state.withSlice(
        kind,
        state
            .sliceFor(kind)
            .copyWith(status: WorkbenchActionStatus.loading, clearError: true),
      ),
    );
    try {
      emit(state.withSlice(kind, await action()));
    } catch (e) {
      _emitError(kind, e.toString());
    }
  }

  String _safe(Object? value) {
    if (value == null) return '—';
    final text = value.toString().trim();
    if (text.isEmpty || text == 'null') return '—';
    return text;
  }
}
