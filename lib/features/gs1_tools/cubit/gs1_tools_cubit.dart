import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/utils/gs1/check_digit_utils.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_query_parameters_dto.dart';
import 'package:traqtrace_app/data/services/barcode_generation_service.dart';
import 'package:traqtrace_app/data/services/epcis/epc_conversion_service.dart';
import 'package:traqtrace_app/data/services/epcis/epcis_serialization_service.dart';
import 'package:traqtrace_app/data/services/gs1_barcode_api_service.dart';
import 'package:traqtrace_app/features/barcode/services/epc_uri_converter.dart';
import 'package:traqtrace_app/features/barcode/services/gs1_barcode_parser.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_state.dart';
import 'package:traqtrace_app/features/gs1_tools/models/gs1_tool_kind.dart';
import 'package:traqtrace_app/features/shared/validation/gs1_batch_validator.dart';
import 'package:traqtrace_app/features/shared/validation/gs1_identifier_validation.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_slice.dart';

class Gs1ToolsCubit extends Cubit<Gs1ToolsState> {
  Gs1ToolsCubit({
    required EPCConversionService epcConversionService,
    required BarcodeGenerationService barcodeGenerationService,
    required GS1BarcodeApiService gs1BarcodeApiService,
    required EPCISSerializationService serializationService,
    Gs1ToolKind initialTool = Gs1ToolKind.checkDigit,
  })  : _epc = epcConversionService,
        _barcodes = barcodeGenerationService,
        _verify = gs1BarcodeApiService,
        _serialization = serializationService,
        super(Gs1ToolsState(selectedTool: initialTool));

  final EPCConversionService _epc;
  final BarcodeGenerationService _barcodes;
  final GS1BarcodeApiService _verify;
  final EPCISSerializationService _serialization;

  static const _fnc1 = '\u001D';
  static const _knownAiIds = {
    '00',
    '01',
    '02',
    '10',
    '11',
    '13',
    '15',
    '17',
    '21',
    '30',
    '310',
    '400',
    '401',
    '402',
    '414',
    '415',
    '420',
    '421',
    '422',
  };

  void selectTool(Gs1ToolKind tool) {
    if (state.selectedTool == tool) return;
    emit(state.copyWith(selectedTool: tool));
  }

  // ─── Check Digit ──────────────────────────────────────────────────────────

  void computeCheckDigit({
    required String input,
    required String kind, // gtin | gln | sscc
  }) {
    final lengths = switch (kind) {
      'gln' => CheckDigitUtils.glnLengths,
      'sscc' => CheckDigitUtils.ssccLengths,
      _ => CheckDigitUtils.gtinLengths,
    };
    final result = CheckDigitUtils.compute(input: input, fullLengths: lengths);
    if (result.checkDigit < 0 || result.fullNumber.isEmpty) {
      emit(
        state.withSlice(
          Gs1ToolKind.checkDigit,
          const WorkbenchSlice(
            status: WorkbenchActionStatus.error,
            error:
                'Enter a valid-length body or full identifier (GTIN 8/12/13/14, GLN 13, SSCC 18).',
          ),
        ),
      );
      return;
    }

    emit(
      state.withSlice(
        Gs1ToolKind.checkDigit,
        WorkbenchSlice(
          status: WorkbenchActionStatus.success,
          resultText: result.fullNumber,
          resultFields: {
            'Check digit': '${result.checkDigit}',
            'Valid': result.wasValid ? 'Yes' : 'No (corrected)',
            'Full number': result.fullNumber,
            'Kind': kind.toUpperCase(),
          },
        ),
      ),
    );
  }

  // ─── EPC Conversion ───────────────────────────────────────────────────────

