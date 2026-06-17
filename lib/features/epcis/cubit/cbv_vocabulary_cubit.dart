import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/data/services/epcis/cbv_master_data_service.dart';
import 'cbv_vocabulary_state.dart';

/// Singleton cubit that owns the CBV vocabulary for the entire app lifetime.
///
/// Load once during the splash screen — every widget that needs vocabulary
/// reads from this cubit instead of making its own API call.
class CbvVocabularyCubit extends Cubit<CbvVocabularyState> {
  final CbvMasterDataService _service;

  CbvVocabularyCubit({required CbvMasterDataService service})
      : _service = service,
        super(const CbvVocabularyState());

  /// Load vocabulary from the API.
  ///
  /// No-ops if already loaded unless [forceRefresh] is true.
  /// Safe to call concurrently — a second call while loading is ignored.
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

  /// Force a fresh fetch (e.g. after an admin toggle of enabled flags).
  Future<void> refresh() => loadVocabulary(forceRefresh: true);
}
