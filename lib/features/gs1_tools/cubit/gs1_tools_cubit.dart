import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/utils/gs1/check_digit_utils.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_anatomy.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_date_utils.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_element_string_builder.dart';
import 'package:traqtrace_app/core/utils/gs1/ndc_gtin_converter.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_query_parameters_dto.dart';
import 'package:traqtrace_app/data/services/barcode_generation_service.dart';
import 'package:traqtrace_app/data/services/epcis/epc_conversion_service.dart';
import 'package:traqtrace_app/data/services/epcis/epcis_serialization_service.dart';
import 'package:traqtrace_app/data/services/gs1_barcode_api_service.dart';
import 'package:traqtrace_app/features/barcode/services/epc_uri_converter.dart';
import 'package:traqtrace_app/features/barcode/services/gs1_barcode_parser.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_state.dart';
import 'package:traqtrace_app/features/gs1_tools/models/gs1_tool_kind.dart';
import 'package:traqtrace_app/features/gs1_tools/utils/epcis_import_validator.dart';
import 'package:traqtrace_app/features/shared/validation/gs1_batch_validator.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_slice.dart';

class Gs1ToolsCubit extends Cubit<Gs1ToolsState> {
  Gs1ToolsCubit({
    required EPCConversionService epcConversionService,
    required BarcodeGenerationService barcodeGenerationService,
    required GS1BarcodeApiService gs1BarcodeApiService,
    required EPCISSerializationService serializationService,
    Gs1ToolKind initialTool = Gs1ToolKind.convert,
    String? initialMode,
  }) : _epc = epcConversionService,
       _barcodes = barcodeGenerationService,
       _verify = gs1BarcodeApiService,
       _serialization = serializationService,
       super(
         Gs1ToolsState(selectedTool: initialTool, initialMode: initialMode),
       );

  final EPCConversionService _epc;
  final BarcodeGenerationService _barcodes;
  final GS1BarcodeApiService _verify;
  final EPCISSerializationService _serialization;

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

  Future<void> convertIdentifier({
    required String mode,
    String? input,
    String? gtin,
    String? serial,
    String? sscc,
    String? gln,
    String? direction,
    String? epcType,
    String? extension,
    String? lot,
  }) async {
    final m = mode.toLowerCase();
    if (m == 'epc') {
      await _convertEpcMode(
        direction: direction,
        epcType: epcType,
        gtin: gtin,
        serial: serial,
        sscc: sscc,
        gln: gln,
        extension: extension,
        input: input,
      );
      return;
    }
    if (m == 'element') {
      _convertElementBridge(input ?? '');
      return;
    }
    // urn-dl / digital-link build+parse
    _convertUrnDl(
      input: input ?? '',
      gtin: gtin,
      serial: serial,
      sscc: sscc,
      gln: gln,
      lot: lot,
      extension: extension,
      direction: direction,
    );
  }

