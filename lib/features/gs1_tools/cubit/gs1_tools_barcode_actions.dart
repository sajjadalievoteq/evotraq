import 'package:traqtrace_app/core/utils/gs1/check_digit_utils.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_date_utils.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_element_string_builder.dart';
import 'package:traqtrace_app/core/utils/gs1/ndc_gtin_converter.dart';
import 'package:traqtrace_app/data/services/barcode/gs1_barcode_parser.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_cubit.dart';
import 'package:traqtrace_app/features/gs1_tools/models/gs1_tool_kind.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_slice.dart';

extension Gs1ToolsBarcodeActions on Gs1ToolsCubit {
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
      await verifyBarcode(verifyInput ?? elementString ?? '');
      return;
    }
    if (m == 'pharma' || m == 'sgtin') {
      final err = CheckDigitUtils.validateGtin(gtin);
      if (err != null) {
        emitError(Gs1ToolKind.barcode, err);
        return;
      }
      if ((serial ?? '').trim().isEmpty) {
        emitError(Gs1ToolKind.barcode, 'Serial (AI 21) is required');
        return;
      }
      final exp = (expiry ?? '').trim();
      if (exp.isEmpty) {
        emitError(
          Gs1ToolKind.barcode,
          'Expiry (AI 17) is required for pharma pack',
        );
        return;
      }
      final dateErr = Gs1DateUtils.validateYymmdd(exp, label: 'Expiry');
      if (dateErr != null) {
        emitError(Gs1ToolKind.barcode, dateErr);
        return;
      }
      final lot = (batch ?? '').trim();
      if (lot.isEmpty) {
        emitError(
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
      await run(Gs1ToolKind.barcode, () async {
        final bytes = await barcodes.generateSGTINDataMatrix(
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
            'AI 17 ISO': safe(Gs1DateUtils.toIsoDate(exp)),
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
        emitError(Gs1ToolKind.barcode, err);
        return;
      }
      await run(Gs1ToolKind.barcode, () async {
        final bytes = await barcodes.generateSSCCBarcode(sscc: sscc!.trim());
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
        emitError(Gs1ToolKind.barcode, 'GS1 element string is required');
        return;
      }
      await run(Gs1ToolKind.barcode, () async {
        final bytes = await barcodes.generateDataMatrix(gs1ElementString: es);
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
        emitError(Gs1ToolKind.barcode, 'GS1 element string is required');
        return;
      }
      await run(Gs1ToolKind.barcode, () async {
        final bytes = await barcodes.generateGS1128(gs1ElementString: es);
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
      emitError(Gs1ToolKind.barcode, 'Data is required');
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
    await run(Gs1ToolKind.barcode, () async {
      try {
        final bytes = await barcodes.generateGenericBarcode(
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

  Future<void> verifyBarcode(String input) async {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      emitError(Gs1ToolKind.barcode, 'Barcode / element string is required');
      return;
    }
    await run(Gs1ToolKind.barcode, () async {
      final local = GS1BarcodeParser.parseGS1Barcode(trimmed);
      final remote = await verify.verifyGS1Barcode(trimmed);
      final gtin = local['GTIN']?.toString();
      final serial = local['SERIAL']?.toString();
      final expiry = local['EXPIRY']?.toString();
      final batch = local['BATCH']?.toString();
      final fields = <String, String>{
        'Local valid': local['valid'] == true ? 'Yes' : 'No',
        'AI 01 GTIN': safe(gtin),
        'AI 21 Serial': safe(serial),
        'AI 17 Expiry': safe(expiry),
        'AI 10 Batch/Lot': safe(batch),
        'Local SSCC': safe(local['SSCC']),
        'Local GLN': safe(local['GLN']),
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
            ? 'PASS — ${safe(Gs1DateUtils.toIsoDate(expiry))}'
            : 'FAIL — $dateErr';
      }
      final checkErrors = (local['checkDigitErrors'] as List?) ?? const [];
      if (checkErrors.isNotEmpty) {
        fields['Check digit errors'] = checkErrors.join('; ');
      }
      remote.forEach((key, value) {
        fields['API $key'] = safe(value);
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
        emitError(Gs1ToolKind.aiElement, 'Enter at least one AI and value');
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
      emitError(Gs1ToolKind.aiElement, 'Paste a GS1 element string');
      return;
    }
    final parsed = GS1BarcodeParser.parseGS1Barcode(trimmed);
    final map = (parsed['parsedData'] as Map?)?.cast<String, String>() ?? {};
    final human =
        (parsed['humanReadable'] as Map?)?.cast<String, String>() ?? {};
    if (map.isEmpty) {
      emitError(Gs1ToolKind.aiElement, 'No Application Identifiers found');
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
      fields['AI $ai — $label'] = safe(value);
      if (ai == '17' || ai == '11' || ai == '15') {
        fields['AI $ai ISO'] = safe(Gs1DateUtils.toIsoDate(value));
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
        emitError(
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
      emitError(Gs1ToolKind.ndc, err);
      return;
    }
    final gtin = NdcGtinConverter.ndcToGtin14(input, format: format);
    if (gtin == null) {
      emitError(Gs1ToolKind.ndc, 'Unable to convert NDC to GTIN-14');
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
            'NDC-11': safe(NdcGtinConverter.toNdc11(input, format: format)),
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
      emitError(Gs1ToolKind.lookup, 'Enter a GTIN or GLN to look up');
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
}
