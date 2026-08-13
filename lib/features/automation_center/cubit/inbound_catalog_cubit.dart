import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/data/services/automation_center/inbound_catalog_service.dart';
import 'package:traqtrace_app/features/automation_center/cubit/inbound_catalog_state.dart';

class InboundCatalogCubit extends Cubit<InboundCatalogState> {
  InboundCatalogCubit({required InboundCatalogService service})
      : _service = service,
        super(const InboundCatalogState());

  final InboundCatalogService _service;
  bool _loading = false;

  Future<void> load({bool force = false}) async {
    if (_loading) return;
    // Skip redundant fetches when the workspace-scoped cubit already has data
    // (Outbound ↔ Inbound section switches remount the panel).
    if (!force &&
        state.status == InboundCatalogStatus.success &&
        state.catalog != null) {
      return;
    }
    _loading = true;
    emit(state.copyWith(status: InboundCatalogStatus.loading));
    try {
      final catalog = await _service.fetchCatalog();
      final previousId = state.selectedCategoryId;
      final stillValid = previousId != null &&
          catalog.categories.any((c) => c.id == previousId);
      emit(
        state.copyWith(
          status: InboundCatalogStatus.success,
          catalog: catalog,
          selectedCategoryId: stillValid ? previousId : null,
          clearSelectedCategory: !stillValid,
          error: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: InboundCatalogStatus.error,
          error: e.toString(),
        ),
      );
    } finally {
      _loading = false;
    }
  }

  void selectCategory(String categoryId) {
    emit(state.copyWith(selectedCategoryId: categoryId));
  }

  Future<List<int>> downloadPostmanCollection(String categoryId) {
    return _service.downloadPostmanCollection(categoryId: categoryId);
  }
}