  Future<void> convertSgtinToEpc({
    required String gtin,
    required String serial,
  }) async {
    final gtinErr = CheckDigitUtils.validateGS1CheckDigit(
      gtin,
      allowedLengths: CheckDigitUtils.gtinLengths,
      label: 'GTIN',
    );
    if (gtinErr != null) {
      _emitError(Gs1ToolKind.epcConversion, gtinErr);
      return;
    }
    if (serial.trim().isEmpty) {
      _emitError(Gs1ToolKind.epcConversion, 'Serial is required');
      return;
    }
    await _run(Gs1ToolKind.epcConversion, () async {
      final uri = await _epc.convertSGTINToEPC(gtin.trim(), serial.trim());
      return WorkbenchSlice(
        status: WorkbenchActionStatus.success,
        resultText: _safe(uri),
        resultFields: {'EPC URI': _safe(uri)},
      );
    });
  }

  Future<void> convertSsccToEpc(String sscc) async {
    final err = CheckDigitUtils.validateGS1CheckDigit(
      sscc,
      allowedLengths: CheckDigitUtils.ssccLengths,
      label: 'SSCC',
    );
    if (err != null) {
      _emitError(Gs1ToolKind.epcConversion, err);
      return;
    }
    await _run(Gs1ToolKind.epcConversion, () async {
      final uri = await _epc.convertSSCCToEPC(sscc.trim());
      return WorkbenchSlice(
        status: WorkbenchActionStatus.success,
        resultText: _safe(uri),
        resultFields: {'EPC URI': _safe(uri)},
      );
    });
  }

  Future<void> convertGlnToEpc({
    required String gln,
    String? extension,
  }) async {
    final err = CheckDigitUtils.validateGS1CheckDigit(
      gln,
      allowedLengths: CheckDigitUtils.glnLengths,
      label: 'GLN',
    );
    if (err != null) {
      _emitError(Gs1ToolKind.epcConversion, err);
      return;
    }
    await _run(Gs1ToolKind.epcConversion, () async {
      final ext = (extension ?? '').trim();
      final uri = await _epc.convertGLNToEPC(
        gln.trim(),
        ext.isEmpty ? null : ext,
      );
      return WorkbenchSlice(
        status: WorkbenchActionStatus.success,
        resultText: _safe(uri),
        resultFields: {'EPC URI': _safe(uri)},
      );
    });
  }

  Future<void> convertEpcToGs1({
    required String epcUri,
    required String type,
  }) async {
    final uri = epcUri.trim();
    if (uri.isEmpty) {
      _emitError(Gs1ToolKind.epcConversion, 'EPC URI is required');
      return;
    }
    await _run(Gs1ToolKind.epcConversion, () async {
      switch (type.toUpperCase()) {
        case 'SSCC':
          final sscc = await _epc.convertEPCToSSCC(uri);
          return WorkbenchSlice(
            status: WorkbenchActionStatus.success,
            resultText: _safe(sscc),
            resultFields: {'SSCC': _safe(sscc)},
          );
        case 'GLN':
          final gln = await _epc.convertEPCToGLN(uri);
          return WorkbenchSlice(
            status: WorkbenchActionStatus.success,
            resultText: _safe(gln),
            resultFields: {'GLN': _safe(gln)},
          );
        default:
          final result = await _epc.convertEPCToSGTIN(uri);
          final gtin = _safe(result['gtin']);
          final serial = _safe(result['serial']);
          return WorkbenchSlice(
            status: WorkbenchActionStatus.success,
            resultText: 'GTIN: $gtin\nSerial: $serial',
            resultFields: {'GTIN': gtin, 'Serial': serial},
          );
      }
    });
  }

  Future<void> convertElementStringToEpc(String elementString) async {
    if (elementString.trim().isEmpty) {
      _emitError(Gs1ToolKind.epcConversion, 'Element string is required');
      return;
    }
    await _run(Gs1ToolKind.epcConversion, () async {
      final uri =
          await _epc.convertGS1ElementStringToEPC(elementString.trim());
      return WorkbenchSlice(
        status: WorkbenchActionStatus.success,
        resultText: _safe(uri),
        resultFields: {'EPC URI': _safe(uri)},
      );
    });
  }

