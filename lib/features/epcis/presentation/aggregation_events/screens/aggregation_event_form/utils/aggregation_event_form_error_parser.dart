class AggregationEventFormCommissioningError {
  const AggregationEventFormCommissioningError({
    required this.needsCommissioning,
    required this.parentEPCs,
    required this.childEPCs,
    required this.otherErrors,
  });

  final bool needsCommissioning;
  final List<String> parentEPCs;
  final List<String> childEPCs;
  final List<String> otherErrors;
}

abstract final class AggregationEventFormErrorParser {
  static bool isValidationError(String errorMessage) =>
      errorMessage.contains('Validation Error:');

  static bool needsCommissioning(String errorMessage) =>
      errorMessage.contains('not been commissioned') ||
      errorMessage.contains('not commissioned:');

  static AggregationEventFormCommissioningError parseCommissioningError(
    String errorMessage,
  ) {
    final needsCommissioningFlag = needsCommissioning(errorMessage);
    if (!needsCommissioningFlag) {
      return const AggregationEventFormCommissioningError(
        needsCommissioning: false,
        parentEPCs: [],
        childEPCs: [],
        otherErrors: [],
      );
    }

    final parentEPCs = <String>[];
    final childEPCs = <String>[];
    final otherErrors = <String>[];

    var collectingParents = false;
    var collectingChildren = false;
    var collectingOthers = false;

    for (final line in errorMessage.split('\n')) {
      if (line.contains('Parent container not found')) {
        collectingParents = true;
        collectingChildren = false;
        collectingOthers = false;
        continue;
      } else if (line.contains('items have not been commissioned')) {
        collectingParents = false;
        collectingChildren = true;
        collectingOthers = false;
        continue;
      } else if (line.contains('Other issues:')) {
        collectingParents = false;
        collectingChildren = false;
        collectingOthers = true;
        continue;
      }

      if (line.trim().startsWith('• ')) {
        final epc = line.trim().substring(2);
        if (collectingParents) {
          parentEPCs.add(epc);
        } else if (collectingChildren) {
          childEPCs.add(epc);
        } else if (collectingOthers) {
          otherErrors.add(epc);
        }
      }
    }

    return AggregationEventFormCommissioningError(
      needsCommissioning: true,
      parentEPCs: parentEPCs,
      childEPCs: childEPCs,
      otherErrors: otherErrors,
    );
  }
}