  void _convertUrnDl({
    required String input,
    String? gtin,
    String? serial,
    String? sscc,
    String? gln,
    String? lot,
    String? extension,
    String? direction,
  }) {
    final dir = (direction ?? 'parse').toLowerCase();
    if (dir == 'build') {
      final kind = (epcTypeOrGuess(
        gtin: gtin,
        sscc: sscc,
        gln: gln,
        serial: serial,
      ));
      String? err;
      String? uri;
      if (kind == 'sscc') {
        err = CheckDigitUtils.validateSscc(sscc);
        if (err == null) uri = EPCURIConverter.convertSSCCToEPCUri(sscc!);
      } else if (kind == 'gln') {
        err = CheckDigitUtils.validateGln(gln);
        if (err == null) {
          uri = EPCURIConverter.convertGLNToEPCUri(
            gln!,
            extension: (extension ?? '0').trim().isEmpty
                ? '0'
                : extension!.trim(),
          );
        }
      } else if (kind == 'sgtin') {
        err = CheckDigitUtils.validateGtin(gtin);
        if (err == null && (serial ?? '').trim().isEmpty) {
          err = 'Serial is required for SGTIN';
        }
        if (err == null) {
          uri = EPCURIConverter.convertGTINSerialToEPCUri(
            gtin!,
            serial!.trim(),
          );
        }
      } else {
        err = CheckDigitUtils.validateGtin(gtin);
        if (err == null) {
          final lotValue = (lot ?? '').trim();
          uri = lotValue.isEmpty
              ? EPCURIConverter.convertGTINToClassEPCUri(gtin!)
              : EPCURIConverter.convertGTINLotToLGTINEpcUri(gtin!, lotValue);
        }
      }
      if (err != null) {
        _emitError(Gs1ToolKind.convert, err);
        return;
      }
      if (uri == null || uri.isEmpty) {
        _emitError(Gs1ToolKind.convert, 'Unable to build Digital Link');
        return;
      }
      emit(
        state.withSlice(
          Gs1ToolKind.convert,
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
      return;
    }

    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      _emitError(Gs1ToolKind.convert, 'Paste a Digital Link URL or URN');
      return;
    }
    final normalized = EPCURIConverter.normalizeForStorage(trimmed);
    final type = EPCURIConverter.getEPCType(normalized);
    final fields = <String, String>{
      'Normalized': _safe(normalized),
      'Type': _safe(type),
    };
    final g = EPCURIConverter.extractGTINFromEPCUri(normalized);
    final s = EPCURIConverter.extractSerialFromEPCUri(normalized);
    final sc = EPCURIConverter.extractSSCCFromEPCUri(normalized);
    if (g != null) {
      fields['GTIN'] = g;
      final cdErr = CheckDigitUtils.validateGtin(g);
      fields['GTIN check digit'] = cdErr ?? 'Valid';
    }
    if (s != null) fields['Serial'] = s;
    if (sc != null) {
      fields['SSCC'] = sc;
      final cdErr = CheckDigitUtils.validateSscc(sc);
      fields['SSCC check digit'] = cdErr ?? 'Valid';
    }
    if (fields.length <= 2 && type == null) {
      _emitError(Gs1ToolKind.convert, 'Unrecognized Digital Link / URN format');
      return;
    }
    emit(
      state.withSlice(
        Gs1ToolKind.convert,
        WorkbenchSlice(
          status: WorkbenchActionStatus.success,
          resultText: _safe(normalized),
          resultFields: fields,
        ),
      ),
    );
  }

  Future<void> _convertEpcMode({
    String? direction,
    String? epcType,
    String? gtin,
    String? serial,
    String? sscc,
    String? gln,
    String? extension,
    String? input,
  }) async {
    final dir = (direction ?? 'to-epc').toLowerCase();
    final type = (epcType ?? 'SGTIN').toUpperCase();
    if (dir == 'from-epc' || dir == 'epc-to-gs1') {
      final uri = (input ?? '').trim();
      if (uri.isEmpty) {
        _emitError(Gs1ToolKind.convert, 'EPC URI is required');
        return;
      }
      await _run(Gs1ToolKind.convert, () async {
        switch (type) {
          case 'SSCC':
            final v = await _epc.convertEPCToSSCC(uri);
            return WorkbenchSlice(
              status: WorkbenchActionStatus.success,
              resultText: _safe(v),
              resultFields: {'SSCC': _safe(v)},
            );
          case 'GLN':
            final v = await _epc.convertEPCToGLN(uri);
            return WorkbenchSlice(
              status: WorkbenchActionStatus.success,
              resultText: _safe(v),
              resultFields: {'GLN': _safe(v)},
            );
          default:
            final result = await _epc.convertEPCToSGTIN(uri);
            return WorkbenchSlice(
              status: WorkbenchActionStatus.success,
              resultText:
                  'GTIN: ${_safe(result['gtin'])}\nSerial: ${_safe(result['serial'])}',
              resultFields: {
                'GTIN': _safe(result['gtin']),
                'Serial': _safe(result['serial']),
              },
            );
        }
      });
      return;
    }

    if (type == 'ELEMENT' || type == 'ELEMENT-STRING') {
      final es = (input ?? '').trim();
      if (es.isEmpty) {
        _emitError(Gs1ToolKind.convert, 'Element string is required');
        return;
      }
      await _run(Gs1ToolKind.convert, () async {
        final uri = await _epc.convertGS1ElementStringToEPC(es);
        return WorkbenchSlice(
          status: WorkbenchActionStatus.success,
          resultText: _safe(uri),
          resultFields: {'EPC URI': _safe(uri)},
        );
      });
      return;
    }

    if (type == 'SSCC') {
      final err = CheckDigitUtils.validateSscc(sscc);
      if (err != null) {
        _emitError(Gs1ToolKind.convert, err);
        return;
      }
      await _run(Gs1ToolKind.convert, () async {
        final uri = await _epc.convertSSCCToEPC(sscc!.trim());
        return WorkbenchSlice(
          status: WorkbenchActionStatus.success,
          resultText: _safe(uri),
          resultFields: {'EPC URI': _safe(uri)},
        );
      });
      return;
    }
    if (type == 'GLN') {
      final err = CheckDigitUtils.validateGln(gln);
      if (err != null) {
        _emitError(Gs1ToolKind.convert, err);
        return;
      }
      await _run(Gs1ToolKind.convert, () async {
        final ext = (extension ?? '').trim();
        final uri = await _epc.convertGLNToEPC(
          gln!.trim(),
          ext.isEmpty ? null : ext,
        );
        return WorkbenchSlice(
          status: WorkbenchActionStatus.success,
          resultText: _safe(uri),
          resultFields: {'EPC URI': _safe(uri)},
        );
      });
      return;
    }

    final gtinErr = CheckDigitUtils.validateGtin(gtin);
    if (gtinErr != null) {
      _emitError(Gs1ToolKind.convert, gtinErr);
      return;
    }
    if ((serial ?? '').trim().isEmpty) {
      _emitError(Gs1ToolKind.convert, 'Serial is required');
      return;
    }
    await _run(Gs1ToolKind.convert, () async {
      final uri = await _epc.convertSGTINToEPC(gtin!.trim(), serial!.trim());
      return WorkbenchSlice(
        status: WorkbenchActionStatus.success,
        resultText: _safe(uri),
        resultFields: {'EPC URI': _safe(uri)},
      );
    });
  }

  void _convertElementBridge(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      _emitError(Gs1ToolKind.convert, 'Enter a Digital Link or element string');
      return;
    }
    if (trimmed.startsWith('http') || trimmed.startsWith('urn:')) {
      final normalized = EPCURIConverter.normalizeForStorage(trimmed);
      final gtin = EPCURIConverter.extractGTINFromEPCUri(normalized);
      final serial = EPCURIConverter.extractSerialFromEPCUri(normalized);
      final sscc = EPCURIConverter.extractSSCCFromEPCUri(normalized);
      final ais = <String, String>{};
      if (sscc != null) ais['00'] = sscc;
      if (gtin != null) ais['01'] = gtin.padLeft(14, '0');
      if (serial != null) ais['21'] = serial;
      if (ais.isEmpty) {
        _emitError(
          Gs1ToolKind.convert,
          'Could not derive AIs from Digital Link',
        );
        return;
      }
      final built = Gs1ElementStringBuilder.build(ais);
      emit(
        state.withSlice(
          Gs1ToolKind.convert,
          WorkbenchSlice(
            status: WorkbenchActionStatus.success,
            resultText: built.human,
            resultFields: {
              'Human readable': built.human,
              'Element string (FNC1)': built.raw.replaceAll(
                Gs1ElementStringBuilder.fnc1,
                '|',
              ),
              'Source': _safe(normalized),
            },
          ),
        ),
      );
      return;
    }

    final uri = EPCURIConverter.convertToEPCUri(trimmed);
    if (uri == null || uri.isEmpty) {
      _emitError(
        Gs1ToolKind.convert,
        'Unable to convert element string to Digital Link',
      );
      return;
    }
    emit(
      state.withSlice(
        Gs1ToolKind.convert,
        WorkbenchSlice(
          status: WorkbenchActionStatus.success,
          resultText: uri,
          resultFields: {'Digital Link': uri},
        ),
      ),
    );
  }

