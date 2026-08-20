import 'package:traqtrace_app/features/operations/shared/operation_epc_type.dart';
import 'dart:async';

import 'package:traqtrace_app/core/utils/gs1/gs1_canonical_identifier.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/services/gs1/gln/gln_service.dart';
import 'package:traqtrace_app/data/services/gs1/gtin/gtin_service.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sgtin/sgtin_service.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sscc/sscc_service.dart';
import 'package:traqtrace_app/features/operations/shared/operation_epc_scan_validator.dart';

class ReferenceDataService {
  ReferenceDataService({
    required GTINService gtinService,
    required SGTINService sgtinService,
    required SSCCService ssccService,
    required GLNService glnService,
  }) : _gtinService = gtinService,
       _sgtinService = sgtinService,
       _ssccService = ssccService,
       _glnService = glnService;

  final GTINService _gtinService;
  final SGTINService _sgtinService;
  final SSCCService _ssccService;
  final GLNService _glnService;

  static const int _maxCacheEntries = 256;
  final Map<String, Future<String?>> _productNameCache = {};
  final Map<String, Future<String?>> _gtinNameCache = {};
  final Map<String, Future<GLN?>> _glnCache = {};

  Future<String?> resolveProductName(String epc) {
    final key = epc.trim();
    if (key.isEmpty) return Future.value(null);
    final cached = _productNameCache.remove(key);
    if (cached != null) {
      _productNameCache[key] = cached;
      return cached;
    }
    _evictIfNeeded(_productNameCache);
    return _productNameCache.putIfAbsent(
      key,
      () => _resolveProductNameUncached(key),
    );
  }

  Future<GLN?> resolveGln(String code) {
    final key = code.trim();
    if (key.isEmpty) return Future.value(null);
    final cached = _glnCache.remove(key);
    if (cached != null) {
      _glnCache[key] = cached;
      return cached;
    }
    _evictIfNeeded(_glnCache);
    return _glnCache.putIfAbsent(key, () async {
      try {
        return await _glnService.getGLNByCode(key);
      } catch (_) {
        return null;
      }
    });
  }

  Future<String?> _resolveProductNameUncached(String epc) async {
    final type = OperationEpcScanValidator.resolveEpcType(epc);
    if (type == OperationScanItemType.sgtin) {
      final gtinFromUri = Gs1CanonicalIdentifier.extractGtin(epc);
      if (gtinFromUri != null) {
        return _productNameForGtin(gtinFromUri);
      }
      final serial = Gs1CanonicalIdentifier.extractSerial(epc);
      if (serial == null) return null;
      try {
        final sgtin = await _sgtinService.getSGTINBySerialNumber(serial);
        return _productNameForGtin(sgtin.gtinCode);
      } catch (_) {
        return null;
      }
    }

    if (type == OperationScanItemType.sscc) {
      final ssccCode = Gs1CanonicalIdentifier.extractSscc18(epc);
      if (ssccCode == null) return null;
      try {
        final sscc = await _ssccService.getSSCCByCode(ssccCode);
        final contained = sscc.containedGtin?.trim();
        if (contained != null && contained.isNotEmpty) {
          return _productNameForGtin(contained);
        }
        final children = sscc.childSgtins;
        if (children == null || children.isEmpty) return null;
        final firstChild = children.first;
        final gtinFromUri = Gs1CanonicalIdentifier.extractGtin(firstChild);
        if (gtinFromUri != null) {
          return _productNameForGtin(gtinFromUri);
        }
        final childSerial = Gs1CanonicalIdentifier.extractSerial(firstChild);
        if (childSerial != null) {
          try {
            final sgtin = await _sgtinService.getSGTINBySerialNumber(
              childSerial,
            );
            return _productNameForGtin(sgtin.gtinCode);
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
        return _productNameForGtin(gtinCode);
      }
    }

    return null;
  }

  Future<String?> _productNameForGtin(String gtinCode) {
    final key = gtinCode.trim();
    final cached = _gtinNameCache.remove(key);
    if (cached != null) {
      _gtinNameCache[key] = cached;
      return cached;
    }
    _evictIfNeeded(_gtinNameCache);
    return _gtinNameCache.putIfAbsent(key, () async {
      try {
        final gtin = await _gtinService.getGTIN(key);
        if (gtin.tradeItemDescription?.trim().isNotEmpty == true) {
          return gtin.tradeItemDescription;
        }
        if (gtin.productName.trim().isNotEmpty) return gtin.productName;
      } catch (_) {}
      return null;
    });
  }

  void _evictIfNeeded<T>(Map<String, Future<T>> cache) {
    while (cache.length >= _maxCacheEntries) {
      cache.remove(cache.keys.first);
    }
  }
}
