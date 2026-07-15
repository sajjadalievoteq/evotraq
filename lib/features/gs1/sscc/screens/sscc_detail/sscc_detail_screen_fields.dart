import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_model.dart';

/// Screen-owned SSCC detail field holders (same ownership pattern as GTIN/GLN).
/// Mixed into [_SSCCDetailScreenState] — not a separate form-model abstraction.
///
/// Controllers are allocated on first access and disposed from [_controllers].
/// Save reads controller text when created, otherwise the seed/hydrate value.
mixin SsccDetailScreenFields {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _seedTexts = {};

  TextEditingController _c(String key) => _controllers.putIfAbsent(
        key,
        () => TextEditingController(text: _seedTexts[key] ?? ''),
      );

  /// Save/read precedence: live controller text if allocated, else seed.
  String _text(String key) =>
      _controllers[key]?.text ?? _seedTexts[key] ?? '';

  void _setSeedOrController(String key, String value) {
    _seedTexts[key] = value;
    _controllers[key]?.text = value;
  }

  TextEditingController get ssccCodeController => _c('ssccCode');
  TextEditingController get extensionDigitController => _c('extensionDigit');
  TextEditingController get containedGtinController => _c('containedGtin');
  TextEditingController get containedQuantityController =>
      _c('containedQuantity');
  TextEditingController get containedBatchController => _c('containedBatch');
  TextEditingController get gsinController => _c('gsin');
  TextEditingController get gincController => _c('ginc');
  TextEditingController get poController => _c('po');
  TextEditingController get carrierRoutingController => _c('carrierRouting');

  void initSsccDetailFields() {
    _setSeedOrController('extensionDigit', '0');
  }

  void disposeSsccDetailFields() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _controllers.clear();
    _seedTexts.clear();
  }

  void hydrateSsccDetailFields(SSCC sscc) {
    _setSeedOrController('ssccCode', sscc.ssccCode);
    _setSeedOrController('extensionDigit', sscc.extensionDigit ?? '0');
    _setSeedOrController('containedGtin', sscc.containedGtin ?? '');
    _setSeedOrController(
      'containedQuantity',
      sscc.containedQuantity?.toString() ?? '',
    );
    _setSeedOrController('containedBatch', sscc.containedBatch ?? '');
    _setSeedOrController('gsin', sscc.gsin ?? '');
    _setSeedOrController('ginc', sscc.ginc ?? '');
    _setSeedOrController('po', sscc.purchaseOrderNumber ?? '');
    _setSeedOrController('carrierRouting', sscc.carrierRoutingCode ?? '');
  }

  String ssccCodeText() => _text('ssccCode');
  String extensionDigitText() => _text('extensionDigit');
  String containedGtinText() => _text('containedGtin');
  String containedQuantityText() => _text('containedQuantity');
  String containedBatchText() => _text('containedBatch');
  String gsinText() => _text('gsin');
  String gincText() => _text('ginc');
  String poText() => _text('po');
  String carrierRoutingText() => _text('carrierRouting');

  void setSsccFieldSeedOrController(String key, String value) =>
      _setSeedOrController(key, value);

  void clearSsccCodeFields() {
    _setSeedOrController('ssccCode', '');
    _setSeedOrController('extensionDigit', '0');
  }

  void syncExtensionDigitFromSsccCode(String ssccCode) {
    final digits = ssccCode.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return;
    _setSeedOrController('extensionDigit', digits[0]);
  }
}
