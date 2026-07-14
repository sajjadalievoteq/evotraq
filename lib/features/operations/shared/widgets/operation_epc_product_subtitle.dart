import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_canonical_identifier.dart';
import 'package:traqtrace_app/data/services/gs1/gtin/gtin_service.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sgtin/sgtin_service.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sscc/sscc_service.dart';
import 'package:traqtrace_app/features/operations/shared/operation_epc_scan_validator.dart';

class OperationEpcProductSubtitle extends StatelessWidget {
  const OperationEpcProductSubtitle({
    super.key,
    required this.epc,
    this.productName,
  });

  final String epc;
  final String? productName;

  /// Session-scoped memoization keyed by EPC. Caching the *Future* both
  /// deduplicates concurrent lookups (in-flight guard) and prevents re-fetching
  /// on every rebuild — the FutureBuilder below gets the same completed future
  /// for a given EPC instead of issuing fresh /sgtins/serial + /gtins/code calls
  /// each time the (always-mounted, on desktop) items panel rebuilds.
  static const int _maxCacheEntries = 256;
  static final Map<String, Future<String?>> _resolveCache = {};
  static final Map<String, Future<String?>> _gtinNameCache = {};

  static Future<String?> resolveProductName(String epc) {
    final cached = _resolveCache.remove(epc);
    if (cached != null) {
      // Re-insert so this key becomes most-recently used.
      _resolveCache[epc] = cached;
      return cached;
    }
    while (_resolveCache.length >= _maxCacheEntries) {
      _resolveCache.remove(_resolveCache.keys.first);
    }
    return _resolveCache.putIfAbsent(epc, () => _resolveProductNameUncached(epc));
  }

  static Future<String?> _resolveProductNameUncached(String epc) async {
    final type = OperationEpcScanValidator.resolveEpcType(epc);
    final gtinService = getIt<GTINService>();

    if (type == OperationScanItemType.sgtin) {
      // Prefer GTIN from EPC URI — avoids an extra SGTIN-by-serial round trip.
      final gtinFromUri = Gs1CanonicalIdentifier.extractGtin(epc);
      if (gtinFromUri != null) {
        return _productNameForGtin(gtinService, gtinFromUri);
      }
      final serial = Gs1CanonicalIdentifier.extractSerial(epc);
      if (serial == null) return null;
      try {
        final sgtin = await getIt<SGTINService>().getSGTINBySerialNumber(serial);
        return _productNameForGtin(gtinService, sgtin.gtinCode);
      } catch (_) {
        return null;
      }
    }

    if (type == OperationScanItemType.sscc) {
      final ssccCode = Gs1CanonicalIdentifier.extractSscc18(epc);
      if (ssccCode == null) return null;
      try {
        final sscc = await getIt<SSCCService>().getSSCCByCode(ssccCode);
        final contained = sscc.containedGtin?.trim();
        if (contained != null && contained.isNotEmpty) {
          return _productNameForGtin(gtinService, contained);
        }
        final children = sscc.childSgtins;
        if (children == null || children.isEmpty) return null;
        final firstChild = children.first;
        final gtinFromUri = Gs1CanonicalIdentifier.extractGtin(firstChild);
        if (gtinFromUri != null) {
          return _productNameForGtin(gtinService, gtinFromUri);
        }
        final childSerial = Gs1CanonicalIdentifier.extractSerial(firstChild);
        if (childSerial != null) {
          try {
            final sgtin =
                await getIt<SGTINService>().getSGTINBySerialNumber(childSerial);
            return _productNameForGtin(gtinService, sgtin.gtinCode);
          } catch (_) {}
        }
      } catch (_) {
        return null;
      }
    }

    if (type == OperationScanItemType.gtin ||
        Gs1CanonicalIdentifier.isLotOrClassLevel(epc)) {
      final gtinCode = Gs1CanonicalIdentifier.extractGtin(epc);
      if (gtinCode != null) {
        return _productNameForGtin(gtinService, gtinCode);
      }
    }

    return null;
  }

  static Future<String?> _productNameForGtin(
    GTINService gtinService,
    String gtinCode,
  ) {
    final cached = _gtinNameCache.remove(gtinCode);
    if (cached != null) {
      _gtinNameCache[gtinCode] = cached;
      return cached;
    }
    while (_gtinNameCache.length >= _maxCacheEntries) {
      _gtinNameCache.remove(_gtinNameCache.keys.first);
    }
    return _gtinNameCache.putIfAbsent(gtinCode, () async {
      try {
        final gtin = await gtinService.getGTIN(gtinCode);
        if (gtin.tradeItemDescription?.trim().isNotEmpty == true) {
          return gtin.tradeItemDescription;
        }
        if (gtin.productName.trim().isNotEmpty) return gtin.productName;
      } catch (_) {}
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (productName != null) {
      return _productNameText(productName);
    }

    return FutureBuilder<String?>(
      future: resolveProductName(epc),
      builder: (context, snapshot) {
        return _productNameText(snapshot.data);
      },
    );
  }

  Widget _productNameText(String? name) {
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
  }
}