  static String epcTypeOrGuess({
    String? gtin,
    String? sscc,
    String? gln,
    String? serial,
  }) {
    if ((sscc ?? '').trim().isNotEmpty) return 'sscc';
    if ((gln ?? '').trim().isNotEmpty) return 'gln';
    if ((serial ?? '').trim().isNotEmpty) return 'sgtin';
    return 'gtin';
  }

  // ─── Validate ─────────────────────────────────────────────────────────────

  Future<void> validateTool({
    required String mode,
    String? kind,
    String? value,
    String? gtin,
    String? serial,
    String? paste,
    String? checkDigitKind,
    String? checkDigitInput,
  }) async {
    final m = mode.toLowerCase();
    if (m == 'batch') {
      _validateBatch(paste ?? '');
      return;
    }
    if (m == 'check-digit') {
      _validateCheckDigit(checkDigitKind ?? 'gtin', checkDigitInput ?? '');
      return;
    }
    if (m == 'anatomy') {
      await _validateAnatomy(kind ?? 'gtin', value ?? '');
      return;
    }
    // single
    final k = (kind ?? 'gtin').toLowerCase();
    if (k == 'sgtin') {
      final err = CheckDigitUtils.validateSgtin(gtin ?? value, serial);
      final fields = <String, String>{
        'SGTIN': err == null ? 'PASS' : 'FAIL — $err',
      };
      final digits = CheckDigitUtils.digitsOnly(gtin ?? value);
      if (err == null && digits.length >= 2) {
        final body = digits.substring(0, digits.length - 1);
        fields['Check digit'] = digits[digits.length - 1];
        fields['Computed check digit'] = CheckDigitUtils.calculateMod10String(
          body,
        );
      }
      emit(
        state.withSlice(
          Gs1ToolKind.validate,
          WorkbenchSlice(
            status: WorkbenchActionStatus.success,
            resultText: fields.entries
                .map((e) => '${e.key}: ${e.value}')
                .join('\n'),
            resultFields: fields,
          ),
        ),
      );
      return;
    }

    String? err;
    Set<int> lengths = CheckDigitUtils.gtinLengths;
    var label = 'GTIN';
    if (k == 'gln') {
      err = CheckDigitUtils.validateGln(value);
      lengths = CheckDigitUtils.glnLengths;
      label = 'GLN';
    } else if (k == 'sscc') {
      err = CheckDigitUtils.validateSscc(value);
      lengths = CheckDigitUtils.ssccLengths;
      label = 'SSCC';
    } else if (k == 'gsrn') {
      err = CheckDigitUtils.validateGsrn(value);
      lengths = CheckDigitUtils.gsrnLengths;
      label = 'GSRN';
    } else if (k == 'gdti') {
      err = CheckDigitUtils.validateGdti(value);
      lengths = CheckDigitUtils.gdtiLengths;
      label = 'GDTI';
    } else if (k == 'grai') {
      err = CheckDigitUtils.validateGrai(value);
      lengths = CheckDigitUtils.graiLengths;
      label = 'GRAI';
    } else if (k == 'giai') {
      err = CheckDigitUtils.validateGiai(value);
      label = 'GIAI';
    } else if (k == 'cpid') {
      err = CheckDigitUtils.validateCpid(value);
      label = 'CPID';
    } else {
      err = CheckDigitUtils.validateGtin(value);
    }

    final fields = <String, String>{
      label: err == null ? 'PASS' : 'FAIL — $err',
    };
    final digits = CheckDigitUtils.digitsOnly(value);
    if (digits.length >= 2 &&
        (k == 'giai' || k == 'cpid' || lengths.contains(digits.length))) {
      if (k != 'giai' && k != 'cpid') {
        final body = digits.substring(0, digits.length - 1);
        fields['Check digit (provided)'] = digits[digits.length - 1];
        fields['Check digit (computed)'] = CheckDigitUtils.calculateMod10String(
          body,
        );
      }
    }
    emit(
      state.withSlice(
        Gs1ToolKind.validate,
        WorkbenchSlice(
          status: WorkbenchActionStatus.success,
          resultText: fields.entries
              .map((e) => '${e.key}: ${e.value}')
              .join('\n'),
          resultFields: fields,
        ),
      ),
    );
  }

