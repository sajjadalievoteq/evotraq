import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_item.dart';

String cbvPairingKey(String bizCode, String dispCode) => '$bizCode|$dispCode';

Map<String, List<String>> cbvPairMapWith(
  Map<String, List<String>> current,
  String bizCode,
  String dispCode, {
  required bool add,
}) {
  final copy = {
    for (final e in current.entries) e.key: List<String>.from(e.value),
  };
  if (add) {
    copy.putIfAbsent(bizCode, () => []);
    if (!copy[bizCode]!.contains(dispCode)) {
      copy[bizCode]!.add(dispCode);
    }
  } else {
    copy[bizCode]?.remove(dispCode);
  }
  return copy;
}

List<CbvVocabularyItem> cbvReplaceEnabled(
  List<CbvVocabularyItem> items,
  String code, {
  required bool enabled,
}) {
  return items.map((item) {
    if (item.code != code) return item;
    return item.copyWith(enabled: enabled);
  }).toList();
}
