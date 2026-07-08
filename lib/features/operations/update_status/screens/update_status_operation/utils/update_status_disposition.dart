import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_formatter.dart';

enum UpdateStatusDisposition {
  sample('non_sellable_other', 'Sample'),
  lost('unknown', 'Lost'),
  stolen('stolen', 'Stolen'),
  damaged('damaged', 'Damaged'),
  dispensing('dispensed', 'Dispensing'),
  export('in_transit', 'Export');

  const UpdateStatusDisposition(this.code, this.label);

  final String code;

  final String label;

  static UpdateStatusDisposition? fromCode(String? code) {
    if (code == null) return null;
    final normalised =
        CbvVocabularyFormatter.shortName(code.trim()).toLowerCase();
    for (final d in values) {
      if (d.code == normalised || d.name == normalised) return d;
    }
    return null;
  }

  static String labelFor(String? code) =>
      fromCode(code)?.label ?? code ?? '-';
}
