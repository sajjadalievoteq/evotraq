import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_item.dart';

class CbvVocabularySession {
  final List<CbvVocabularyItem> bizSteps;
  final List<CbvVocabularyItem> dispositions;

  const CbvVocabularySession({
    required this.bizSteps,
    required this.dispositions,
  });

  factory CbvVocabularySession.fromJson(Map<String, dynamic> json) {
    final bizStepsJson = json['bizSteps'] as List? ?? [];
    final dispositionsJson = json['dispositions'] as List? ?? [];
    return CbvVocabularySession(
      bizSteps: bizStepsJson
          .map(
            (e) => CbvVocabularyItem.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList(),
      dispositions: dispositionsJson
          .map(
            (e) => CbvVocabularyItem.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList(),
    );
  }
}