  void _validateBatch(String paste) {
    final trimmed = paste.trim();
    if (trimmed.isEmpty) {
      _emitError(Gs1ToolKind.validate, 'Paste one or more identifiers');
      return;
    }
    final rows = Gs1BatchValidator.validatePaste(trimmed);
    if (rows.isEmpty) {
      _emitError(Gs1ToolKind.validate, 'No identifiers found');
      return;
    }
    final fields = <String, String>{};
    for (final row in rows) {
      fields['#${row.lineNumber} ${row.type}'] = row.isValid
          ? 'PASS — ${row.message}'
          : 'FAIL — ${row.message}';
    }
    final passed = rows.where((r) => r.isValid).length;
    emit(
      state.withSlice(
        Gs1ToolKind.validate,
        WorkbenchSlice(
          status: WorkbenchActionStatus.success,
          resultText: '$passed / ${rows.length} passed',
          resultFields: fields,
        ),
      ),
    );
  }

  void _validateCheckDigit(String kind, String input) {
    final lengths = switch (kind.toLowerCase()) {
      'gln' => CheckDigitUtils.glnLengths,
      'sscc' => CheckDigitUtils.ssccLengths,
      'gsrn' => CheckDigitUtils.gsrnLengths,
      'gdti' => CheckDigitUtils.gdtiLengths,
      'grai' => CheckDigitUtils.graiLengths,
      _ => CheckDigitUtils.gtinLengths,
    };
    final result = CheckDigitUtils.compute(input: input, fullLengths: lengths);
    if (result.checkDigit < 0 || result.fullNumber.isEmpty) {
      _emitError(
        Gs1ToolKind.validate,
        'Enter a valid-length body or full identifier.',
      );
      return;
    }
    emit(
      state.withSlice(
        Gs1ToolKind.validate,
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

  Future<void> _validateAnatomy(String kind, String value) async {
    await Gs1Anatomy.ensureLoaded();
    final digits = CheckDigitUtils.digitsOnly(value);
    if (digits.isEmpty) {
      _emitError(Gs1ToolKind.validate, 'Enter an identifier to decompose');
      return;
    }
    final fields = Gs1Anatomy.decompose(value, kind: kind);
    emit(
      state.withSlice(
        Gs1ToolKind.validate,
        WorkbenchSlice(
          status: WorkbenchActionStatus.success,
          resultText: fields.entries
              .map((e) => '${e.key}: ${e.value}')
              .join('\n'),
          resultFields: fields,
        ),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  void buildIdentifier({
    required String mode,
    String? extensionDigit,
    String? companyPrefix,
    String? serialReference,
    String? gtin,
    int? targetLength,
    int? indicator,
  }) {
    if (mode.toLowerCase() == 'sscc') {
      final gcp = CheckDigitUtils.digitsOnly(companyPrefix);
      final ext = CheckDigitUtils.digitsOnly(extensionDigit);
      final serial = CheckDigitUtils.digitsOnly(serialReference);
      if (ext.length != 1) {
        _emitError(
          Gs1ToolKind.build,
          'Extension digit must be one digit (0–9)',
        );
        return;
      }
      if (gcp.length < 6 || gcp.length > 12) {
        _emitError(Gs1ToolKind.build, 'Company prefix must be 6–12 digits');
        return;
      }
      final serialLen = 16 - gcp.length;
      if (serial.length != serialLen) {
        _emitError(
          Gs1ToolKind.build,
          'Serial reference must be $serialLen digits for GCP length ${gcp.length}',
        );
        return;
      }
      final body = '$ext$gcp$serial';
      if (body.length != 17) {
        _emitError(Gs1ToolKind.build, 'Internal SSCC body length error');
        return;
      }
      final cd = CheckDigitUtils.calculateMod10String(body);
      final full = '$body$cd';
      emit(
        state.withSlice(
          Gs1ToolKind.build,
          WorkbenchSlice(
            status: WorkbenchActionStatus.success,
            resultText: full,
            resultFields: {
              'SSCC': full,
              'Check digit': cd,
              'Extension': ext,
              'GS1 Company Prefix': gcp,
              'Serial reference': serial,
            },
          ),
        ),
      );
      return;
    }

    // GTIN packaging / indicator
    final digits = CheckDigitUtils.digitsOnly(gtin);
    if (digits.isEmpty) {
      _emitError(Gs1ToolKind.build, 'Enter a GTIN');
      return;
    }
    // Strip check digit if present at a known full length
    String body;
    if (CheckDigitUtils.gtinLengths.contains(digits.length) &&
        CheckDigitUtils.isValidMod10(digits)) {
      body = digits.substring(0, digits.length - 1);
    } else if ({7, 11, 12, 13}.contains(digits.length)) {
      body = digits;
    } else if (CheckDigitUtils.gtinLengths.contains(digits.length)) {
      body = digits.substring(0, digits.length - 1);
    } else {
      _emitError(Gs1ToolKind.build, 'GTIN length not recognized');
      return;
    }

    // Normalize to 13-digit body (indicator + 12) for GTIN-14
    var core = body;
    while (core.length < 13) {
      core = '0$core';
    }
    if (core.length > 13) {
      core = core.substring(core.length - 13);
    }
    if (indicator != null && indicator >= 0 && indicator <= 9) {
      core = '$indicator${core.substring(1)}';
    }
    final target = targetLength ?? 14;
    String fullBody;
    if (target == 8) {
      fullBody = core.substring(core.length - 7);
    } else if (target == 12) {
      fullBody = core.substring(core.length - 11);
    } else if (target == 13) {
      fullBody = core.substring(core.length - 12);
    } else {
      fullBody = core;
    }
    final cd = CheckDigitUtils.calculateMod10String(fullBody);
    final full = '$fullBody$cd';
    emit(
      state.withSlice(
        Gs1ToolKind.build,
        WorkbenchSlice(
          status: WorkbenchActionStatus.success,
          resultText: full,
          resultFields: {
            'GTIN-$target': full,
            'Check digit': cd,
            'Indicator': full.length == 14 ? full[0] : '—',
            'Indicator meaning': full.length == 14
                ? (full[0] == '0'
                      ? 'Base unit'
                      : full[0] == '9'
                      ? 'Variable measure'
                      : 'Company-assigned packaging level')
                : '—',
          },
        ),
      ),
    );
  }

  // ─── Barcode ──────────────────────────────────────────────────────────────

  Future<void> barcodeTool({
    required String mode,
    String? elementString,
    String? gtin,
    String? serial,
    String? expiry,
    String? batch,
    String? sscc,
    String? data,
    String? verifyInput,
  }) async {
    final m = mode.toLowerCase();
    if (m == 'verify') {
      await _verifyBarcode(verifyInput ?? elementString ?? '');
      return;
    }
    if (m == 'pharma' || m == 'sgtin') {
      final err = CheckDigitUtils.validateGtin(gtin);
      if (err != null) {
        _emitError(Gs1ToolKind.barcode, err);
        return;
      }
      if ((serial ?? '').trim().isEmpty) {
        _emitError(Gs1ToolKind.barcode, 'Serial (AI 21) is required');
        return;
      }
      final exp = (expiry ?? '').trim();
      if (exp.isEmpty) {
        _emitError(
          Gs1ToolKind.barcode,
          'Expiry (AI 17) is required for pharma pack',
        );
        return;
      }
      final dateErr = Gs1DateUtils.validateYymmdd(exp, label: 'Expiry');
      if (dateErr != null) {
        _emitError(Gs1ToolKind.barcode, dateErr);
        return;
      }
      final lot = (batch ?? '').trim();
      if (lot.isEmpty) {
        _emitError(
          Gs1ToolKind.barcode,
          'Batch/Lot (AI 10) is required for pharma pack',
        );
        return;
      }
      final built = Gs1ElementStringBuilder.build({
        '01': gtin!.trim().padLeft(14, '0'),
        '21': serial!.trim(),
        '17': exp,
        '10': lot,
      });
      await _run(Gs1ToolKind.barcode, () async {
        final bytes = await _barcodes.generateSGTINDataMatrix(
          gtin: gtin.trim(),
          serialNumber: serial.trim(),
          expiryDate: exp,
          batchLot: lot,
        );
        return WorkbenchSlice(
          status: WorkbenchActionStatus.success,
          imageBytes: bytes,
          resultText: built.human,
          resultFields: {
            'Element string': built.human,
            'AI 01 GTIN': gtin.trim(),
            'AI 21 Serial': serial.trim(),
            'AI 17 Expiry': exp,
            'AI 17 ISO': _safe(Gs1DateUtils.toIsoDate(exp)),
            'AI 10 Batch/Lot': lot,
          },
          meta: {'format': 'pharma-datamatrix'},
        );
      });
      return;
    }
    if (m == 'sscc') {
      final err = CheckDigitUtils.validateSscc(sscc);
      if (err != null) {
        _emitError(Gs1ToolKind.barcode, err);
        return;
      }
      await _run(Gs1ToolKind.barcode, () async {
        final bytes = await _barcodes.generateSSCCBarcode(sscc: sscc!.trim());
        return WorkbenchSlice(
          status: WorkbenchActionStatus.success,
          imageBytes: bytes,
          resultText: 'SSCC barcode generated',
          meta: {'format': 'sscc'},
        );
      });
      return;
    }
    if (m == 'datamatrix') {
      final es = (elementString ?? '').trim();
      if (es.isEmpty) {
        _emitError(Gs1ToolKind.barcode, 'GS1 element string is required');
        return;
      }
      await _run(Gs1ToolKind.barcode, () async {
        final bytes = await _barcodes.generateDataMatrix(gs1ElementString: es);
        return WorkbenchSlice(
          status: WorkbenchActionStatus.success,
          imageBytes: bytes,
          resultText: 'GS1 DataMatrix generated',
          meta: {'format': 'datamatrix'},
        );
      });
      return;
    }
    if (m == 'gs1128' || m == 'gs1-128') {
      final es = (elementString ?? '').trim();
      if (es.isEmpty) {
        _emitError(Gs1ToolKind.barcode, 'GS1 element string is required');
        return;
      }
      await _run(Gs1ToolKind.barcode, () async {
        final bytes = await _barcodes.generateGS1128(gs1ElementString: es);
        return WorkbenchSlice(
          status: WorkbenchActionStatus.success,
          imageBytes: bytes,
          resultText: 'GS1-128 generated',
          meta: {'format': 'gs1-128'},
        );
      });
      return;
    }

    // ean13 / upca / itf14 / qrDl via generic endpoint (may be unsupported server-side)
    final payload = (data ?? gtin ?? elementString ?? '').trim();
    if (payload.isEmpty) {
      _emitError(Gs1ToolKind.barcode, 'Data is required');
      return;
    }
    if (m == 'ean13' || m == 'upca' || m == 'itf14') {
      final err = CheckDigitUtils.validateGtin(payload);
      if (err != null && m != 'upca') {
        // still try — upc-a is 12
      }
    }
    final format = switch (m) {
      'ean13' => 'ean-13',
      'upca' => 'upc-a',
      'itf14' => 'itf-14',
      'qrdl' || 'qr' || 'qr-dl' => 'qr',
      _ => m,
    };
    await _run(Gs1ToolKind.barcode, () async {
      try {
        final bytes = await _barcodes.generateGenericBarcode(
          data: payload,
          format: format,
        );
        return WorkbenchSlice(
          status: WorkbenchActionStatus.success,
          imageBytes: bytes,
          resultText: '$format barcode generated',
          meta: {'format': format},
        );
      } catch (e) {
        throw Exception(
          'Symbology "$format" is not available from the barcode service: $e',
        );
      }
    });
  }

  Future<void> _verifyBarcode(String input) async {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      _emitError(Gs1ToolKind.barcode, 'Barcode / element string is required');
      return;
    }
    await _run(Gs1ToolKind.barcode, () async {
      final local = GS1BarcodeParser.parseGS1Barcode(trimmed);
      final remote = await _verify.verifyGS1Barcode(trimmed);
      final gtin = local['GTIN']?.toString();
      final serial = local['SERIAL']?.toString();
      final expiry = local['EXPIRY']?.toString();
      final batch = local['BATCH']?.toString();
      final fields = <String, String>{
        'Local valid': local['valid'] == true ? 'Yes' : 'No',
        'AI 01 GTIN': _safe(gtin),
        'AI 21 Serial': _safe(serial),
        'AI 17 Expiry': _safe(expiry),
        'AI 10 Batch/Lot': _safe(batch),
        'Local SSCC': _safe(local['SSCC']),
        'Local GLN': _safe(local['GLN']),
      };

      // Pharma pack (01 present): flag missing mandatory AIs 21/17/10.
      if (gtin != null && gtin.isNotEmpty) {
        final missing = <String>[];
        if (serial == null || serial.isEmpty) missing.add('21 (serial)');
        if (expiry == null || expiry.isEmpty) missing.add('17 (expiry)');
        if (batch == null || batch.isEmpty) missing.add('10 (batch/lot)');
        fields['Pharma mandatory AIs'] = missing.isEmpty
            ? 'Complete (01/21/17/10)'
            : 'Missing: ${missing.join(', ')}';
        final err = CheckDigitUtils.validateGtin(gtin);
        fields['GTIN check'] = err == null ? 'PASS' : 'FAIL — $err';
      }
      if (expiry != null && expiry.isNotEmpty) {
        final dateErr = Gs1DateUtils.validateYymmdd(expiry, label: 'Expiry');
        fields['Expiry check'] = dateErr == null
            ? 'PASS — ${_safe(Gs1DateUtils.toIsoDate(expiry))}'
            : 'FAIL — $dateErr';
      }
      final checkErrors = (local['checkDigitErrors'] as List?) ?? const [];
      if (checkErrors.isNotEmpty) {
        fields['Check digit errors'] = checkErrors.join('; ');
      }
      remote.forEach((key, value) {
        fields['API $key'] = _safe(value);
      });
      return WorkbenchSlice(
        status: WorkbenchActionStatus.success,
        resultText: fields.entries
            .map((e) => '${e.key}: ${e.value}')
            .join('\n'),
        resultFields: fields,
      );
    });
  }

  // ─── AI / Element String ──────────────────────────────────────────────────

  void aiTool({required String mode, String? input, Map<String, String>? ais}) {
    final m = mode.toLowerCase();
    if (m == 'build') {
      final built = Gs1ElementStringBuilder.build(ais ?? {});
      if (built.human.isEmpty) {
        _emitError(Gs1ToolKind.aiElement, 'Enter at least one AI and value');
        return;
      }
      emit(
        state.withSlice(
          Gs1ToolKind.aiElement,
          WorkbenchSlice(
            status: WorkbenchActionStatus.success,
            resultText: built.raw,
            resultFields: {
              'Element string (FNC1)': built.raw.replaceAll(
                Gs1ElementStringBuilder.fnc1,
                '|',
              ),
              'Human readable': built.human,
            },
          ),
        ),
      );
      return;
    }
    if (m == 'table') {
      emit(
        state.withSlice(
          Gs1ToolKind.aiElement,
          const WorkbenchSlice(
            status: WorkbenchActionStatus.success,
            resultText: 'AI reference table — use search in the panel',
            resultFields: {'Hint': 'Filter the table in the form above'},
          ),
        ),
      );
      return;
    }

    final trimmed = (input ?? '').trim();
    if (trimmed.isEmpty) {
      _emitError(Gs1ToolKind.aiElement, 'Paste a GS1 element string');
      return;
    }
    final parsed = GS1BarcodeParser.parseGS1Barcode(trimmed);
    final map = (parsed['parsedData'] as Map?)?.cast<String, String>() ?? {};
    final human =
        (parsed['humanReadable'] as Map?)?.cast<String, String>() ?? {};
    if (map.isEmpty) {
      _emitError(Gs1ToolKind.aiElement, 'No Application Identifiers found');
      return;
    }
    final fields = <String, String>{};
    map.forEach((ai, value) {
      final label = human.entries
          .firstWhere(
            (e) => e.value == value,
            orElse: () => MapEntry('($ai)', value),
          )
          .key;
      fields['AI $ai — $label'] = _safe(value);
      if (ai == '17' || ai == '11' || ai == '15') {
        fields['AI $ai ISO'] = _safe(Gs1DateUtils.toIsoDate(value));
      }
      if (ai == '01') {
        final err = CheckDigitUtils.validateGtin(value);
        fields['AI 01 check'] = err == null ? 'PASS' : 'FAIL — $err';
      }
      if (ai == '00') {
        final err = CheckDigitUtils.validateSscc(value);
        fields['AI 00 check'] = err == null ? 'PASS' : 'FAIL — $err';
      }
    });
    emit(
      state.withSlice(
        Gs1ToolKind.aiElement,
        WorkbenchSlice(
          status: WorkbenchActionStatus.success,
          resultText: fields.entries
              .map((e) => '${e.key}: ${e.value}')
              .join('\n'),
          resultFields: {
            ...fields,
            'Valid': parsed['valid'] == true ? 'Yes' : 'No',
          },
        ),
      ),
    );
  }

  // ─── NDC ↔ GTIN ───────────────────────────────────────────────────────────

  void convertNdc({
    required String mode,
    required String input,
    String format = '5-4-2',
  }) {
    if (mode.toLowerCase().contains('gtin-to') ||
        mode.toLowerCase() == 'gtin-to-ndc') {
      final ndc11 = NdcGtinConverter.gtin14ToNdc11(input);
      if (ndc11 == null) {
        _emitError(
          Gs1ToolKind.ndc,
          'Enter a valid US GTIN-14 starting with 003',
        );
        return;
      }
      emit(
        state.withSlice(
          Gs1ToolKind.ndc,
          WorkbenchSlice(
            status: WorkbenchActionStatus.success,
            resultText: ndc11,
            resultFields: {
              'NDC-11': ndc11,
              'Source GTIN': CheckDigitUtils.digitsOnly(input),
            },
          ),
        ),
      );
      return;
    }

    final err = NdcGtinConverter.validateNdc(input, format: format);
    if (err != null) {
      _emitError(Gs1ToolKind.ndc, err);
      return;
    }
    final gtin = NdcGtinConverter.ndcToGtin14(input, format: format);
    if (gtin == null) {
      _emitError(Gs1ToolKind.ndc, 'Unable to convert NDC to GTIN-14');
      return;
    }
    emit(
      state.withSlice(
        Gs1ToolKind.ndc,
        WorkbenchSlice(
          status: WorkbenchActionStatus.success,
          resultText: gtin,
          resultFields: {
            'GTIN-14': gtin,
            'NDC-11': _safe(NdcGtinConverter.toNdc11(input, format: format)),
            'Format': format,
            'Check digit': gtin[gtin.length - 1],
          },
        ),
      ),
    );
  }

  // ─── GS1 Lookup ───────────────────────────────────────────────────────────

  Future<void> lookupGs1(String identifier) async {
    final id = identifier.trim();
    if (id.isEmpty) {
      _emitError(Gs1ToolKind.lookup, 'Enter a GTIN or GLN to look up');
      return;
    }
    // No GEPIR/Verified-by-GS1 backend endpoint is wired in this app yet.
    emit(
      state.withSlice(
        Gs1ToolKind.lookup,
        const WorkbenchSlice(
          status: WorkbenchActionStatus.error,
          error:
              'GS1 Lookup requires a network connection to a Verified-by-GS1 / '
              'GEPIR backend endpoint, which is not configured. '
              'Lookup unavailable — no fabricated results.',
        ),
      ),
    );
  }

  // ─── EPCIS Serialization (unchanged domain) ───────────────────────────────

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
      _emitError(Gs1ToolKind.serializeConvert, 'Enter data to validate');
      return;
    }
    await _run(Gs1ToolKind.serializeConvert, () async {
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
          final csv = await _serialization.exportToCsv(queryParams);
          return WorkbenchSlice(
            status: WorkbenchActionStatus.success,
            resultText: csv,
            resultFields: {'Format': 'CSV'},
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
            resultFields: {'Format': 'PDF', 'Bytes': '${bytes.length}'},
            meta: {'bytes': bytes},
          );
        case 'EXCEL':
          final bytes = await _serialization.exportToExcel(queryParams);
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
    await _run(Gs1ToolKind.serializeImport, () async {
      final local = EpcisImportValidator.validate(input);
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
      final schemaResponse = await _serialization.validateJsonSchema(
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
      _emitError(Gs1ToolKind.serializeImport, 'Enter an EPCIS document');
      return;
    }
    await _run(Gs1ToolKind.serializeImport, () async {
      final local = EpcisImportValidator.validate(text);
      if (!local.isValid) {
        throw Exception(
          'Import blocked — document does not conform:\n${local.summarize()}',
        );
      }

      final schemaResponse = await _serialization.validateJsonSchema(
        local.document!,
      );
      if (schemaResponse['valid'] != true) {
        final errors = schemaResponse['errors'];
        final errorText = errors is List
            ? errors.map((e) => '$e').join('; ')
            : (errors?.toString() ?? 'Schema validation failed');
        throw Exception('Import blocked — schema gate failed: $errorText');
      }

      final result = await _serialization.importEventsFromJsonLd(
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
          'Imported': _safe(processed),
          'Total': _safe(total),
          'Failed': _safe(failed),
          'Status': _safe(status),
          'Format': 'JSON-LD',
          if (errorList.isNotEmpty) 'Errors': errorList.join('; '),
        },
        meta: {'importValidated': ok},
      );
    });
  }

  // ─── helpers ──────────────────────────────────────────────────────────────

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

  static String _safe(Object? value) {
    if (value == null) return '—';
    final text = value.toString().trim();
    if (text.isEmpty || text == 'null') return '—';
    return text;
  }
}
