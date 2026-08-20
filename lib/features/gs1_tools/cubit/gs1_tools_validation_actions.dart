import 'package:traqtrace_app/core/utils/gs1/check_digit_utils.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_anatomy.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_cubit.dart';
import 'package:traqtrace_app/features/gs1_tools/models/gs1_tool_kind.dart';
import 'package:traqtrace_app/features/shared/validation/gs1_batch_validator.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_slice.dart';

extension Gs1ToolsValidationActions on Gs1ToolsCubit {
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
      emitError(Gs1ToolKind.validate, 'Paste one or more identifiers');
      return;
    }
    final rows = Gs1BatchValidator.validatePaste(trimmed);
    if (rows.isEmpty) {
      emitError(Gs1ToolKind.validate, 'No identifiers found');
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
      emitError(
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
      emitError(Gs1ToolKind.validate, 'Enter an identifier to decompose');
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
        emitError(Gs1ToolKind.build, 'Extension digit must be one digit (0–9)');
        return;
      }
      if (gcp.length < 6 || gcp.length > 12) {
        emitError(Gs1ToolKind.build, 'Company prefix must be 6–12 digits');
        return;
      }
      final serialLen = 16 - gcp.length;
      if (serial.length != serialLen) {
        emitError(
          Gs1ToolKind.build,
          'Serial reference must be $serialLen digits for GCP length ${gcp.length}',
        );
        return;
      }
      final body = '$ext$gcp$serial';
      if (body.length != 17) {
        emitError(Gs1ToolKind.build, 'Internal SSCC body length error');
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
      emitError(Gs1ToolKind.build, 'Enter a GTIN');
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
      emitError(Gs1ToolKind.build, 'GTIN length not recognized');
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
}
