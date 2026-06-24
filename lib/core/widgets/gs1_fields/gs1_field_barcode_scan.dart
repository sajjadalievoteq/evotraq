import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/models/scan_result.dart';
import 'package:traqtrace_app/core/utils/barcode_utils.dart';
import 'package:traqtrace_app/features/barcode/services/epc_uri_converter.dart';
import 'package:traqtrace_app/features/barcode/widgets/gs1_barcode_scan_dialog.dart';
import 'package:traqtrace_app/features/epcis/utils/epc_formatter.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_format.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_format.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_format.dart';

/// GS1 identifier fields that support camera barcode scanning.
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

  /// Opens the camera scanner and returns a value formatted for the target field.
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
        if (result.data.startsWith('urn:epc:id:sgtin:')) {
          return result.data;
        }
        final epc = EPCFormatter.formatToEPCUri(result.data);
        if (epc != null && epc.startsWith('urn:epc:id:sgtin:')) {
          return epc;
        }
        if (details.gtin != null && details.serial != null) {
          return EPCURIConverter.convertGTINSerialToEPCUri(
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
        if (result.data.startsWith('urn:epc:id:sscc:')) {
          return _ssccDigitsFromEpcUri(result.data);
        }
        final digits = SsccFormat.stripSsccInput(result.data);
        if (digits.length == 18) return digits;
        return null;
    }
  }

  static String? _ssccDigitsFromEpcUri(String epcUri) {
    if (!epcUri.startsWith('urn:epc:id:sscc:')) return null;
    final body = epcUri.substring('urn:epc:id:sscc:'.length);
    final dot = body.indexOf('.');
    if (dot < 0) return null;
    final companyPrefix = body.substring(0, dot);
    final serialRef = body.substring(dot + 1);
    final combined = companyPrefix + serialRef;
    if (!RegExp(r'^\d+$').hasMatch(combined)) return null;
    return combined.padLeft(18, '0');
  }

  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  static Widget scanSuffixIcon({
    required BuildContext context,
    required Gs1FieldScanKind kind,
    required ValueChanged<String> onScanned,
  }) {
    return IconButton(
      icon: const Icon(Icons.qr_code_scanner),
      tooltip: 'Scan barcode',
      onPressed: () async {
        final value = await scan(context, kind);
        if (value != null) onScanned(value);
      },
    );
  }
}
