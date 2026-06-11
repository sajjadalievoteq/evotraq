import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/utilities/object_event_form_constants.dart';
import 'package:traqtrace_app/features/gs1/utils/gs1_utils.dart';

/// Shared validation helpers for object event create/edit forms.
class ObjectEventFormValidators {
  ObjectEventFormValidators._();

  /// Parses GLN from 13-digit code or GS1 element-string / URN forms.
  static String parseGlnToCode(String input) {
    final clean = input.trim();
    final extracted = GS1Utils.extractGLNCode(clean);
    if (extracted != null && RegExp(r'^\d{13}$').hasMatch(extracted)) {
      return extracted;
    }
    if (RegExp(r'^\d{13}$').hasMatch(clean)) {
      return clean;
    }
    if (clean.contains('.') && !clean.startsWith('urn:')) {
      final parts = clean.split('.');
      if (parts.length >= 2) {
        final companyPrefix = parts[0];
        final locationRef = parts[1].padLeft(5, '0');
        if (companyPrefix.length >= 7 && companyPrefix.length <= 10) {
          final withoutCheck = companyPrefix + locationRef;
          return withoutCheck + GS1Utils.calculateGS1CheckDigit(withoutCheck);
        }
      }
    }
    return clean;
  }

  static String? validateLocationGln(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Please enter the location GLN' : null;
    }
    try {
      final code = parseGlnToCode(value);
      if (!RegExp(r'^\d{13}$').hasMatch(code)) {
        return 'GLN must resolve to exactly 13 digits';
      }
      final expectedCheck =
          GS1Utils.calculateGS1CheckDigit(code.substring(0, 12));
      if (code[12] != expectedCheck) {
        return 'Invalid GLN check digit';
      }
      return null;
    } catch (_) {
      return 'Invalid GLN format';
    }
  }

  static String? validateBusinessStepCbv(String? value) {
    if (value == null || value.isEmpty) {
      return 'Business Step is required by GS1 standard';
    }
    if (!objectEventStandardBusinessSteps.contains(value) &&
        !value.startsWith('urn:epcglobal:cbv:bizstep:')) {
      return 'Business Step should follow the GS1 CBV format';
    }
    return null;
  }

  static String? validateDispositionCbv(String? value) {
    if (value == null || value.isEmpty) {
      return 'Disposition is required by GS1 standard';
    }
    return null;
  }

  static String? validateCustomBusinessStep(String value) {
    if (!value.startsWith('urn:epcglobal:cbv:bizstep:')) {
      return 'Business Step should follow the GS1 CBV format';
    }
    return null;
  }

  static String? validateCustomDisposition(String value) {
    if (!value.startsWith('urn:epcglobal:cbv:disp:')) {
      return 'Disposition should follow the GS1 CBV format';
    }
    return null;
  }

  static String? validateLotNumber(String? value, {required bool isAddAction}) {
    if (isAddAction && (value == null || value.trim().isEmpty)) {
      return 'Lot number is required for commissioning events (ADD action)';
    }
    if (value != null && value.isNotEmpty) {
      if (value.trim().length < 2) {
        return 'Lot number must be at least 2 characters long';
      }
      if (!RegExp(r'^[A-Za-z0-9\-_\.]+$').hasMatch(value.trim())) {
        return 'Lot number can only contain letters, numbers, hyphens, underscores, and dots';
      }
    }
    return null;
  }

  static String? validateTimeZone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Time zone is required by GS1 standard';
    }
    return null;
  }

  static String? validateAction(String? value) {
    if (value == null || value.isEmpty) {
      return 'Action is required by GS1 standard (ADD, OBSERVE, or DELETE)';
    }
    return null;
  }
}
