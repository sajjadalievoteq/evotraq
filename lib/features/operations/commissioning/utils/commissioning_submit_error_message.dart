import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';

/// Resolves a user-visible message when bulk commissioning fails or partially fails.
String commissioningSubmitErrorMessage(CommissioningResponse response) {
  final failedItems =
      response.itemResults?.where((r) => !r.success).toList() ?? const [];

  if (failedItems.isNotEmpty) {
    final lines = failedItems
        .map((item) {
          final serial = item.serialNumber.trim();
          final detail = item.errorMessage?.trim();
          if (detail != null && detail.isNotEmpty) {
            return serial.isEmpty ? detail : '$serial: $detail';
          }
          return serial.isEmpty
              ? 'One or more serials failed commissioning.'
              : '$serial: commissioning failed';
        })
        .toList();
    return lines.join('\n');
  }

  if (response.messages != null && response.messages!.isNotEmpty) {
    return response.messages!.first;
  }

  return 'No items were successfully commissioned.';
}
