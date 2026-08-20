import 'package:traqtrace_app/features/gs1_tools/utils/epcis_import_validation_result.dart';

void validateEpcisIsoInstant(
  String? value,
  String path,
  List<EpcisImportIssue> issues,
) {
  if (value == null || value.trim().isEmpty) {
    issues.add(
      EpcisImportIssue(
        gate: EpcisImportGate.content,
        path: path,
        reason: 'ISO-8601 date-time is required',
      ),
    );
    return;
  }
  try {
    DateTime.parse(value);
  } on FormatException {
    issues.add(
      EpcisImportIssue(
        gate: EpcisImportGate.content,
        path: path,
        reason: 'Invalid ISO-8601 date-time: $value',
      ),
    );
  }
}
