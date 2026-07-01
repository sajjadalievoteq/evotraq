import 'package:traqtrace_app/features/epcis/validators/epcis_gln_validators.dart';

/// Disposition / GLN checks for pharma return actions.
class PharmaReturnEligibility {
  PharmaReturnEligibility._();

  static String? normalizeGln(String? gln) {
    if (gln == null || gln.trim().isEmpty) return null;
    return EpcisGlnValidators.parseGlnToCode(gln.trim());
  }

  static bool glnMatches(String? userGln, String? expectedGln) {
    final normalizedUser = normalizeGln(userGln);
    final normalizedExpected = normalizeGln(expectedGln);
    if (normalizedUser == null || normalizedExpected == null) return false;
    return normalizedUser == normalizedExpected;
  }

  static bool isAcceptingInStock({
    required String? businessStep,
    required String? disposition,
  }) {
    if (businessStep == null || disposition == null) return false;
    return businessStep.toLowerCase().contains('accepting') &&
        disposition.toLowerCase().contains('in_stock');
  }

  static bool isReceivingInProgress(String? disposition) {
    if (disposition == null || disposition.trim().isEmpty) return false;
    return disposition.toLowerCase().contains('in_progress');
  }

  static bool isReturnShippingInTransit({
    required String? businessStep,
    required String? disposition,
  }) {
    if (businessStep == null || disposition == null) return false;
    final step = businessStep.toLowerCase();
    final disp = disposition.toLowerCase();
    return step.contains('returning') && disp.contains('in_transit');
  }

  /// True when the return has already been received by the original shipper
  /// (accepting + returned / recalled / damaged disposition).
  /// Used to suppress the "Accept Return" button when the cycle is complete.
  static bool isReturnAlreadyReceived({
    required String? businessStep,
    required String? disposition,
  }) {
    if (businessStep == null || disposition == null) return false;
    final step = businessStep.toLowerCase();
    final disp = disposition.toLowerCase();
    if (!step.contains('accepting')) return false;
    return disp.contains('returned') ||
        disp.contains('recalled') ||
        disp.contains('damaged');
  }
}
