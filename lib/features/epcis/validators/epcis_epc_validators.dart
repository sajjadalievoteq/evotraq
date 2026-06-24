import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/utils/aggregation_event_form_validators.dart';
import 'package:traqtrace_app/features/gs1/sgtin/utils/sgtin_validators.dart'
    as sgtin_validators;

/// Shared EPC / barcode validation for EPCIS event forms.
abstract final class EpcisEpcValidators {
  static bool isLikelyEpc(String value) =>
      AggregationEventFormValidators.isLikelyEpc(value);

  static String? validateEpcOrBarcode(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'EPC is required' : null;
    }
    final trimmed = value.trim();
    if (trimmed.startsWith('urn:epc:id:') ||
        RegExp(r'\(\d+\)').hasMatch(trimmed) ||
        trimmed.startsWith('https://id.gs1.org/')) {
      return AggregationEventFormValidators.validateResolvedParentEpc(trimmed);
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
