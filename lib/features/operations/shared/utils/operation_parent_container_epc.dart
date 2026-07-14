import 'package:traqtrace_app/core/utils/gs1/gs1_canonical_identifier.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/utils/aggregation_event_form_validators.dart';

/// Resolves the stored parent-container key from a parsed scan.
String parentContainerIdFromParsed(EPCParseResult parsed) {
  return switch (parsed.type) {
    EPCType.sscc => parsed.sscc ?? parsed.raw,
    EPCType.sgtin => parsed.epc,
    _ => parsed.epc,
  };
}

/// Returns a user-facing error when [parsed] cannot be used as parent container.
String? validateParentContainerEpc(EPCParseResult parsed) {
  return switch (parsed.type) {
    EPCType.sscc => () {
        final sscc = parsed.sscc ?? parsed.raw;
        final technical =
            AggregationEventFormValidators.validateSsccInput(sscc);
        if (technical == null) return null;
        if (technical.toLowerCase().contains('check digit')) {
          return 'The SSCC check digit is invalid. Re-scan the 18-digit carton or pallet barcode.';
        }
        return 'Enter a valid SSCC — scan the 18-digit barcode on the carton or pallet, or use a (00)… GS1 label.';
      }(),
    EPCType.sgtin => () {
        final technical =
            AggregationEventFormValidators.validateChildEpcEntry(parsed.epc);
        if (technical == null) return null;
        return 'The case or bundle serial is not valid. Scan a GS1 label with GTIN and serial number.';
      }(),
    _ =>
      'Parent container must be an SSCC (carton/pallet) or a case-level SGTIN (GTIN + serial).',
  };
}

bool isValidParentContainerId(String? id) {
  if (id == null || id.isEmpty) return false;
  if (Gs1CanonicalIdentifier.isSerializedInstance(id)) return true;
  return RegExp(r'^\d{18}$').hasMatch(id);
}
