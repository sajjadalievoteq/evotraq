import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';

/// GLN code with human-readable labels snapshotted at operation post time.
class OperationGlnDisplay {
  const OperationGlnDisplay({
    required this.glnCode,
    this.locationName,
    this.city,
  });

  final String glnCode;
  final String? locationName;
  final String? city;

  static OperationGlnDisplay? fromGln(GLN? gln) {
    if (gln == null || gln.glnCode.trim().isEmpty) return null;
    return OperationGlnDisplay(
      glnCode: gln.glnCode.trim(),
      locationName: _nonEmpty(gln.locationName),
      city: _nonEmpty(gln.city),
    );
  }

  static OperationGlnDisplay? fromJson(dynamic json) {
    if (json is! Map) return null;
    final code = _nonEmpty(json['glnCode']?.toString());
    if (code == null) return null;
    return OperationGlnDisplay(
      glnCode: code,
      locationName: _nonEmpty(json['locationName']?.toString()),
      city: _nonEmpty(json['city']?.toString()),
    );
  }

  Map<String, dynamic> toJson() => {
        'glnCode': glnCode,
        if (locationName != null) 'locationName': locationName,
        if (city != null) 'city': city,
      };

  static String? _nonEmpty(String? value) {
    if (value == null) return null;
    final text = value.trim();
    return text.isEmpty ? null : text;
  }
}
