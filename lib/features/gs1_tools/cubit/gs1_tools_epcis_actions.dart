import 'package:traqtrace_app/features/gs1_tools/utils/epcis_import_validation_result.dart';
import 'dart:convert';
import 'package:traqtrace_app/data/models/epcis/epcis_query_parameters_dto.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_cubit.dart';
import 'package:traqtrace_app/features/gs1_tools/models/gs1_tool_kind.dart';
import 'package:traqtrace_app/features/gs1_tools/utils/epcis_import_validator.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_slice.dart';

extension Gs1ToolsEpcisActions on Gs1ToolsCubit {
  Future<void> convertEpcisFormat({
    required String input,
    required String inputFormat,
    required String outputFormat,
  }) async {
    final text = input.trim();
    if (text.isEmpty) {
      emitError(Gs1ToolKind.serializeConvert, 'Enter input data to convert');
      return;
    }
    await run(Gs1ToolKind.serializeConvert, () async {
      late final String result;
      if (inputFormat == 'XML' && outputFormat == 'JSON-LD') {
        final jsonLd = await serialization.convertXmlToJsonLd(text);
        result = const JsonEncoder.withIndent('  ').convert(jsonLd);
      } else if (inputFormat == 'JSON-LD' && outputFormat == 'XML') {
        final jsonInput = jsonDecode(text) as Map<String, dynamic>;
        result = await serialization.convertJsonLdToXml(jsonInput);
      } else {
        throw Exception(
          'Conversion from $inputFormat to $outputFormat is not supported. '
          'Use XML ⇄ JSON-LD.',
        );
      }
      return WorkbenchSlice(
        status: WorkbenchActionStatus.success,
        resultText: result,
        resultFields: {'From': inputFormat, 'To': outputFormat},
      );
    });
  }

  Future<void> validateEpcisSchema({
    required String input,
    required String format,
  }) async {
    final text = input.trim();
    if (text.isEmpty) {
      emitError(Gs1ToolKind.serializeConvert, 'Enter data to validate');
      return;
    }
    await run(Gs1ToolKind.serializeConvert, () async {
      late final Map<String, dynamic> response;
      if (format.toUpperCase() == 'XML') {
        response = await serialization.validateXmlSchema(text);
      } else {
        final jsonInput = jsonDecode(text) as Map<String, dynamic>;
        response = await serialization.validateJsonSchema(jsonInput);
      }
      final valid = response['valid'] == true;
      final errors = response['errors'];
      final errorText = errors is List
          ? errors.map((e) => '$e').join('; ')
          : (errors?.toString() ?? '');
      return WorkbenchSlice(
        status: valid
            ? WorkbenchActionStatus.success
            : WorkbenchActionStatus.error,
        error: valid
            ? null
            : (errorText.isEmpty ? 'Document validation failed' : errorText),
        resultText: const JsonEncoder.withIndent('  ').convert(response),
        resultFields: {
          'Valid': valid ? 'Yes' : 'No',
          'Format': format.toUpperCase(),
          if (errorText.isNotEmpty) 'Errors': errorText,
        },
      );
    });
  }

  Future<void> exportEpcisEvents({
    required String format,
    String? startDate,
    String? endDate,
    String? epcs,
    String? businessSteps,
    String? businessLocations,
    String? limit,
  }) async {
    await run(Gs1ToolKind.serializeExport, () async {
      DateTime? startTime;
      DateTime? endTime;
      int? limitValue;
      final start = (startDate ?? '').trim();
      final end = (endDate ?? '').trim();
      if (start.isNotEmpty) startTime = DateTime.parse(start);
      if (end.isNotEmpty) endTime = DateTime.parse(end);
      final epcList = (epcs ?? '')
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      final stepList = (businessSteps ?? '')
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      final locationList = (businessLocations ?? '')
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      final limitRaw = (limit ?? '').trim();
      if (limitRaw.isNotEmpty) {
        limitValue = int.parse(limitRaw);
        if (limitValue <= 0) throw Exception('Limit must be a positive number');
      }
      final queryParams = EPCISQueryParametersDTO(
        startTime: startTime,
        endTime: endTime,
        epcs: epcList.isNotEmpty ? epcList : null,
        businessSteps: stepList.isNotEmpty ? stepList : null,
        businessLocations: locationList.isNotEmpty ? locationList : null,
        dispositions: const [],
        readPoints: const [],
        limit: limitValue,
      );
      switch (format.toUpperCase()) {
        case 'CSV':
          final csv = await serialization.exportToCsv(queryParams);
          return WorkbenchSlice(
            status: WorkbenchActionStatus.success,
            resultText: csv,
            resultFields: {'Format': 'CSV'},
          );
        case 'HTML':
          final html = await serialization.exportToHtml(queryParams);
          return WorkbenchSlice(
            status: WorkbenchActionStatus.success,
            resultText: html,
            resultFields: {'Format': 'HTML'},
          );
        case 'PDF':
          final bytes = await serialization.exportToPdf(queryParams);
          return WorkbenchSlice(
            status: WorkbenchActionStatus.success,
            resultText: 'PDF export (${bytes.length} bytes)',
            resultFields: {'Format': 'PDF', 'Bytes': '${bytes.length}'},
            meta: {'bytes': bytes},
          );
        case 'EXCEL':
          final bytes = await serialization.exportToExcel(queryParams);
          return WorkbenchSlice(
            status: WorkbenchActionStatus.success,
            resultText: 'Excel export (${bytes.length} bytes)',
            resultFields: {'Format': 'Excel', 'Bytes': '${bytes.length}'},
            meta: {'bytes': bytes},
          );
        default:
          throw Exception('Export format $format is not supported');
      }
    });
  }

