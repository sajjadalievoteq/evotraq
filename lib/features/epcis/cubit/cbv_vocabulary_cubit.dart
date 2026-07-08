import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/data/services/epcis/cbv_master_data_service.dart';
import 'cbv_vocabulary_state.dart';

class CbvVocabularyCubit extends Cubit<CbvVocabularyState> {
  final CbvMasterDataService _service;

  CbvVocabularyCubit({required CbvMasterDataService service})
      : _service = service,
        super(const CbvVocabularyState());

  Future<void> loadVocabulary({bool forceRefresh = false}) async {
    if (state.isLoading) return;
    if (state.isLoaded && !forceRefresh) return;

    emit(state.copyWith(status: CbvVocabularyStatus.loading, error: null));
    try {
      final session = await _service.loadVocabularySession(
        forceRefresh: forceRefresh,
      );
      emit(state.copyWith(
        status: CbvVocabularyStatus.loaded,
        session: session,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CbvVocabularyStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> refresh() => loadVocabulary(forceRefresh: true);
}
