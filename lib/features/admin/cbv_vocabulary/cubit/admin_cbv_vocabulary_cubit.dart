import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_item.dart';
import 'package:traqtrace_app/data/services/epcis/cbv_master_data_service.dart';
import 'package:traqtrace_app/features/epcis/cubit/cbv_vocabulary_cubit.dart';
import 'admin_cbv_vocabulary_state.dart';

class AdminCbvVocabularyCubit extends Cubit<AdminCbvVocabularyState> {
  AdminCbvVocabularyCubit({
    CbvMasterDataService? service,
    CbvVocabularyCubit? vocabCubit,
  })  : _service = service ?? GetIt.instance<CbvMasterDataService>(),
        _vocabCubit = vocabCubit ?? GetIt.instance<CbvVocabularyCubit>(),
        super(const AdminCbvVocabularyState());

  final CbvMasterDataService _service;
  final CbvVocabularyCubit _vocabCubit;

  // ──────────────────────────────────────────────────────────────────────────
  // Load
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> load({bool forceRefresh = false}) async {
    if (state.isLoading) return;
    if (state.isLoaded && !forceRefresh) return;

    emit(state.copyWith(
      status: AdminCbvVocabularyStatus.loading,
      clearError: true,
    ));
    try {
      final session = await _service.loadVocabularySession(
        forceRefresh: true,
        enabledOnly: false,
      );
      emit(state.copyWith(
        status: AdminCbvVocabularyStatus.loaded,
        bizSteps: session.bizSteps,
        dispositions: session.dispositions,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AdminCbvVocabularyStatus.error,
        error: e.toString(),
      ));
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Toggle enabled (optimistic PATCH)
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> toggleBizStep(String code, {required bool enabled}) =>
      _toggle(
        code: code,
        enabled: enabled,
        current: state.bizSteps,
        apiCall: () => _service.toggleBizStepEnabled(code, enabled: enabled),
        onUpdated: (updated) => emit(state.copyWith(bizSteps: updated)),
      );

  Future<void> toggleDisposition(String code, {required bool enabled}) =>
      _toggle(
        code: code,
        enabled: enabled,
        current: state.dispositions,
        apiCall: () =>
            _service.toggleDispositionEnabled(code, enabled: enabled),
        onUpdated: (updated) => emit(state.copyWith(dispositions: updated)),
      );

  Future<void> _toggle({
    required String code,
    required bool enabled,
    required List<CbvVocabularyItem> current,
    required Future<void> Function() apiCall,
    required void Function(List<CbvVocabularyItem>) onUpdated,
  }) async {
    if (state.togglingCodes.contains(code)) return;

    final toggled = _replaceEnabled(current, code, enabled: enabled);
    emit(state.copyWith(togglingCodes: {...state.togglingCodes, code}));
    onUpdated(toggled);

    try {
      await apiCall();
      emit(state.copyWith(
        togglingCodes: {...state.togglingCodes}..remove(code),
      ));
      _vocabCubit.refresh();
    } catch (e) {
      final reverted = _replaceEnabled(current, code, enabled: !enabled);
      emit(state.copyWith(
        togglingCodes: {...state.togglingCodes}..remove(code),
      ));
      onUpdated(reverted);
      rethrow;
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Create custom items
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> createBizStep({
    required String code,
    required String label,
    required String group,
    required String urn,
    required bool enabled,
    required String cbvVersion,
  }) async {
    emit(state.copyWith(isCreating: true));
    try {
      final item = await _service.createBizStep(
        code: code,
        label: label,
        group: group,
        urn: urn,
        enabled: enabled,
        cbvVersion: cbvVersion,
      );
      emit(state.copyWith(
        bizSteps: [...state.bizSteps, item],
        isCreating: false,
      ));
      _vocabCubit.refresh();
    } catch (e) {
      emit(state.copyWith(isCreating: false));
      rethrow;
    }
  }

  Future<void> createDisposition({
    required String code,
    required String label,
    required String group,
    required String urn,
    required bool enabled,
    required String cbvVersion,
  }) async {
    emit(state.copyWith(isCreating: true));
    try {
      final item = await _service.createDisposition(
        code: code,
        label: label,
        group: group,
        urn: urn,
        enabled: enabled,
        cbvVersion: cbvVersion,
      );
      emit(state.copyWith(
        dispositions: [...state.dispositions, item],
        isCreating: false,
      ));
      _vocabCubit.refresh();
    } catch (e) {
      emit(state.copyWith(isCreating: false));
      rethrow;
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Delete custom items (optimistic)
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> deleteBizStep(String code) async {
    if (state.deletingCodes.contains(code)) return;

    final original = List<CbvVocabularyItem>.from(state.bizSteps);
    emit(state.copyWith(
      bizSteps: original.where((b) => b.code != code).toList(),
      deletingCodes: {...state.deletingCodes, code},
    ));

    try {
      await _service.deleteBizStep(code);
      emit(state.copyWith(
        deletingCodes: {...state.deletingCodes}..remove(code),
      ));
      _vocabCubit.refresh();
    } catch (e) {
      emit(state.copyWith(
        bizSteps: original,
        deletingCodes: {...state.deletingCodes}..remove(code),
      ));
      rethrow;
    }
  }

  Future<void> deleteDisposition(String code) async {
    if (state.deletingCodes.contains(code)) return;

    final original = List<CbvVocabularyItem>.from(state.dispositions);
    emit(state.copyWith(
      dispositions: original.where((d) => d.code != code).toList(),
      deletingCodes: {...state.deletingCodes, code},
    ));

    try {
      await _service.deleteDisposition(code);
      emit(state.copyWith(
        deletingCodes: {...state.deletingCodes}..remove(code),
      ));
      _vocabCubit.refresh();
    } catch (e) {
      emit(state.copyWith(
        dispositions: original,
        deletingCodes: {...state.deletingCodes}..remove(code),
      ));
      rethrow;
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────────────────────────────────

  List<CbvVocabularyItem> _replaceEnabled(
    List<CbvVocabularyItem> items,
    String code, {
    required bool enabled,
  }) {
    return items.map((item) {
      if (item.code != code) return item;
      return item.copyWith(enabled: enabled);
    }).toList();
  }
}
