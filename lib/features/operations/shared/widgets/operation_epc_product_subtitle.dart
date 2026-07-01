import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/services/gs1/gtin/gtin_service.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sgtin/sgtin_service.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sscc/sscc_service.dart';
import 'package:traqtrace_app/features/operations/shared/operation_epc_scan_validator.dart';

/// Resolves and displays GTIN product name for SGTIN/SSCC scans in operation lists.
class OperationEpcProductSubtitle extends StatelessWidget {
  const OperationEpcProductSubtitle({super.key, required this.epc});

  final String epc;

  static Future<String?> resolveProductName(String epc) async {
    final type = OperationEpcScanValidator.resolveEpcType(epc);
    final gtinService = getIt<GTINService>();

    if (type == OperationScanItemType.sgtin) {
      final serial = _serialFromSgtinEpc(epc);
      if (serial == null) return null;
      try {
        final sgtin = await getIt<SGTINService>().getSGTINBySerialNumber(serial);
        return _productNameForGtin(gtinService, sgtin.gtinCode);
      } catch (_) {
        return null;
      }
    }

    if (type == OperationScanItemType.sscc) {
      final ssccCode = _ssccCodeFromEpc(epc);
      if (ssccCode == null) return null;
      try {
        final sscc = await getIt<SSCCService>().getSSCCByCode(ssccCode);
        final children = sscc.childSgtins;
        if (children == null || children.isEmpty) return null;
        final firstChild = children.first;
        final childSerial = _serialFromSgtinEpc(firstChild);
        if (childSerial != null) {
          try {
            final sgtin =
                await getIt<SGTINService>().getSGTINBySerialNumber(childSerial);
            return _productNameForGtin(gtinService, sgtin.gtinCode);
          } catch (_) {}
        }
        final gtinFromUri = _gtinFromSgtinEpc(firstChild);
        if (gtinFromUri != null) {
          return _productNameForGtin(gtinService, gtinFromUri);
        }
      } catch (_) {
        return null;
      }
    }

    if (type == OperationScanItemType.gtin) {
      final gtinCode = _gtinFromLgtinOrBarcode(epc);
      if (gtinCode != null) {
        return _productNameForGtin(gtinService, gtinCode);
      }
    }

    return null;
  }

  static Future<String?> _productNameForGtin(
    GTINService gtinService,
    String gtinCode,
  ) async {
    try {
      final gtin = await gtinService.getGTIN(gtinCode);
      if (gtin.tradeItemDescription?.trim().isNotEmpty == true) {
        return gtin.tradeItemDescription;
      }
      if (gtin.productName.trim().isNotEmpty) return gtin.productName;
    } catch (_) {}
    return null;
  }

  static String? _serialFromSgtinEpc(String epc) {
    if (epc.startsWith('urn:epc:id:sgtin:')) {
      final parts = epc.substring('urn:epc:id:sgtin:'.length).split('.');
      if (parts.length == 3) return parts[2];
    }
    return null;
  }

  static String? _gtinFromSgtinEpc(String epc) {
    if (epc.startsWith('urn:epc:id:sgtin:')) {
      final parts = epc.substring('urn:epc:id:sgtin:'.length).split('.');
      if (parts.length == 3) {
        return '${parts[0]}${parts[1]}';
      }
    }
    return null;
  }

  static String? _ssccCodeFromEpc(String epc) {
    if (epc.startsWith('urn:epc:id:sscc:')) {
      return epc.substring('urn:epc:id:sscc:'.length);
    }
    return null;
  }

  static String? _gtinFromLgtinOrBarcode(String epc) {
    if (epc.startsWith('urn:epc:class:lgtin:')) {
      final parts = epc.substring('urn:epc:class:lgtin:'.length).split('.');
      if (parts.length >= 2) return '${parts[0]}${parts[1]}';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: resolveProductName(epc),
      builder: (context, snapshot) {
        final name = snapshot.data;
        if (name == null || name.trim().isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            name,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }
}
