/// Human-readable labels for GS1 CBV biz steps, dispositions, and lifecycle status.
abstract final class CbvDisplayUtils {
  static const String cbvUrlPrefix = 'https://ref.gs1.org/cbv/';
  static const String bizStepUrnPrefix = 'urn:epcglobal:cbv:bizstep:';
  static const String dispUrnPrefix = 'urn:epcglobal:cbv:disp:';

  /// Extracts the canonical short token (e.g. `shipping`, `in_transit`).
  static String? shortName(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    if (trimmed.startsWith(cbvUrlPrefix)) {
      final tail = trimmed.substring(cbvUrlPrefix.length);
      final hyphen = tail.indexOf('-');
      if (hyphen != -1 && hyphen < tail.length - 1) {
        return tail.substring(hyphen + 1);
      }
      return tail;
    }
    if (trimmed.startsWith(bizStepUrnPrefix)) {
      return trimmed.substring(bizStepUrnPrefix.length);
    }
    if (trimmed.startsWith(dispUrnPrefix)) {
      return trimmed.substring(dispUrnPrefix.length);
    }
    if (trimmed.contains('BizStep-')) {
      return trimmed.split('BizStep-').last;
    }
    if (trimmed.contains('Disp-')) {
      return trimmed.split('Disp-').last;
    }
    if (trimmed.contains(':')) {
      return trimmed.split(':').last;
    }
    return trimmed;
  }

  /// Display label for a CBV biz-step URI/URL or short name.
  static String displayBizStep(String? value, {String fallback = 'Unknown'}) {
    return _display(shortName(value), fallback: fallback);
  }

  /// Display label for a CBV disposition URI/URL or short name.
  static String displayDisposition(String? value, {String fallback = 'Unknown'}) {
    return _display(shortName(value), fallback: fallback);
  }

  /// Display label for XS-017 / master-data lifecycle status (e.g. `IN_TRANSIT`).
  static String displayLifecycleStatus(String? value, {String fallback = '—'}) {
    return _display(shortName(value), fallback: fallback);
  }

  static String _display(String? token, {required String fallback}) {
    if (token == null || token.isEmpty) return fallback;
    return _humanizeToken(token);
  }

  static String _humanizeToken(String raw) {
    var token = raw;
    if (token.contains('/')) {
      token = token.split('/').last;
    }

    final words = token
        .split(RegExp(r'[_\-\s]+'))
        .where((w) => w.isNotEmpty)
        .map((w) {
          if (w.length == 1) return w.toUpperCase();
          final lower = w.toLowerCase();
          return '${lower[0].toUpperCase()}${lower.substring(1)}';
        })
        .toList();

    if (words.isEmpty) return raw;
    return words.join(' ');
  }
}
