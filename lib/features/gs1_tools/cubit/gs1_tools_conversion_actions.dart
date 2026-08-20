import 'package:traqtrace_app/core/utils/gs1/check_digit_utils.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_element_string_builder.dart';
import 'package:traqtrace_app/data/services/barcode/epc_uri_converter.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_cubit.dart';
import 'package:traqtrace_app/features/gs1_tools/models/gs1_tool_kind.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_slice.dart';

extension Gs1ToolsConversionActions on Gs1ToolsCubit {
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
        emitError(Gs1ToolKind.convert, err);
        return;
      }
      if (uri == null || uri.isEmpty) {
        emitError(Gs1ToolKind.convert, 'Unable to build Digital Link');
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
      emitError(Gs1ToolKind.convert, 'Paste a Digital Link URL or URN');
      return;
    }
    final normalized = EPCURIConverter.normalizeForStorage(trimmed);
    final type = EPCURIConverter.getEPCType(normalized);
    final fields = <String, String>{
      'Normalized': safe(normalized),
      'Type': safe(type),
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
      emitError(Gs1ToolKind.convert, 'Unrecognized Digital Link / URN format');
      return;
    }
    emit(
      state.withSlice(
        Gs1ToolKind.convert,
        WorkbenchSlice(
          status: WorkbenchActionStatus.success,
          resultText: safe(normalized),
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
        emitError(Gs1ToolKind.convert, 'EPC URI is required');
        return;
      }
      await run(Gs1ToolKind.convert, () async {
        switch (type) {
          case 'SSCC':
            final v = await epc.convertEPCToSSCC(uri);
            return WorkbenchSlice(
              status: WorkbenchActionStatus.success,
              resultText: safe(v),
              resultFields: {'SSCC': safe(v)},
            );
          case 'GLN':
            final v = await epc.convertEPCToGLN(uri);
            return WorkbenchSlice(
              status: WorkbenchActionStatus.success,
              resultText: safe(v),
              resultFields: {'GLN': safe(v)},
            );
          default:
            final result = await epc.convertEPCToSGTIN(uri);
            return WorkbenchSlice(
              status: WorkbenchActionStatus.success,
              resultText:
                  'GTIN: ${safe(result['gtin'])}\nSerial: ${safe(result['serial'])}',
              resultFields: {
                'GTIN': safe(result['gtin']),
                'Serial': safe(result['serial']),
              },
            );
        }
      });
      return;
    }

    if (type == 'ELEMENT' || type == 'ELEMENT-STRING') {
      final es = (input ?? '').trim();
      if (es.isEmpty) {
        emitError(Gs1ToolKind.convert, 'Element string is required');
        return;
      }
      await run(Gs1ToolKind.convert, () async {
        final uri = await epc.convertGS1ElementStringToEPC(es);
        return WorkbenchSlice(
          status: WorkbenchActionStatus.success,
          resultText: safe(uri),
          resultFields: {'EPC URI': safe(uri)},
        );
      });
      return;
    }

    if (type == 'SSCC') {
      final err = CheckDigitUtils.validateSscc(sscc);
      if (err != null) {
        emitError(Gs1ToolKind.convert, err);
        return;
      }
      await run(Gs1ToolKind.convert, () async {
        final uri = await epc.convertSSCCToEPC(sscc!.trim());
        return WorkbenchSlice(
          status: WorkbenchActionStatus.success,
          resultText: safe(uri),
          resultFields: {'EPC URI': safe(uri)},
        );
      });
      return;
    }
    if (type == 'GLN') {
      final err = CheckDigitUtils.validateGln(gln);
      if (err != null) {
        emitError(Gs1ToolKind.convert, err);
        return;
      }
      await run(Gs1ToolKind.convert, () async {
        final ext = (extension ?? '').trim();
        final uri = await epc.convertGLNToEPC(
          gln!.trim(),
          ext.isEmpty ? null : ext,
        );
        return WorkbenchSlice(
          status: WorkbenchActionStatus.success,
          resultText: safe(uri),
          resultFields: {'EPC URI': safe(uri)},
        );
      });
      return;
    }

    final gtinErr = CheckDigitUtils.validateGtin(gtin);
    if (gtinErr != null) {
      emitError(Gs1ToolKind.convert, gtinErr);
      return;
    }
    if ((serial ?? '').trim().isEmpty) {
      emitError(Gs1ToolKind.convert, 'Serial is required');
      return;
    }
    await run(Gs1ToolKind.convert, () async {
      final uri = await epc.convertSGTINToEPC(gtin!.trim(), serial!.trim());
      return WorkbenchSlice(
        status: WorkbenchActionStatus.success,
        resultText: safe(uri),
        resultFields: {'EPC URI': safe(uri)},
      );
    });
  }

  void _convertElementBridge(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      emitError(Gs1ToolKind.convert, 'Enter a Digital Link or element string');
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
        emitError(
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
              'Source': safe(normalized),
            },
          ),
        ),
      );
      return;
    }

    final uri = EPCURIConverter.convertToEPCUri(trimmed);
    if (uri == null || uri.isEmpty) {
      emitError(
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
}
