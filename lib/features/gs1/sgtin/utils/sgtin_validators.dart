import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_model.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_field_validators.dart';
import 'package:traqtrace_app/features/gs1/sgtin/utils/sgtin_status_rules.dart'
    as status_rules;

final RegExp _serialRegex = RegExp(
    r'''^[A-Za-z0-9 !"%-?_]{1,20}$''');

final RegExp _batchLotRegex = RegExp(
    r'''^[A-Za-z0-9 !"%-?_]{1,20}$''');

final RegExp _epcUrnRegex = RegExp(
    r'''^urn:epc:id:sgtin:([0-9]{1,12})\.([0-9]{1,13})\.([A-Za-z0-9 !"%-?_]{1,20})$''');

final RegExp _gs1DlRegex = RegExp(
    r'''^https://id\.gs1\.org/01/(\d{14})/21/([A-Za-z0-9!"%&'()*+,\-./:;<=>?_]{1,20})$''');

String? validateSerialNumber(String? value) {
  if (value == null || value.isEmpty) return 'Serial number is required';
  if (!_serialRegex.hasMatch(value)) {
    return 'Serial number must be 1–20 characters using GS1 file-7 charset '
        r'(A-Za-z0-9 space !"%-?_)';
  }
  return null;
}

String? validateBatchLotNumber(String? value) {
  if (value == null || value.isEmpty) return null;
  if (!_batchLotRegex.hasMatch(value)) {
    return 'Batch/lot number must be 1–20 characters using GS1 file-7 charset '
        r'(A-Za-z0-9 space !"%-?_)';
  }
  return null;
}

String? validateEpcUri(String? value) {
  if (value == null || value.isEmpty) return null;
  if (_epcUrnRegex.hasMatch(value)) return null;
  if (_gs1DlRegex.hasMatch(value)) return null;
  return 'Invalid SGTIN EPC URI — expected https://id.gs1.org/01/<14digits>/21/<serial> '
      '(or urn:epc:id:sgtin:<prefix>.<ref>.<serial>)';
}

String? validateGs1DigitalLinkUri(String? value) {
  if (value == null || value.isEmpty) return null;
  if (!_gs1DlRegex.hasMatch(value)) {
    return 'Invalid GS1 Digital Link URI — expected https://id.gs1.org/01/<14digits>/21/<serial>';
  }
  return null;
}

String? validateGtin(String? value) {
  return GtinFieldValidators.validateGtinCode(value);
}

String? validateGln(String? value, {String fieldName = 'GLN'}) {
  if (value == null || value.isEmpty) return null;
  if (!RegExp(r'^\d{13}$').hasMatch(value)) {
    return '$fieldName must be exactly 13 digits';
  }
  if (!_luhnCheck(value)) {
    return '$fieldName has an invalid check digit';
  }
  return null;
}

String? validateExpiryDate(DateTime? value) {
  if (value == null) return null;
  if (!value.isAfter(DateTime.now())) {
    return 'Expiry date must be in the future';
  }
  return null;
}

String? validateExpiryAfterCommissioning(DateTime? expiryDate, DateTime? commissionedAt) {
  if (expiryDate == null || commissionedAt == null) return null;
  if (!expiryDate.isAfter(commissionedAt)) {
    return 'Expiry date must be after the commissioning date';
  }
  return null;
}

String? validateParentEpc(String? parentEpc, String? ownEpcUri) {
  if (parentEpc == null || parentEpc.isEmpty) return null;
  if (ownEpcUri != null && parentEpc == ownEpcUri) {
    return 'An SGTIN cannot be aggregated into itself';
  }
  return null;
}

String? validateStatusTransition(ItemStatus from, ItemStatus to) {
  return status_rules.validateTransition(from, to);
}

String? validateAlertCount(int count) {
  if (count < 0) return 'Alert count must be 0 or greater';
  return null;
}

String? validateSerialGuessingProbability(double? value) {
  if (value == null) return null;
  if (value < 0.0 || value > 1.0) {
    return 'Serial guessing probability must be between 0.0 and 1.0';
  }
  return null;
}

String? validateSerialEntropySeed(String? value) {
  if (value == null || value.isEmpty) return null;
  if (value.length > 255) return 'Entropy seed must be at most 255 characters';
  return null;
}

String? validateCreatedBy(String? value) {
  if (value == null || value.isEmpty) return null;
  if (value.length > 255) return 'Created by must be at most 255 characters';
  return null;
}

const Set<String> knownReportingRegimes = {
  'EU_FMD',
  'UAE_TATMEEN',
  'US_DSCSA',
  'NMPA',
  'SFDA',
  'CDSCO',
  'SASO',
};

const Set<String> knownSubmissionStatuses = {
  'ACKNOWLEDGED',
  'ACCEPTED',
  'UPLOADED',
  'SUBMITTED',
  'PENDING',
  'REJECTED',
};

final RegExp _hexHashRegex = RegExp(r'^[0-9a-fA-F]{8,128}$');

final RegExp _sgtinRefRegex = RegExp(
    r'''^(\d{8}|\d{12}|\d{13}|\d{14})/([A-Za-z0-9 !"%-?_]{1,20})$''');

String? validateReportingRegimes(List<String> regimes) {
  for (final regime in regimes) {
    if (!knownReportingRegimes.contains(regime.toUpperCase())) {
      return 'Unknown reporting regime "$regime". '
          'Allowed: ${knownReportingRegimes.join(', ')}';
    }
  }
  return null;
}

String? validateSubmissionStatus(String? value,
    {String fieldName = 'Submission status'}) {
  if (value == null || value.isEmpty) return null;
  if (!knownSubmissionStatuses.contains(value.toUpperCase())) {
    return '$fieldName must be one of: ${knownSubmissionStatuses.join(', ')}';
  }
  return null;
}

String? validateDscsaTransactionHash(String? value) {
  if (value == null || value.isEmpty) return null;
  if (!_hexHashRegex.hasMatch(value)) {
    return 'DSCSA transaction hash must be a hexadecimal string (8–128 characters)';
  }
  return null;
}

String? validateDuplicateEvidenceCount(int count) {
  if (count < 0) return 'Duplicate evidence count must be 0 or greater';
  return null;
}

String? validateControlledCustodyRef(String? value) {
  if (value == null || value.isEmpty) return null;
  if (value.length > 255) {
    return 'Controlled custody reference must be at most 255 characters';
  }
  return null;
}

String? validateOriginalSgtinRef(String? value) {
  if (value == null || value.isEmpty) return null;
  if (value.length > 256) {
    return 'Original SGTIN reference must be at most 256 characters';
  }
  if (!_sgtinRefRegex.hasMatch(value)) {
    return 'Original SGTIN reference must follow the format <gtin>/<serialNumber>';
  }
  return null;
}

bool _luhnCheck(String digits) {
  int sum = 0;
  bool odd = false;
  for (int i = digits.length - 1; i >= 0; i--) {
    int d = int.parse(digits[i]);
    if (odd) {
      d *= 2;
      if (d > 9) d -= 9;
    }
    sum += d;
    odd = !odd;
  }
  return sum % 10 == 0;
}