  // ─── Digital Link ─────────────────────────────────────────────────────────

  void buildDigitalLink({
    required String kind, // gtin | sgtin | sscc | gln
    required String primary,
    String? serial,
    String? lot,
    String? extension,
  }) {
    String? err;
    String? uri;

    switch (kind) {
      case 'sscc':
        err = CheckDigitUtils.validateGS1CheckDigit(
          primary,
          allowedLengths: CheckDigitUtils.ssccLengths,
          label: 'SSCC',
        );
        if (err == null) {
          uri = EPCURIConverter.convertSSCCToEPCUri(primary);
        }
      case 'gln':
        err = CheckDigitUtils.validateGS1CheckDigit(
          primary,
          allowedLengths: CheckDigitUtils.glnLengths,
          label: 'GLN',
        );
        if (err == null) {
          uri = EPCURIConverter.convertGLNToEPCUri(
            primary,
            extension: (extension ?? '0').trim().isEmpty
                ? '0'
                : extension!.trim(),
          );
        }
      case 'sgtin':
        err = CheckDigitUtils.validateGS1CheckDigit(
          primary,
          allowedLengths: CheckDigitUtils.gtinLengths,
          label: 'GTIN',
        );
        if (err == null && (serial ?? '').trim().isEmpty) {
          err = 'Serial is required for SGTIN Digital Link';
        }
        if (err == null) {
          uri = EPCURIConverter.convertGTINSerialToEPCUri(
            primary,
            serial!.trim(),
          );
        }
      default:
        err = CheckDigitUtils.validateGS1CheckDigit(
          primary,
          allowedLengths: CheckDigitUtils.gtinLengths,
          label: 'GTIN',
        );
        if (err == null) {
          final lotValue = (lot ?? '').trim();
          uri = lotValue.isEmpty
              ? EPCURIConverter.convertGTINToClassEPCUri(primary)
              : EPCURIConverter.convertGTINLotToLGTINEpcUri(primary, lotValue);
        }
    }

    if (err != null) {
      _emitError(Gs1ToolKind.digitalLink, err);
      return;
    }
    if (uri == null || uri.isEmpty) {
      _emitError(Gs1ToolKind.digitalLink, 'Unable to build Digital Link');
      return;
    }

    emit(
      state.withSlice(
        Gs1ToolKind.digitalLink,
        WorkbenchSlice(
          status: WorkbenchActionStatus.success,
          resultText: uri,
          resultFields: {
            'Digital Link': uri,
            'Type': EPCURIConverter.getEPCType(uri) ?? 'unknown',
          },
        ),
      ),
    );
  }

  void parseDigitalLink(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      _emitError(Gs1ToolKind.digitalLink, 'Paste a Digital Link URL or URN');
      return;
    }

    final normalized = EPCURIConverter.normalizeForStorage(trimmed);
    final type = EPCURIConverter.getEPCType(normalized);
    final fields = <String, String>{
      'Normalized': _safe(normalized),
      'Type': _safe(type),
    };

    final gtin = EPCURIConverter.extractGTINFromEPCUri(normalized);
    final serial = EPCURIConverter.extractSerialFromEPCUri(normalized);
    final sscc = EPCURIConverter.extractSSCCFromEPCUri(normalized);
    if (gtin != null) fields['GTIN'] = gtin;
    if (serial != null) fields['Serial'] = serial;
    if (sscc != null) fields['SSCC'] = sscc;

    final dlMatch = RegExp(
      r'^https://id\.gs1\.org/(?:01|00|414)/([^/]+)(?:/(\d{2,4})/(.+))?$',
    ).firstMatch(normalized);
    if (dlMatch != null) {
      fields['Primary AI value'] = dlMatch.group(1)!;
      if (dlMatch.group(2) != null) {
        fields['Qualifier AI (${dlMatch.group(2)})'] =
            Uri.decodeComponent(dlMatch.group(3)!);
      }
    }

