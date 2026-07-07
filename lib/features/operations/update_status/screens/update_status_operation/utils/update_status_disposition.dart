import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_formatter.dart';

enum UpdateStatusDisposition {
  sample('non_sellable_other', 'Sample'),
  lost('unknown', 'Lost'),
  stolen('stolen', 'Stolen'),
  damaged('damaged', 'Damaged'),
  dispensing('dispensed', 'Dispensing'),
  export('in_transit', 'Export');

  const UpdateStatusDisposition(this.code, this.label);

  /// GS1 CBV 2.0 disposition code sent to the backend.
  final String code;

  /// Human-readable label shown in the UI.
  final String label;

  /// Resolves a disposition from a short CBV code, HTTPS URI, or EPCIS 1.x URN.
  static UpdateStatusDisposition? fromCode(String? code) {
    if (code == null) return null;
    final normalised =
        CbvVocabularyFormatter.shortName(code.trim()).toLowerCase();
    for (final d in values) {
      if (d.code == normalised || d.name == normalised) return d;
    }
    return null;
  }

  /// User-facing status label for any stored disposition form.
  static String labelFor(String? code) =>
      fromCode(code)?.label ?? code ?? '-';
}
