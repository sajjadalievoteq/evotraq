import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/models/scan_result.dart';
import 'package:traqtrace_app/core/utils/barcode_utils.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_canonical_identifier.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_converter.dart';
import 'package:traqtrace_app/features/barcode/widgets/gs1_barcode_scan_dialog.dart';
import 'package:traqtrace_app/features/epcis/utils/epc_formatter.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_format.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_format.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_format.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

enum Gs1FieldScanKind { gln, gtin, sgtin, sscc }

abstract final class Gs1FieldBarcodeScan {
  static List<String> _allowedFormats(Gs1FieldScanKind kind) {
    switch (kind) {
      case Gs1FieldScanKind.gln:
        return ['GLN'];
      case Gs1FieldScanKind.gtin:
        return ['GTIN'];
      case Gs1FieldScanKind.sgtin:
        return ['SGTIN'];
      case Gs1FieldScanKind.sscc:
        return ['SSCC'];
    }
  }

  static String _dialogTitle(Gs1FieldScanKind kind) {
    switch (kind) {
      case Gs1FieldScanKind.gln:
        return 'Scan GLN Barcode';
      case Gs1FieldScanKind.gtin:
        return 'Scan GTIN Barcode';
      case Gs1FieldScanKind.sgtin:
        return 'Scan SGTIN Barcode';
      case Gs1FieldScanKind.sscc:
        return 'Scan SSCC Barcode';
    }
  }

  static Future<String?> scan(
    BuildContext context,
    Gs1FieldScanKind kind,
  ) async {
    final result = await GS1BarcodeScanDialog.show(
      context,
      title: _dialogTitle(kind),
      allowedFormats: _allowedFormats(kind),
    );
    if (result == null) return null;

    if (!result.isValid) {
      _showError(
        context,
        result.error ?? 'Invalid barcode scan',
      );
      return null;
    }

    final value = _extractFieldValue(kind, result);
    if (value == null || value.isEmpty) {
      _showError(context, 'Could not extract ${_kindLabel(kind)} from barcode');
      return null;
    }
    return value;
  }

  static String _kindLabel(Gs1FieldScanKind kind) {
    switch (kind) {
      case Gs1FieldScanKind.gln:
        return 'GLN';
      case Gs1FieldScanKind.gtin:
        return 'GTIN';
      case Gs1FieldScanKind.sgtin:
        return 'SGTIN EPC';
      case Gs1FieldScanKind.sscc:
        return 'SSCC';
    }
  }

  static String? _extractFieldValue(Gs1FieldScanKind kind, ScanResult result) {
    final details = extractBarcodeDetails(result.data);

    switch (kind) {
      case Gs1FieldScanKind.gln:
        final gln = details.gln ?? result.metadata?['gln'] as String?;
        if (gln != null && gln.isNotEmpty) {
          return GlnFormat.stripGlnInput(gln);
        }
        final digits = GlnFormat.stripGlnInput(result.data);
        return digits.length == 13 ? digits : null;

      case Gs1FieldScanKind.gtin:
        final gtin = details.gtin ?? result.metadata?['gtin'] as String?;
        if (gtin != null && gtin.isNotEmpty) {
          return GtinFormat.stripGtinInput(gtin);
        }
        final digits = GtinFormat.stripGtinInput(result.data);
        if (digits.length >= 8 && digits.length <= 14) {
          return digits;
        }
        return null;

      case Gs1FieldScanKind.sgtin:
        if (Gs1CanonicalIdentifier.isSgtin(result.data)) {
          return Gs1CanonicalIdentifier.forStorage(result.data);
        }
        final epc = EPCFormatter.formatToEPCUri(result.data);
        if (epc != null && Gs1CanonicalIdentifier.isSgtin(epc)) {
          return Gs1CanonicalIdentifier.forStorage(epc);
        }
        if (details.gtin != null && details.serial != null) {
          return Gs1Converter.gtinSerialToEpc(
            details.gtin!,
            details.serial!,
          );
        }
        return null;

      case Gs1FieldScanKind.sscc:
        final sscc = details.sscc ?? result.metadata?['sscc'] as String?;
        if (sscc != null && sscc.isNotEmpty) {
          final stripped = SsccFormat.stripSsccInput(sscc);
          if (stripped.length == 18) return stripped;
          if (stripped.length == 17) {
            return stripped.padLeft(18, '0');
          }
        }
        if (Gs1CanonicalIdentifier.isSscc(result.data)) {
          return Gs1CanonicalIdentifier.extractSscc18(result.data);
        }
        final digits = SsccFormat.stripSsccInput(result.data);
        if (digits.length == 18) return digits;
        return null;
    }
  }

  static void _showError(BuildContext context, String message) {
    context.showError(message);
  }

  static Widget scanSuffixIcon({
    required BuildContext context,
    required Gs1FieldScanKind kind,
    required ValueChanged<String> onScanned,
  }) {
    return IconButton(
      icon: TraqIcon(AppAssets.iconQr),
      tooltip: 'Scan barcode',
      onPressed: () async {
        final value = await scan(context, kind);
        if (value != null) onScanned(value);
      },
    );
  }
}
