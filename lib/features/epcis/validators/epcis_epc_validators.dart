import 'package:traqtrace_app/core/utils/gs1/gs1_canonical_identifier.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/utils/aggregation_event_form_validators.dart';
import 'package:traqtrace_app/features/gs1/sgtin/utils/sgtin_validators.dart'
    as sgtin_validators;

abstract final class EpcisEpcValidators {
  static bool isLikelyEpc(String value) =>
      AggregationEventFormValidators.isLikelyEpc(value);

  static String? validateEpcOrBarcode(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'EPC is required' : null;
    }
    final trimmed = value.trim();
    // Phase 2: normalize once at the validator boundary so URN / DL / AI
    // are treated equivalently before form validation.
    final canonical = Gs1CanonicalIdentifier.forStorage(trimmed);
    if (Gs1CanonicalIdentifier.isValid(canonical) ||
        Gs1CanonicalIdentifier.isValid(trimmed) ||
        RegExp(r'\(\d+\)').hasMatch(trimmed)) {
      return AggregationEventFormValidators.validateResolvedParentEpc(
        Gs1CanonicalIdentifier.isValid(canonical) ? canonical : trimmed,
      );
    }
    return 'Invalid EPC format: $trimmed';
  }

  static String? validateEpcList(String? value, {bool required = true}) {
    if (!required && (value == null || value.trim().isEmpty)) {
      return null;
    }
    return AggregationEventFormValidators.validateChildEpcList(
      value,
      required ? 'ADD' : 'DELETE',
    );
  }

  static String? validateSgtinEpcUri(String? value) =>
      sgtin_validators.validateEpcUri(value);
}