    if (fields.length <= 2 && type == null) {
      _emitError(
        Gs1ToolKind.digitalLink,
        'Unrecognized Digital Link / URN format',
      );
      return;
    }

    emit(
      state.withSlice(
        Gs1ToolKind.digitalLink,
        WorkbenchSlice(
          status: WorkbenchActionStatus.success,
          resultText: _safe(normalized),
          resultFields: fields,
        ),
      ),
    );
  }

  // ─── AI Parser ────────────────────────────────────────────────────────────

  void parseElementString(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      _emitError(Gs1ToolKind.aiParser, 'Paste a GS1 element string');
      return;
    }

    final parsed = GS1BarcodeParser.parseGS1Barcode(trimmed);
    final ais = (parsed['parsedData'] as Map?)?.cast<String, String>() ?? {};
    final human =
        (parsed['humanReadable'] as Map?)?.cast<String, String>() ?? {};
    final unknown = <String>[];
    final fields = <String, String>{};

    ais.forEach((ai, value) {
      final label = human.entries
          .firstWhere(
            (e) => e.value == value,
            orElse: () => MapEntry('($ai)', value),
          )
          .key;
      fields['AI $ai — $label'] = _safe(value);
      if (!_knownAiIds.contains(ai)) {
        unknown.add(ai);
      }
    });

    if (ais.isEmpty) {
      _emitError(Gs1ToolKind.aiParser, 'No Application Identifiers found');
      return;
    }

    final checkErrors =
        (parsed['checkDigitErrors'] as List?)?.map((e) => '$e').toList() ?? [];

    emit(
      state.withSlice(
        Gs1ToolKind.aiParser,
        WorkbenchSlice(
          status: WorkbenchActionStatus.success,
          resultText: fields.entries.map((e) => '${e.key}: ${e.value}').join('\n'),
          resultFields: {
            ...fields,
            'Valid': (parsed['valid'] == true) ? 'Yes' : 'No',
            if (unknown.isNotEmpty) 'Unknown AIs': unknown.join(', '),
            if (checkErrors.isNotEmpty)
              'Check digit issues': checkErrors.join('; '),
          },
          meta: {'ais': ais},
        ),
      ),
    );
  }

  void buildElementString(Map<String, String> ais) {
    final cleaned = <String, String>{};
    for (final entry in ais.entries) {
      final ai = entry.key.trim();
      final value = entry.value.trim();
      if (ai.isEmpty || value.isEmpty) continue;
      cleaned[ai] = value;
    }
    if (cleaned.isEmpty) {
      _emitError(Gs1ToolKind.aiParser, 'Enter at least one AI and value');
      return;
    }

    final fixed = const {'00', '01', '02', '11', '12', '13', '15', '16', '17'};
    final buffer = StringBuffer();
    final human = StringBuffer();
    var first = true;
    cleaned.forEach((ai, value) {
      if (!first && !fixed.contains(ai)) {
        buffer.write(_fnc1);
      }
      buffer.write(ai);
      buffer.write(value);
      human.write('($ai)$value');
      first = false;
    });

    emit(
      state.withSlice(
        Gs1ToolKind.aiParser,
        WorkbenchSlice(
          status: WorkbenchActionStatus.success,
          resultText: buffer.toString(),
          resultFields: {
            'Element string (FNC1)': buffer.toString().replaceAll(_fnc1, '|'),
            'Human readable': human.toString(),
          },
        ),
      ),
    );
  }

  // ─── Barcode Generate / Verify ────────────────────────────────────────────

  Future<void> generateDataMatrix(String elementString, {int size = 300}) async {
    if (elementString.trim().isEmpty) {
      _emitError(Gs1ToolKind.barcode, 'GS1 element string is required');
      return;
    }
    await _run(Gs1ToolKind.barcode, () async {
      final bytes = await _barcodes.generateDataMatrix(
        gs1ElementString: elementString.trim(),
        width: size,
        height: size,
      );
      return WorkbenchSlice(
        status: WorkbenchActionStatus.success,
        imageBytes: bytes,
        resultText: 'GS1 DataMatrix generated',
        meta: {'format': 'datamatrix'},
      );
    });
  }

  Future<void> generateGs1128(String elementString) async {
    if (elementString.trim().isEmpty) {
      _emitError(Gs1ToolKind.barcode, 'GS1 element string is required');
      return;
    }
    await _run(Gs1ToolKind.barcode, () async {
      final bytes = await _barcodes.generateGS1128(
        gs1ElementString: elementString.trim(),
      );
      return WorkbenchSlice(
        status: WorkbenchActionStatus.success,
        imageBytes: bytes,
        resultText: 'GS1-128 generated',
        meta: {'format': 'gs1-128'},
      );
    });
  }

  Future<void> generateSgtinDataMatrix({
    required String gtin,
    required String serial,
    String? expiry,
    String? batch,
  }) async {
    final err = CheckDigitUtils.validateGS1CheckDigit(
      gtin,
      allowedLengths: CheckDigitUtils.gtinLengths,
      label: 'GTIN',
    );
    if (err != null) {
      _emitError(Gs1ToolKind.barcode, err);
      return;
    }
    if (serial.trim().isEmpty) {
      _emitError(Gs1ToolKind.barcode, 'Serial is required');
      return;
    }
    await _run(Gs1ToolKind.barcode, () async {
      final bytes = await _barcodes.generateSGTINDataMatrix(
        gtin: gtin.trim(),
        serialNumber: serial.trim(),
        expiryDate: (expiry ?? '').trim().isEmpty ? null : expiry!.trim(),
        batchLot: (batch ?? '').trim().isEmpty ? null : batch!.trim(),
      );
      return WorkbenchSlice(
        status: WorkbenchActionStatus.success,
        imageBytes: bytes,
        resultText: 'SGTIN DataMatrix generated',
        meta: {'format': 'sgtin-datamatrix'},
      );
    });
  }

  Future<void> generateSsccBarcode(String sscc, {String format = 'gs1-128'}) async {
    final err = CheckDigitUtils.validateGS1CheckDigit(
      sscc,
      allowedLengths: CheckDigitUtils.ssccLengths,
      label: 'SSCC',
    );
    if (err != null) {
      _emitError(Gs1ToolKind.barcode, err);
      return;
    }
    await _run(Gs1ToolKind.barcode, () async {
      final bytes = await _barcodes.generateSSCCBarcode(
        sscc: sscc.trim(),
        format: format,
      );
      return WorkbenchSlice(
        status: WorkbenchActionStatus.success,
        imageBytes: bytes,
        resultText: 'SSCC barcode generated',
        meta: {'format': format},
      );
    });
  }

  Future<void> verifyBarcode(String elementString) async {
    if (elementString.trim().isEmpty) {
      _emitError(Gs1ToolKind.barcode, 'Barcode / element string is required');
      return;
    }
    await _run(Gs1ToolKind.barcode, () async {
      final local = GS1BarcodeParser.parseGS1Barcode(elementString.trim());
      final remote = await _verify.verifyGS1Barcode(elementString.trim());
      final fields = <String, String>{
        'Local valid': local['valid'] == true ? 'Yes' : 'No',
        'Local GTIN': _safe(local['GTIN']),
        'Local Serial': _safe(local['SERIAL']),
        'Local SSCC': _safe(local['SSCC']),
        'Local GLN': _safe(local['GLN']),
      };
      remote.forEach((key, value) {
        fields['API $key'] = _safe(value);
      });
      final checkErrors =
          (local['checkDigitErrors'] as List?)?.map((e) => '$e').toList();
      if (checkErrors != null && checkErrors.isNotEmpty) {
        fields['Check digit issues'] = checkErrors.join('; ');
      }
      return WorkbenchSlice(
        status: WorkbenchActionStatus.success,
        resultText:
            fields.entries.map((e) => '${e.key}: ${e.value}').join('\n'),
        resultFields: fields,
      );
    });
  }

  // ─── Validator / Identifier ───────────────────────────────────────────────

  void validateIdentifiers({
    String? gtin,
    String? gln,
    String? sscc,
    String? sgtin,
    Gs1ToolKind target = Gs1ToolKind.validator,
  }) {
    final kind = target == Gs1ToolKind.identifier
        ? Gs1ToolKind.identifier
        : Gs1ToolKind.validator;
    emit(
      state.withSlice(
        kind,
        Gs1IdentifierValidation.validate(
          gtin: gtin,
          gln: gln,
          sscc: sscc,
          sgtin: sgtin,
        ),
      ),
    );
  }

  void validateBatch(String paste) {
    final trimmed = paste.trim();
    if (trimmed.isEmpty) {
      _emitError(
        Gs1ToolKind.batch,
        'Paste one or more identifiers (one per line or CSV).',
      );
      return;
    }
    final rows = Gs1BatchValidator.validatePaste(trimmed);
    if (rows.isEmpty) {
      _emitError(Gs1ToolKind.batch, 'No identifiers found in input.');
      return;
    }
    final fields = <String, String>{};
    for (final row in rows) {
      final key = '#${row.lineNumber} ${row.type}';
      fields[key] = row.isValid
          ? 'PASS — ${row.message}'
          : 'FAIL — ${row.message}';
    }
    final passed = rows.where((r) => r.isValid).length;
    emit(
      state.withSlice(
        Gs1ToolKind.batch,
        WorkbenchSlice(
          status: WorkbenchActionStatus.success,
          resultText: '$passed / ${rows.length} passed',
          resultFields: fields,
        ),
      ),
    );
  }

  // ─── EPCIS Serialization ──────────────────────────────────────────────────

  Future<void> convertEpcisFormat({
    required String input,
    required String inputFormat,
    required String outputFormat,
  }) async {
    final text = input.trim();
    if (text.isEmpty) {
      _emitError(Gs1ToolKind.serializeConvert, 'Enter input data to convert');
      return;
    }
    await _run(Gs1ToolKind.serializeConvert, () async {
      late final String result;
      if (inputFormat == 'XML' && outputFormat == 'JSON-LD') {
        final jsonLd = await _serialization.convertXmlToJsonLd(text);
        result = const JsonEncoder.withIndent('  ').convert(jsonLd);
      } else if (inputFormat == 'JSON-LD' && outputFormat == 'XML') {
        final jsonInput = jsonDecode(text) as Map<String, dynamic>;
        result = await _serialization.convertJsonLdToXml(jsonInput);
      } else {
        throw Exception(
          'Conversion from $inputFormat to $outputFormat is not supported. '
          'Use XML ⇄ JSON-LD.',
        );
      }
      return WorkbenchSlice(
        status: WorkbenchActionStatus.success,
        resultText: result,
        resultFields: {
          'From': inputFormat,
          'To': outputFormat,
        },
      );
    });
  }

  Future<void> validateEpcisSchema({
    required String input,
    required String format,
  }) async {
    final text = input.trim();
    if (text.isEmpty) {
      _emitError(Gs1ToolKind.serializeValidate, 'Enter data to validate');
      return;
    }
    await _run(Gs1ToolKind.serializeValidate, () async {
      late final Map<String, dynamic> response;
      if (format.toUpperCase() == 'XML') {
        response = await _serialization.validateXmlSchema(text);
      } else {
        final jsonInput = jsonDecode(text) as Map<String, dynamic>;
        response = await _serialization.validateJsonSchema(jsonInput);
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
    await _run(Gs1ToolKind.serializeExport, () async {
      DateTime? startTime;
      DateTime? endTime;
      int? limitValue;

      final start = (startDate ?? '').trim();
      final end = (endDate ?? '').trim();
      if (start.isNotEmpty) {
        startTime = DateTime.parse(start);
      }
      if (end.isNotEmpty) {
        endTime = DateTime.parse(end);
      }
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
        if (limitValue <= 0) {
          throw Exception('Limit must be a positive number');
        }
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
          final csv = await _serialization.exportToCsv(queryParams);
          final lines = csv.split('\n').where((l) => l.trim().isNotEmpty);
          return WorkbenchSlice(
            status: WorkbenchActionStatus.success,
            resultText: csv,
            resultFields: {
              'Format': 'CSV',
              'Rows': '${lines.length}',
            },
          );
        case 'HTML':
          final html = await _serialization.exportToHtml(queryParams);
          return WorkbenchSlice(
            status: WorkbenchActionStatus.success,
            resultText: html,
            resultFields: {'Format': 'HTML'},
          );
        case 'PDF':
          final bytes = await _serialization.exportToPdf(queryParams);
          return WorkbenchSlice(
            status: WorkbenchActionStatus.success,
            resultText: 'PDF export (${bytes.length} bytes)',
            resultFields: {
              'Format': 'PDF',
              'Bytes': '${bytes.length}',
            },
            meta: {'bytes': bytes},
          );
        case 'EXCEL':
          final bytes = await _serialization.exportToExcel(queryParams);
          return WorkbenchSlice(
            status: WorkbenchActionStatus.success,
            resultText: 'Excel export (${bytes.length} bytes)',
            resultFields: {
              'Format': 'Excel',
              'Bytes': '${bytes.length}',
            },
            meta: {'bytes': bytes},
          );
        default:
          throw Exception('Export format $format is not supported');
      }
    });
  }

  Future<void> importEpcisEvents({
    required String input,
    required String format,
  }) async {
    final text = input.trim();
    if (text.isEmpty) {
      _emitError(
        Gs1ToolKind.serializeImport,
        'Enter an EPCIS document to import',
      );
      return;
    }
    await _run(Gs1ToolKind.serializeImport, () async {
      late final Map<String, dynamic> result;
      if (format.toUpperCase() == 'XML') {
        result = await _serialization.importEventsFromXml(text);
      } else {
        final jsonInput = jsonDecode(text) as Map<String, dynamic>;
        result = await _serialization.importEventsFromJsonLd(jsonInput);
      }
      final eventsImported =
          result['eventsImported'] ?? result['totalEvents'] ?? 0;
      final eventsSkipped =
          result['eventsSkipped'] ?? result['duplicates'] ?? 0;
      final errors = result['errors'];
      final errorList = errors is List
          ? errors.map((e) => '$e').where((e) => e.isNotEmpty).toList()
          : <String>[];
      return WorkbenchSlice(
        status: errorList.isEmpty
            ? WorkbenchActionStatus.success
            : WorkbenchActionStatus.error,
        error: errorList.isEmpty ? null : errorList.join('; '),
        resultText: const JsonEncoder.withIndent('  ').convert(result),
        resultFields: {
          'Imported': _safe(eventsImported),
          'Skipped': _safe(eventsSkipped),
          'Format': format.toUpperCase(),
          if (errorList.isNotEmpty) 'Errors': errorList.join('; '),
        },
      );
    });
  }

  // ─── helpers ──────────────────────────────────────────────────────────────

  void _emitError(Gs1ToolKind kind, String message) {
    emit(
      state.withSlice(
        kind,
        WorkbenchSlice(
          status: WorkbenchActionStatus.error,
          error: message,
        ),
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
        state.sliceFor(kind).copyWith(
              status: WorkbenchActionStatus.loading,
              clearError: true,
            ),
      ),
    );
    try {
      final result = await action();
      emit(state.withSlice(kind, result));
    } catch (e) {
      _emitError(kind, e.toString());
    }
  }

  static String _safe(Object? value) {
    if (value == null) return '—';
    final text = value.toString().trim();
    if (text.isEmpty || text == 'null') return '—';
    return text;
  }
}
