import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/data/services/epcis/cbv_vocabulary_service.dart';
import 'cbv_vocabulary_state.dart';






class CbvVocabularyCubit extends Cubit<CbvVocabularyState> {
  final CbvVocabularyService _service;
  late final StreamSubscription<CbvVocabularyFetchEvent> _subscription;

  CbvVocabularyCubit({required CbvVocabularyService service})
      : _service = service,
        super(CbvVocabularyState(
          status: service.currentSession != null
              ? CbvVocabularyStatus.loaded
              : CbvVocabularyStatus.initial,
          session: service.currentSession,
        )) {
    _subscription = _service.events.listen(_onEvent);
  }

  void _onEvent(CbvVocabularyFetchEvent event) {
    if (event.session != null) {
      emit(state.copyWith(
        status: CbvVocabularyStatus.loaded,
        session: event.session,
        error: null,
      ));
    } else if (event.isLoading) {
      
      
      
      if (!state.isLoaded) {
        emit(state.copyWith(status: CbvVocabularyStatus.loading, error: null));
      }
    } else if (event.error != null) {
      
      
      
      if (!state.isLoaded) {
        emit(state.copyWith(
          status: CbvVocabularyStatus.error,
          error: event.error.toString(),
        ));
      }
    }
  }

  Future<void> loadVocabulary({bool forceRefresh = false}) async {
    try {
      if (forceRefresh) {
        await _service.refresh();
      } else {
        await _service.ensureLoaded();
      }
    } catch (_) {
      
      
    }
  }

  Future<void> refresh() => loadVocabulary(forceRefresh: true);

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
