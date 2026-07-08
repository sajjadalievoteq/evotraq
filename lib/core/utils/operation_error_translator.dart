abstract final class OperationErrorTranslator {
  static String translate(
    String? raw, {
    String fallback =
        'The operation could not be completed. Check your inputs and try again.',
  }) {
    if (raw == null || raw.isEmpty) return fallback;

    if (raw.contains('SGTIN not found for EPC') ||
        raw.contains('not found for EPC')) {
      return 'One or more scanned items could not be found in the system. Please verify the barcode and try again.';
    }
    if (raw.contains('not eligible') || raw.contains('invalid state')) {
      return 'One or more items are not in a valid state for this operation (e.g. already processed or decommissioned).';
    }
    if (raw.contains('already') && raw.contains('received')) {
      return 'One or more items have already been received.';
    }
    if (raw.contains('already') && raw.contains('shipped')) {
      return 'One or more items have already been shipped.';
    }
    if (raw.contains('location') || raw.contains('GLN')) {
      return 'There is an issue with the selected location. Please verify the Ship From and Receiving locations.';
    }
    if (raw.contains('disposed') ||
        raw.contains('decommissioned') ||
        raw.contains('destroyed')) {
      return 'One or more items have been decommissioned and cannot be processed.';
    }
    if (raw.contains('expired')) {
      return 'One or more items are expired and cannot be processed.';
    }

    return fallback;
  }

  static String translateMessages(
    List<String>? messages, {
    String fallback = 'The operation could not be completed.',
  }) {
    if (messages == null || messages.isEmpty) return fallback;
    return translate(messages.first, fallback: fallback);
  }
}
