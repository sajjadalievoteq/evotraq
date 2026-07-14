import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/data/services/epcis/cbv_vocabulary_service.dart';
import 'cbv_vocabulary_state.dart';

/// Thin adapter over [CbvVocabularyService]: mirrors the service's
/// background-loaded/cached/retried vocabulary into [CbvVocabularyState]
/// so every existing consumer (which reads this cubit's state / calls
/// [loadVocabulary]/[refresh]) keeps working unchanged, while the actual
/// loading, caching, and retry logic live in the service.
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
      // Only show a loading state if nothing is displayed yet — a
      // background revalidation of an already-loaded vocabulary shouldn't
      // flicker the UI back to a loading spinner.
      if (!state.isLoaded) {
        emit(state.copyWith(status: CbvVocabularyStatus.loading, error: null));
      }
    } else if (event.error != null) {
      // Only surface an error if there is nothing to show yet. Once loaded,
      // a transient background refresh failure keeps showing the last
      // known-good session while the service's retry loop keeps trying.
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
      // Swallowed: state is already reflected via _onEvent regardless of
      // outcome, matching the previous behavior where this never threw.
    }
  }

  Future<void> refresh() => loadVocabulary(forceRefresh: true);

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
