import 'package:equatable/equatable.dart';
import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_item.dart';
import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_session.dart';

enum CbvVocabularyStatus { initial, loading, loaded, error }

class CbvVocabularyState extends Equatable {
  final CbvVocabularyStatus status;
  final CbvVocabularySession? session;
  final String? error;

  const CbvVocabularyState({
    this.status = CbvVocabularyStatus.initial,
    this.session,
    this.error,
  });

  bool get isLoaded => status == CbvVocabularyStatus.loaded;
  bool get isLoading => status == CbvVocabularyStatus.loading;
  bool get hasError => status == CbvVocabularyStatus.error;

  List<CbvVocabularyItem> get bizSteps => session?.bizSteps ?? [];
  List<CbvVocabularyItem> get dispositions => session?.dispositions ?? [];
  Map<String, List<String>> get bizStepValidDispositions =>
      session?.bizStepValidDispositions ?? const {};
  Map<String, List<String>> get actionBizStepCodes =>
      session?.actionBizStepCodes ?? const {};

  CbvVocabularyState copyWith({
    CbvVocabularyStatus? status,
    CbvVocabularySession? session,
    String? error,
  }) {
    return CbvVocabularyState(
      status: status ?? this.status,
      session: session ?? this.session,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, session, error];
}