  void clearImportValidation() {
    final slice = state.serializeImport;
    if (slice.meta['importValidated'] != true) return;
    emit(
      state.withSlice(
        Gs1ToolKind.serializeImport,
        slice.copyWith(meta: {...slice.meta, 'importValidated': false}),
      ),
    );
  }

  /// Runs format → schema → content gates. Does not write to the DB.
  Future<void> validateEpcisImport({required String input}) async {
    await run(Gs1ToolKind.serializeImport, () async {
      final cbvSets = await loadCbvSets();
      final local = EpcisImportValidator.validate(
        input,
        validBizSteps: cbvSets.bizSteps,
        validDispositions: cbvSets.dispositions,
      );
      if (!local.isValid) {
        return WorkbenchSlice(
          status: WorkbenchActionStatus.error,
          error: local.summarize(),
          resultText: local.summarize(),
          resultFields: {
            'Valid': 'No',
            'Format issues': '${local.forGate(EpcisImportGate.format).length}',
            'Schema issues': '${local.forGate(EpcisImportGate.schema).length}',
            'Content issues':
                '${local.forGate(EpcisImportGate.content).length}',
          },
          meta: {
            'importValidated': false,
            'validationSummary': local.summarize(),
          },
        );
      }

      // Official EPCIS JSON schema (backend) — second schema confirmation.
      final schemaResponse = await serialization.validateJsonSchema(
        local.document!,
      );
      final schemaValid = schemaResponse['valid'] == true;
      if (!schemaValid) {
        final errors = schemaResponse['errors'];
        final errorText = errors is List
            ? errors.map((e) => '$e').join('\n')
            : (errors?.toString() ?? 'Schema validation failed');
        return WorkbenchSlice(
          status: WorkbenchActionStatus.error,
          error: 'SCHEMA:\n$errorText',
          resultText: const JsonEncoder.withIndent(
            '  ',
          ).convert(schemaResponse),
          resultFields: const {'Valid': 'No', 'Gate': 'Schema (official)'},
          meta: const {'importValidated': false},
        );
      }

      return WorkbenchSlice(
        status: WorkbenchActionStatus.success,
        resultText: local.summarize(),
        resultFields: const {
          'Valid': 'Yes',
          'Format': 'EPCIS 2.0 JSON-LD',
          'Ready to import': 'Yes',
        },
        meta: {'importValidated': true, 'validatedDocument': local.document},
      );
    });
  }

  /// Import only after full conformance. Re-validates before any DB call.
  Future<void> importEpcisEvents({required String input}) async {
    final text = input.trim();
    if (text.isEmpty) {
      emitError(Gs1ToolKind.serializeImport, 'Enter an EPCIS document');
      return;
    }
    await run(Gs1ToolKind.serializeImport, () async {
      final cbvSets = await loadCbvSets();
      final local = EpcisImportValidator.validate(
        text,
        validBizSteps: cbvSets.bizSteps,
        validDispositions: cbvSets.dispositions,
      );
      if (!local.isValid) {
        throw Exception(
          'Import blocked — document does not conform:\n${local.summarize()}',
        );
      }

      final schemaResponse = await serialization.validateJsonSchema(
        local.document!,
      );
      if (schemaResponse['valid'] != true) {
        final errors = schemaResponse['errors'];
        final errorText = errors is List
            ? errors.map((e) => '$e').join('; ')
            : (errors?.toString() ?? 'Schema validation failed');
        throw Exception('Import blocked — schema gate failed: $errorText');
      }

      final result = await serialization.importEventsFromJsonLd(
        local.document!,
      );

      final processed =
          result['processed_events'] ??
          result['eventsImported'] ??
          result['processedEvents'] ??
          0;
      final total =
          result['total_events'] ?? result['totalEvents'] ?? processed;
      final failed = result['failed_events'] ?? result['failedEvents'] ?? 0;
      final status = result['status']?.toString() ?? '';
      final errors = result['errors'];
      final errorList = errors is List
          ? errors.map((e) => '$e').where((e) => e.isNotEmpty).toList()
          : <String>[];
      final ok =
          status.toUpperCase() == 'COMPLETED' &&
          errorList.isEmpty &&
          (failed == 0 || failed == '0');

      return WorkbenchSlice(
        status: ok
            ? WorkbenchActionStatus.success
            : WorkbenchActionStatus.error,
        error: ok
            ? null
            : (errorList.isEmpty
                  ? 'Import failed (status: $status)'
                  : errorList.join('; ')),
        resultText: const JsonEncoder.withIndent('  ').convert(result),
        resultFields: {
          'Imported': safe(processed),
          'Total': safe(total),
          'Failed': safe(failed),
          'Status': safe(status),
          'Format': 'JSON-LD',
          if (errorList.isNotEmpty) 'Errors': errorList.join('; '),
        },
        meta: {'importValidated': ok},
      );
    });
  }

  // ─── helpers ──────────────────────────────────────────────────────────────
}
