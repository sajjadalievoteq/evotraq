import 'package:traqtrace_app/core/utils/gs1_ai_normalizer.dart';
import 'package:traqtrace_app/core/utils/gs1/check_digit_utils.dart';

final _sgtinUrn = RegExp(
  r'''^urn:epc:id:sgtin:\d{1,12}\.\d{1,13}\.[!%-?A-Z_a-z"]{1,20}$''');

final _sgtinDl = RegExp(
  r'''^https://id\.gs1\.org/01/\d{14}/21/[!%-?A-Z_a-z"]{1,20}$''');

final _sgtinClassDl = RegExp(
  r'''^https://id\.gs1\.org/01/\d{14}$''');

final _ssccUrn = RegExp(
  r'''^urn:epc:id:sscc:\d{1,12}\.\d{1,17}$''');

final _ssccDl = RegExp(
  r'''^https://id\.gs1\.org/00/\d{18}$''');

final _lgtinUrn = RegExp(
  r'''^urn:epc:id:lgtin:\d{1,12}\.\d{1,13}\.[!%-?A-Z_a-z"]{1,20}$''');

final _lgtinDl = RegExp(
  r'''^https://id\.gs1\.org/01/\d{14}/10/[!%-?A-Z_a-z"]{1,20}$''');

final _graiUrn = RegExp(
  r'''^urn:epc:id:grai:\d{1,12}\.\d{1,11}\.[!%-?A-Z_a-z"]{1,16}$''');

final _giaiUrn = RegExp(
  r'''^urn:epc:id:giai:\d{1,12}\.[!%-?A-Z_a-z"]{1,24}$''');

final _sglnUrn = RegExp(
  r'''^urn:epc:id:sgln:\d{1,12}\.\d{1,12}\.[!%-?A-Z_a-z"0-9]{0,20}$''');


bool isValidEpcUri(String input) {
  if (input.isEmpty) return false;
  final normalized = normalizeEpcInput(input);
  return _isValidNormalized(normalized);
}

String? validateEpcUriField(String? value, {bool required = false}) {
  if (value == null || value.trim().isEmpty) {
    return required ? 'EPC is required' : null;
  }
  final trimmed = value.trim();
  final normalized = normalizeEpcInput(trimmed);
  if (_isValidNormalized(normalized)) return null;

  if (trimmed.startsWith('(')) {
    return 'GS1 barcode could not be converted to a valid EPC URI — '
        'check the GTIN/SSCC digits and serial number';
  }
  if (trimmed.startsWith('urn:epc:')) {
    return 'Invalid EPC URI format — check prefix, dots, and character set';
  }
  if (trimmed.startsWith('https://id.gs1.org/')) {
    return 'Invalid GS1 Digital Link URI format';
  }
  return 'Not a valid EPC URI. Accepted formats:\n'
      '• https://id.gs1.org/01/<14digits>/21/<serial>  — GS1 Digital Link (preferred)\n'
      '• https://id.gs1.org/00/<18digits>  — SSCC Digital Link\n'
      '• (01)<GTIN>(21)<serial>  — GS1 barcode\n'
      '• urn:epc:id:sgtin:<prefix>.<ref>.<serial>  (accepted)\n'
      '• urn:epc:id:sscc:<prefix>.<serialRef>  (accepted)';
}

String normalizeEpc(String input) => normalizeEpcInput(input.trim());

String? epcUriType(String input) {
  final n = normalizeEpcInput(input.trim());
  if (_sgtinUrn.hasMatch(n) || _sgtinDl.hasMatch(n) || _sgtinClassDl.hasMatch(n)) {
    return 'SGTIN';
  }
  if (_ssccUrn.hasMatch(n) || _ssccDl.hasMatch(n)) return 'SSCC';
  if (_lgtinUrn.hasMatch(n) || _lgtinDl.hasMatch(n)) return 'LGTIN';
  if (_graiUrn.hasMatch(n)) return 'GRAI';
  if (_giaiUrn.hasMatch(n)) return 'GIAI';
  if (_sglnUrn.hasMatch(n)) return 'SGLN';
  if (_isLegacyPrefix(n)) return 'Class/Pattern';
  return null;
}


bool _isValidNormalized(String n) {
  if (n.isEmpty) return false;
  if (_sgtinUrn.hasMatch(n)) return true;
  if (_sgtinDl.hasMatch(n)) return _validateSgtinDlCheckDigit(n);
  if (_sgtinClassDl.hasMatch(n)) return _validateSgtinDlCheckDigit(n);
  return _ssccUrn.hasMatch(n) ||
      _ssccDl.hasMatch(n) ||
      _lgtinUrn.hasMatch(n) ||
      _lgtinDl.hasMatch(n) ||
      _graiUrn.hasMatch(n) ||
      _giaiUrn.hasMatch(n) ||
      _sglnUrn.hasMatch(n) ||
      _isLegacyPrefix(n);
}

bool _isLegacyPrefix(String n) =>
    n.startsWith('urn:epc:class:') ||
    n.startsWith('urn:epc:idpat:') ||
    n.startsWith('urn:epc:tag:');

bool _validateSgtinDlCheckDigit(String uri) {
  const prefix = 'https://id.gs1.org/01/';
  if (!uri.startsWith(prefix)) return false;
  final after = uri.substring(prefix.length);
  if (after.length < 14) return false;
  final gtin14 = after.substring(0, 14);
  if (!RegExp(r'^\d{14}$').hasMatch(gtin14)) return false;
  return _isValidGtinCheckDigit(gtin14);
}

bool _isValidGtinCheckDigit(String digits) {
  return CheckDigitUtils.isValidMod10(digits);
}
