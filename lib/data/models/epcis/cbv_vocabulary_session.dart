import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_item.dart';



class CbvVocabularySession {

  final List<CbvVocabularyItem> bizSteps;

  final List<CbvVocabularyItem> dispositions;



  /// Pair matrix from the backend: bizStep short code → list of valid

  /// disposition short codes (in the backend's preferred order).

  /// Empty when the server hasn't returned the field yet (older API version).

  final Map<String, List<String>> bizStepValidDispositions;



  /// Action → allowed bizStep codes for the ObjectEvent form (from backend).

  final Map<String, List<String>> actionBizStepCodes;



  const CbvVocabularySession({

    required this.bizSteps,

    required this.dispositions,

    this.bizStepValidDispositions = const {},

    this.actionBizStepCodes = const {},

  });



  factory CbvVocabularySession.fromJson(Map<String, dynamic> json) {

    final bizStepsJson = json['bizSteps'] as List? ?? [];

    final dispositionsJson = json['dispositions'] as List? ?? [];



    // Parse the optional pair matrix — gracefully absent on older API versions.

    final pairMapJson =

        json['bizStepValidDispositions'] as Map<String, dynamic>?;

    final Map<String, List<String>> pairMap;

    if (pairMapJson != null) {

      pairMap = pairMapJson.map(

        (k, v) => MapEntry(

          k,

          (v as List).map((e) => e as String).toList(),

        ),

      );

    } else {

      pairMap = const {};

    }



    final actionMapJson = json['actionBizStepCodes'] as Map<String, dynamic>?;

    final Map<String, List<String>> actionMap;

    if (actionMapJson != null) {

      actionMap = actionMapJson.map(

        (k, v) => MapEntry(k, (v as List).map((e) => e as String).toList()),

      );

    } else {

      actionMap = const {};

    }



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

      bizStepValidDispositions: pairMap,

      actionBizStepCodes: actionMap,

    );

  }

}


