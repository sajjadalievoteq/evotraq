part of 'gtin_field_validators.dart';

abstract final class _GtinRegulatoryValidators {
  static String? validateMarketingAuthorizationNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Marketing Authorization Number is required';
    }
    final v = value.trim();
    if (v.length > 50) {
      return 'Marketing Authorization Number must be at most 50 characters';
    }
    if (RegExp(r'[\x00-\x1F\x7F]').hasMatch(v)) {
      return 'Marketing Authorization Number contains invalid control characters';
    }

    if (!RegExp(r"^[A-Za-z0-9][A-Za-z0-9 \-\/_\.]*$").hasMatch(v)) {
      return 'Marketing Authorization Number contains invalid characters';
    }
    return null;
  }

  static String? validateGs1CompanyPrefixLengthHelper(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    final n = int.tryParse(v);
    if (n == null) return 'GS1 Company Prefix length must be numeric';

    if (n < 4 || n > 12) return 'GS1 Company Prefix length must be 4–12';
    return null;
  }

  static String? validateGs1CompanyPrefix(String? value, {int? prefixLength}) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    if (!RegExp(r'^\d+$').hasMatch(v)) {
      return 'GS1 Company Prefix must be numeric';
    }
    if (v.length < 4 || v.length > 12) {
      return 'GS1 Company Prefix must be 4–12 digits';
    }
    if (prefixLength != null && v.length != prefixLength) {
      return 'GS1 Company Prefix must be $prefixLength digits';
    }
    return null;
  }

  static String? validateItemReference(String? value, {int? prefixLength}) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    if (!RegExp(r'^\d+$').hasMatch(v)) return 'Item Reference must be numeric';
    if (prefixLength != null) {
      final wantLen = 12 - prefixLength;
      if (wantLen <= 0) return 'Invalid GS1 Company Prefix length';
      if (v.length != wantLen) {
        return 'Item Reference must be $wantLen digits for prefix length $prefixLength';
      }
    } else {
      if (v.isEmpty || v.length > 12) {
        return 'Item Reference must be 1–12 digits';
      }
    }
    return null;
  }

  static DateTime? _parseIsoDate(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;

    final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(v);
    if (m == null) return null;
    final y = int.tryParse(m.group(1)!);
    final mo = int.tryParse(m.group(2)!);
    final d = int.tryParse(m.group(3)!);
    if (y == null || mo == null || d == null) return null;
    try {
      return DateTime(y, mo, d);
    } catch (_) {
      return null;
    }
  }

  static String? validateAuthorizationValidityFromDate(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Authorization Validity From Date is required';
    if (_parseIsoDate(v) == null) {
      return 'Authorization Validity From Date must be YYYY-MM-DD';
    }
    return null;
  }

  static String? validateAuthorizationValidityToDate(
    String? toValue, {
    required String? fromValue,
  }) {
    final to = (toValue ?? '').trim();
    if (to.isEmpty) return 'Authorization Validity To Date is required';
    final toDate = _parseIsoDate(to);
    if (toDate == null) {
      return 'Authorization Validity To Date must be YYYY-MM-DD';
    }
    final fromDate = _parseIsoDate(fromValue);
    if (fromDate == null) {
      return 'Authorization Validity From Date must be set first';
    }
    if (toDate.isBefore(fromDate)) {
      return 'Authorization Validity To Date must be ≥ From Date';
    }
    return null;
  }

  static const Set<String> _docUnitDescriptorAllowed = {
    'BASE_UNIT_OR_EACH',
    'PACK_OR_INNER_PACK',
    'CASE',
    'PALLET',
    'DISPLAY_SHIPPER',
    'MIXED_MODULE',
    'PREPACK_ASSORTMENT',
  };

  static String? mapUnitDescriptorToBackendPackagingLevel(
    String? unitDescriptor,
  ) {
    final v = (unitDescriptor ?? '').trim();
    if (v.isEmpty) return null;
    return switch (v) {
      'BASE_UNIT_OR_EACH' => 'ITEM',
      'PACK_OR_INNER_PACK' => 'PACK',
      'CASE' => 'CASE',
      'PALLET' => 'PALLET',

      'DISPLAY_SHIPPER' => null,
      'MIXED_MODULE' => null,
      'PREPACK_ASSORTMENT' => null,
      _ => null,
    };
  }

  static String? validateUnitDescriptor(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'unit_descriptor is required';
    if (!_docUnitDescriptorAllowed.contains(v)) {
      return 'unit_descriptor must be a valid GS1 code list value';
    }
    final mapped = mapUnitDescriptorToBackendPackagingLevel(v);
    if (mapped == null) {
      return 'unit_descriptor value is not supported by backend packagingLevel yet';
    }
    return null;
  }
}
