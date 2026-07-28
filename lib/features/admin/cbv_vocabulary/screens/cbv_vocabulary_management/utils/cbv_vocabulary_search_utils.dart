import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_item.dart';

String normalizeCbvSearchQuery(String query) => query.trim().toLowerCase();

List<String> filterBizStepCodes({
  required List<CbvVocabularyItem> bizSteps,
  required String searchQuery,
}) {
  final q = normalizeCbvSearchQuery(searchQuery);
  final byCode = {for (final b in bizSteps) b.code: b};
  final allCodes = bizSteps.map((b) => b.code).toList();
  return allCodes.where((code) {
    if (q.isEmpty) return true;
    final item = byCode[code];
    if (item == null) return false;
    return item.label.toLowerCase().contains(q) || code.contains(q);
  }).toList();
}

List<CbvVocabularyItem> filterCbvVocabularyItems({
  required List<CbvVocabularyItem> items,
  required String searchQuery,
}) {
  final q = normalizeCbvSearchQuery(searchQuery);
  if (q.isEmpty) return items;
  return items.where((item) {
    return item.label.toLowerCase().contains(q) ||
        item.code.toLowerCase().contains(q) ||
        item.urn.toLowerCase().contains(q) ||
        (item.group?.toLowerCase().contains(q) ?? false);
  }).toList();
}
