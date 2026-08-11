enum EpcisImportGate { format, schema, content }

class EpcisImportIssue {
  const EpcisImportIssue({
    required this.gate,
    required this.path,
    required this.reason,
  });

  final EpcisImportGate gate;
  final String path;
  final String reason;

  @override
  String toString() => '$path: $reason';
}

class EpcisImportValidationResult {
  const EpcisImportValidationResult({required this.issues, this.document});

  final List<EpcisImportIssue> issues;
  final Map<String, dynamic>? document;

  bool get isValid => issues.isEmpty && document != null;

  List<EpcisImportIssue> forGate(EpcisImportGate gate) =>
      issues.where((i) => i.gate == gate).toList();

  String summarize() {
    if (isValid) return 'Document conforms to the EPCIS import template.';
    final buf = StringBuffer();
    for (final gate in EpcisImportGate.values) {
      final group = forGate(gate);
      if (group.isEmpty) continue;
      buf.writeln('${gate.name.toUpperCase()}:');
      for (final issue in group) {
        buf.writeln('  • $issue');
      }
    }
    return buf.toString().trim();
  }
}
